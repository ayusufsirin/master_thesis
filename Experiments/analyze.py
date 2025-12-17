#!/usr/bin/env python3
"""
PG vs LU-history evo-results analyzer

Usage examples:
  python pg_evo_analyze.py \
      --files results_10_10.csv results_33_10.csv results_0_10.csv results_33_1.csv \
      --metric rmse \
      --pattern "pg_ape_se3" \
      --outdir out

  # Analyze RPE 100m mean
  python pg_evo_analyze.py --files *.csv --metric mean --pattern "pg_rpe_100m" --outdir out
"""

from __future__ import annotations

import argparse
import os
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


# ----------------------------
# Config / parsing
# ----------------------------

LABEL_RE = re.compile(r"^(?P<I>\d+)[_-](?P<H>\d+)$")


@dataclass(frozen=True)
class ExpKey:
    iters: int
    history: int

    @property
    def name(self) -> str:
        return f"{self.iters}_{self.history}"


def parse_label_from_path(path: str) -> ExpKey:
    """
    Extract experiment label from directory name, e.g.
      10_1/outputs/metrics_aligned_se3.csv -> ExpKey(10,1)
    """
    p = Path(path).resolve()

    # Walk upwards until we find a directory matching "<iters>_<history>"
    for parent in p.parents:
        m = LABEL_RE.match(parent.name)
        if m:
            return ExpKey(
                iters=int(m.group("I")),
                history=int(m.group("H")),
            )

    raise ValueError(
        f"Could not find experiment label like '33_10' in path parents: {path}"
    )

def load_one_csv(path: str) -> pd.DataFrame:
    """
    Loads evo CSV into dataframe with first column as 'name' (e.g., pg_ape_se3.zip).
    """
    df = pd.read_csv(path)
    # If the first column is unnamed due to leading comma in your pasted format
    if df.columns[0].startswith("Unnamed"):
        df = df.rename(columns={df.columns[0]: "name"})
    elif df.columns[0] != "name":
        df = df.rename(columns={df.columns[0]: "name"})
    return df


def aggregate_experiments(
    files: List[str],
    *,
    include_regex: Optional[str] = None,
) -> pd.DataFrame:
    """
    Returns a long-form table:
      exp_label, iters, history, name, rmse, mean, median, std, min, max, sse
    """
    rows = []
    cre = re.compile(include_regex) if include_regex else None

    for f in files:
        key = parse_label_from_path(f)
        df = load_one_csv(f)

        if cre is not None:
            df = df[df["name"].astype(str).str.contains(cre)]

        df = df.copy()
        df["exp_label"] = key.name
        df["iters"] = key.iters
        df["history"] = key.history
        rows.append(df)

    if not rows:
        raise ValueError("No rows loaded (check --files and --pattern).")

    out = pd.concat(rows, ignore_index=True)
    return out


# ----------------------------
# Helpers for selection
# ----------------------------

def select_rows(
    data: pd.DataFrame,
    *,
    pattern: str,
) -> pd.DataFrame:
    """
    Filter by a specific evo row key (substring match), e.g. "pg_ape_se3" or "zed_rpe_100m".
    """
    mask = data["name"].astype(str).str.contains(pattern)
    sel = data.loc[mask].copy()
    if sel.empty:
        raise ValueError(
            f"No rows matched pattern='{pattern}'. "
            f"Available examples: {sorted(data['name'].astype(str).unique())[:10]} ..."
        )
    return sel


def pivot_metric(
    sel: pd.DataFrame,
    metric: str,
) -> pd.DataFrame:
    """
    Build a matrix (iters x history) for one metric.
    """
    if metric not in sel.columns:
        raise ValueError(f"Metric '{metric}' not in columns: {list(sel.columns)}")
    mat = sel.pivot_table(index="iters", columns="history", values=metric, aggfunc="mean")
    mat = mat.sort_index().sort_index(axis=1)
    return mat


# ----------------------------
# Plots
# ----------------------------

def plot_heatmap(mat: pd.DataFrame, title: str, outpath: Optional[str] = None) -> None:
    plt.figure()
    arr = mat.values
    plt.imshow(arr, aspect="auto", origin="lower")
    plt.title(title)
    plt.xlabel("LU history")
    plt.ylabel("PG iterations")
    plt.xticks(ticks=np.arange(mat.shape[1]), labels=mat.columns.astype(int))
    plt.yticks(ticks=np.arange(mat.shape[0]), labels=mat.index.astype(int))
    plt.colorbar(label="metric value")
    plt.tight_layout()
    if outpath:
        plt.savefig(outpath, dpi=200)
    plt.close()


def plot_slices(mat: pd.DataFrame, title: str, outpath: Optional[str] = None) -> None:
    """
    Two slice views in one figure:
      - metric vs iterations (one curve per history)
      - metric vs history (one curve per iterations)
    """
    fig = plt.figure(figsize=(10, 4))

    ax1 = fig.add_subplot(1, 2, 1)
    for h in mat.columns:
        ax1.plot(mat.index.values, mat[h].values, marker="o", label=f"H={int(h)}")
    ax1.set_title("Sweep iterations (fixed history)")
    ax1.set_xlabel("PG iterations")
    ax1.set_ylabel("metric")
    ax1.grid(True)
    ax1.legend()

    ax2 = fig.add_subplot(1, 2, 2)
    for i in mat.index:
        ax2.plot(mat.columns.values, mat.loc[i].values, marker="o", label=f"I={int(i)}")
    ax2.set_title("Sweep history (fixed iterations)")
    ax2.set_xlabel("LU history")
    ax2.set_ylabel("metric")
    ax2.grid(True)
    ax2.legend()

    fig.suptitle(title)
    fig.tight_layout()
    if outpath:
        fig.savefig(outpath, dpi=200)
    plt.close(fig)


# ----------------------------
# Tables / effect decomposition
# ----------------------------

def effect_summary_table(mat: pd.DataFrame) -> pd.DataFrame:
    """
    Produces a compact table:
      - global best, worst
      - average over histories for each iters
      - average over iters for each history
    """
    best = mat.stack().idxmin()
    worst = mat.stack().idxmax()

    summary = {
        "best_iters": best[0],
        "best_history": best[1],
        "best_value": float(mat.loc[best[0], best[1]]),
        "worst_iters": worst[0],
        "worst_history": worst[1],
        "worst_value": float(mat.loc[worst[0], worst[1]]),
    }

    iters_means = mat.mean(axis=1).rename("mean_over_histories")
    hist_means = mat.mean(axis=0).rename("mean_over_iters")

    out = pd.DataFrame([summary])
    out = pd.concat([out, iters_means.reset_index().rename(columns={"iters": "iters"}),], axis=1)
    # the concat above may be messy in one row; instead return multi-part frames separately
    # We'll return a dict-like frame: three blocks
    block_a = pd.DataFrame([summary])
    block_b = iters_means.reset_index().rename(columns={"index": "iters"})
    block_c = hist_means.reset_index().rename(columns={"index": "history"})
    block_b.columns = ["iters", "mean_over_histories"]
    block_c.columns = ["history", "mean_over_iters"]

    # Pack into one dataframe with a hierarchical index (nice for saving as CSV)
    block_a.index = pd.Index(["global"], name="block")
    block_b.index = pd.Index(["iters_mean"] * len(block_b), name="block")
    block_c.index = pd.Index(["history_mean"] * len(block_c), name="block")
    return pd.concat([block_a, block_b, block_c], axis=0)


def superposition_check(
    mat: pd.DataFrame,
    *,
    baseline: Tuple[int, int],   # e.g. (0,1)
    a: Tuple[int, int],          # e.g. (33,1)
    b: Tuple[int, int],          # e.g. (0,10)
    ab: Tuple[int, int],         # e.g. (33,10)
) -> pd.DataFrame:
    """
    Tests additivity:
      expected(ab) = baseline + (a-baseline) + (b-baseline)
    Interaction = observed(ab) - expected(ab)

    Negative interaction => better than additive (synergy) if metric is "lower is better".
    """
    def v(p: Tuple[int, int]) -> float:
        i, h = p
        return float(mat.loc[i, h])

    m0 = v(baseline)
    ma = v(a)
    mb = v(b)
    mab = v(ab)

    expected = m0 + (ma - m0) + (mb - m0)
    interaction = mab - expected

    return pd.DataFrame([{
        "baseline": f"{baseline[0]}_{baseline[1]}",
        "a": f"{a[0]}_{a[1]}",
        "b": f"{b[0]}_{b[1]}",
        "ab": f"{ab[0]}_{ab[1]}",
        "m_baseline": m0,
        "m_a": ma,
        "m_b": mb,
        "m_ab_observed": mab,
        "m_ab_expected_additive": expected,
        "interaction_observed_minus_expected": interaction,
        "note": "If lower-is-better: negative interaction => synergy, positive => diminishing returns",
    }])


def two_way_decomposition(mat: pd.DataFrame) -> pd.DataFrame:
    """
    Simple two-way additive decomposition (no statsmodels needed):
      M(i,h) ≈ mu + alpha_i + beta_h + gamma_(i,h)

    Returns:
      - main effect of iters (alpha)
      - main effect of history (beta)
      - interaction residuals (gamma matrix flattened)
    """
    mu = mat.stack().mean()
    alpha = mat.mean(axis=1) - mu
    beta = mat.mean(axis=0) - mu

    # interaction residuals
    gamma = mat.copy()
    for i in mat.index:
        for h in mat.columns:
            gamma.loc[i, h] = mat.loc[i, h] - (mu + alpha.loc[i] + beta.loc[h])

    # return a tidy table
    alpha_df = alpha.reset_index()
    alpha_df.columns = ["iters", "alpha_iters_main_effect"]
    beta_df = beta.reset_index()
    beta_df.columns = ["history", "beta_history_main_effect"]

    gamma_long = gamma.stack().reset_index()
    gamma_long.columns = ["iters", "history", "gamma_interaction_residual"]

    # add mu as a one-row header block
    mu_df = pd.DataFrame([{"mu_global_mean": float(mu)}])

    out = pd.concat(
        [
            mu_df.assign(block="mu"),
            alpha_df.assign(block="alpha"),
            beta_df.assign(block="beta"),
            gamma_long.assign(block="gamma"),
        ],
        ignore_index=True
    )
    return out


# ----------------------------
# Main
# ----------------------------

def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--files", nargs="+", required=True, help="CSV files, each named with label like 33_10.csv")
    ap.add_argument("--pattern", required=True, help="Row selector substring, e.g. 'pg_ape_se3' or 'zed_rpe_100m'")
    ap.add_argument("--metric", default="rmse", help="One of: rmse, mean, median, std, min, max, sse")
    ap.add_argument("--outdir", default="out", help="Output directory for plots/tables")
    ap.add_argument("--include", default=None, help="Optional regex filter applied before pattern (e.g., 'pg_' to ignore zed)")
    ap.add_argument("--baseline", default=None, help="Baseline label like '0_1' for superposition checks")
    ap.add_argument("--super_a", default=None, help="Point A label like '33_1'")
    ap.add_argument("--super_b", default=None, help="Point B label like '0_10'")
    ap.add_argument("--super_ab", default=None, help="Point AB label like '33_10'")
    args = ap.parse_args()

    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    data = aggregate_experiments(args.files, include_regex=args.include)
    sel = select_rows(data, pattern=args.pattern)
    mat = pivot_metric(sel, metric=args.metric)

    # Save the raw pivot table
    mat.to_csv(outdir / f"matrix_{args.pattern}_{args.metric}.csv")

    # Plots
    plot_heatmap(
        mat,
        title=f"{args.pattern} :: {args.metric} (lower is better)",
        outpath=str(outdir / f"heatmap_{args.pattern}_{args.metric}.png"),
    )

    plot_slices(
        mat,
        title=f"{args.pattern} :: {args.metric}",
        outpath=str(outdir / f"slices_{args.pattern}_{args.metric}.png"),
    )

    # Tables
    summ = effect_summary_table(mat)
    summ.to_csv(outdir / f"summary_{args.pattern}_{args.metric}.csv", index=True)

    decomp = two_way_decomposition(mat)
    decomp.to_csv(outdir / f"decomp_{args.pattern}_{args.metric}.csv", index=False)

    # Optional superposition / interaction check
    if args.baseline and args.super_a and args.super_b and args.super_ab:
        def to_key(s: str) -> Tuple[int, int]:
            i, h = s.split("_")
            return (int(i), int(h))
        sp = superposition_check(
            mat,
            baseline=to_key(args.baseline),
            a=to_key(args.super_a),
            b=to_key(args.super_b),
            ab=to_key(args.super_ab),
        )
        sp.to_csv(outdir / f"superposition_{args.pattern}_{args.metric}.csv", index=False)

    print(f"[OK] Wrote outputs to: {outdir.resolve()}")
    print(f"     Matrix shape: {mat.shape} (iters x history)")
    print(f"     Available iters: {list(mat.index)}")
    print(f"     Available history: {list(mat.columns)}")


if __name__ == "__main__":
    main()

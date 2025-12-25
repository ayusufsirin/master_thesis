#!/usr/bin/env python3
import argparse
import re
from pathlib import Path
from typing import Dict, Iterable, Optional, Tuple, List

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import cm
import matplotlib.tri as mtri


METRICS = ("rmse", "mean", "median", "std", "min", "max", "sse")


def infer_IH_from_path(p: Path) -> Tuple[int, int]:
    """
    Infer (I,H) from any parent folder named like '0_1', '10_2', '33_10', etc.
    Searches upward in the path. Raises if not found.
    """
    for parent in [p.parent] + list(p.parents):
        m = re.match(r"^(\d+)[_-](\d+)$", parent.name)
        if m:
            return int(m.group(1)), int(m.group(2))
    raise ValueError(f"Cannot infer (I,H) from path: {p}")


def _find_pattern_column(df: pd.DataFrame) -> str:
    """
    Try to find the column that stores 'pattern' strings (pg_ape_se3, zed_ape_se3, etc.).
    Falls back to the first object/string-like column.
    """
    preferred = ["pattern", "name", "key", "label", "metric", "id"]
    for c in preferred:
        if c in df.columns:
            return c

    # fallback: first object column
    obj_cols = [c for c in df.columns if df[c].dtype == object]
    if obj_cols:
        return obj_cols[0]

    # last resort: first column
    return df.columns[0]


def extract_value_from_csv(
    csv_path: Path,
    *,
    pattern: str,
    metric: str,
    allow_contains: bool = False,
) -> Optional[float]:
    """
    Load a metrics CSV and extract scalar 'metric' value for the given 'pattern'.
    Returns None if not found / not parsable.
    """
    try:
        df = pd.read_csv(csv_path)
    except Exception:
        return None

    if metric not in df.columns:
        return None

    col = _find_pattern_column(df)

    s = df[col].astype(str)
    mask = (s == pattern)
    if not mask.any() and allow_contains:
        mask = s.str.contains(re.escape(pattern), regex=True)

    if not mask.any():
        return None

    # take the first match (your CSV typically has unique rows per pattern)
    val = df.loc[mask, metric].iloc[0]
    try:
        return float(val)
    except Exception:
        return None


def build_matrix(
    files: Iterable[Path],
    *,
    pattern: str,
    metric: str,
    allow_contains: bool = False,
) -> pd.DataFrame:
    """
    Build M(I,H) matrix as DataFrame indexed by I and columns by H.
    """
    values: Dict[Tuple[int, int], float] = {}

    for f in files:
        try:
            I, H = infer_IH_from_path(f)
        except Exception:
            continue

        v = extract_value_from_csv(f, pattern=pattern, metric=metric, allow_contains=allow_contains)
        if v is None:
            continue
        values[(I, H)] = v

    if not values:
        raise RuntimeError(f"No values found for pattern='{pattern}', metric='{metric}'")

    I_vals = sorted({k[0] for k in values.keys()})
    H_vals = sorted({k[1] for k in values.keys()})

    mat = pd.DataFrame(index=I_vals, columns=H_vals, dtype=float)
    for (I, H), v in values.items():
        mat.loc[I, H] = v

    return mat.sort_index().sort_index(axis=1)


def plot_heatmap(
    mat: pd.DataFrame,
    *,
    title: str,
    outpath: Path,
    cmap_name: str = "viridis",
    annotate: bool = True,
    vmin: Optional[float] = None,
    vmax: Optional[float] = None,
) -> None:
    fig, ax = plt.subplots(figsize=(7.8, 5.4))

    data = mat.to_numpy(dtype=float)
    im = ax.imshow(
        data,
        origin="lower",
        aspect="auto",
        cmap=getattr(cm, cmap_name, cm.viridis),
        vmin=vmin,
        vmax=vmax,
    )

    ax.set_title(title)
    ax.set_xlabel("H (history)")
    ax.set_ylabel("I (iterations)")

    ax.set_xticks(np.arange(mat.shape[1]))
    ax.set_xticklabels([str(h) for h in mat.columns.tolist()])
    ax.set_yticks(np.arange(mat.shape[0]))
    ax.set_yticklabels([str(i) for i in mat.index.tolist()])

    cbar = fig.colorbar(im, ax=ax, shrink=0.85, pad=0.02)
    cbar.set_label("metric")

    if annotate:
        for yi in range(mat.shape[0]):
            for xi in range(mat.shape[1]):
                v = data[yi, xi]
                if np.isfinite(v):
                    ax.text(xi, yi, f"{v:.3f}", ha="center", va="center", fontsize=8)

    fig.tight_layout()
    fig.savefig(outpath, dpi=200)
    plt.close(fig)


def plot_slices(
    mat: pd.DataFrame,
    *,
    title: str,
    outpath: Path,
    baseline: Optional[float] = None,
    baseline_label: str = "ZED baseline",
) -> None:
    """
    One figure with two panels:
      left: M vs I for each H
      right: M vs H for each I
    (This supports your marginal analysis in the thesis.)
    """
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11.5, 4.8))

    # left: for each H line over I
    I_vals = mat.index.to_numpy(dtype=float)
    for H in mat.columns:
        y = mat[H].to_numpy(dtype=float)
        ax1.plot(I_vals, y, marker="o", label=f"H={H}")
    ax1.set_title("Slices over I (fixed H)")
    ax1.set_xlabel("I (iterations)")
    ax1.set_ylabel("metric")
    ax1.grid(True, alpha=0.25)
    if baseline is not None and np.isfinite(baseline):
        ax1.axhline(baseline, linestyle="--", linewidth=1.5, label=baseline_label)

    # right: for each I line over H
    H_vals = mat.columns.to_numpy(dtype=float)
    for I in mat.index:
        y = mat.loc[I].to_numpy(dtype=float)
        ax2.plot(H_vals, y, marker="o", label=f"I={I}")
    ax2.set_title("Slices over H (fixed I)")
    ax2.set_xlabel("H (history)")
    ax2.set_ylabel("metric")
    ax2.grid(True, alpha=0.25)
    if baseline is not None and np.isfinite(baseline):
        ax2.axhline(baseline, linestyle="--", linewidth=1.5, label=baseline_label)

    fig.suptitle(title, y=1.02)
    ax1.legend(fontsize=8)
    ax2.legend(fontsize=8)

    fig.tight_layout()
    fig.savefig(outpath, dpi=200, bbox_inches="tight")
    plt.close(fig)


def plot_surface_3d_smooth(
    mat: pd.DataFrame,
    *,
    title: str,
    outpath: Path,
    cmap_name: str = "viridis",
    elev: float = 28.0,
    azim: float = -55.0,
) -> None:
    """
    Smoothed 3D surface via triangular interpolation (continuous-looking even for 4x4 grid).
    Colored with heatmap-like colormap.
    """
    # Prepare scattered points
    mat = mat.sort_index().sort_index(axis=1)
    H_vals = mat.columns.to_numpy(dtype=float)
    I_vals = mat.index.to_numpy(dtype=float)
    Z = mat.to_numpy(dtype=float)

    Xc, Yc = np.meshgrid(H_vals, I_vals)
    xc = Xc.ravel()
    yc = Yc.ravel()
    zc = Z.ravel()

    ok = np.isfinite(zc)
    xc, yc, zc = xc[ok], yc[ok], zc[ok]

    tri = mtri.Triangulation(xc, yc)
    interp = mtri.LinearTriInterpolator(tri, zc)

    H_fine = np.linspace(H_vals.min(), H_vals.max(), 140)
    I_fine = np.linspace(I_vals.min(), I_vals.max(), 140)
    Xf, Yf = np.meshgrid(H_fine, I_fine)
    Zf = interp(Xf, Yf)  # masked array

    cmap = getattr(cm, cmap_name, cm.viridis)

    fig = plt.figure(figsize=(8.6, 6.4))
    ax = fig.add_subplot(111, projection="3d")

    ax.plot_surface(
        Xf, Yf, Zf,
        cmap=cmap,
        linewidth=0,
        antialiased=True,
        shade=False,   # keep colors consistent (heatmap-like)
    )

    ax.set_title(title)
    ax.set_xlabel("H (history)")
    ax.set_ylabel("I (iterations)")
    ax.set_zlabel("metric")
    ax.view_init(elev=elev, azim=azim)

    # colorbar
    sm = cm.ScalarMappable(cmap=cmap)
    sm.set_array(zc)
    sm.set_clim(np.nanmin(zc), np.nanmax(zc))
    fig.colorbar(sm, ax=ax, shrink=0.65, pad=0.08, label="metric")

    fig.tight_layout()
    fig.savefig(outpath, dpi=200)
    plt.close(fig)


def baseline_scalar_from_files(
    files: Iterable[Path],
    *,
    baseline_pattern: str,
    metric: str,
    baseline_ref: str = "mean",   # "mean" or "I0H1"
    allow_contains: bool = False,
) -> float:
    """
    Compute scalar baseline M_baseline for ZED (or any baseline pattern).
    baseline_ref:
      - "mean": average of all found baseline values across files (robust)
      - "I0H1": take only the baseline value from the (0,1) config if present
    """
    vals: List[Tuple[Tuple[int, int], float]] = []
    for f in files:
        try:
            I, H = infer_IH_from_path(f)
        except Exception:
            continue
        v = extract_value_from_csv(f, pattern=baseline_pattern, metric=metric, allow_contains=allow_contains)
        if v is None:
            continue
        vals.append(((I, H), v))

    if not vals:
        raise RuntimeError(f"No baseline values found for '{baseline_pattern}' metric='{metric}'")

    if baseline_ref == "I0H1":
        for (I, H), v in vals:
            if I == 0 and H == 1:
                return float(v)
        # fallback: if (0,1) missing, just mean
        baseline_ref = "mean"

    # mean over all (should be constant anyway)
    return float(np.mean([v for _, v in vals]))

def compute_superposition_gamma(mat: pd.DataFrame) -> pd.DataFrame:
    """
    Gamma(I,H) = M(I,H) - M(I,1) - M(0,H) + M(0,1)
    Requires that I=0 exists in index and H=1 exists in columns.
    """
    if 0 not in mat.index:
        raise RuntimeError("Superposition needs I=0 row in the matrix.")
    if 1 not in mat.columns:
        raise RuntimeError("Superposition needs H=1 column in the matrix.")

    M01 = float(mat.loc[0, 1])
    MI1 = mat[1]          # column at H=1, indexed by I
    M0H = mat.loc[0]      # row at I=0, indexed by H

    gamma = mat.subtract(MI1, axis=0).subtract(M0H, axis=1).add(M01)
    return gamma

def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--files", nargs="+", required=True, help="One or more metrics CSV paths (glob expanded by shell).")
    ap.add_argument("--pattern", required=True, help="PG pattern name, e.g. pg_ape_se3")
    ap.add_argument("--metric", required=True, choices=METRICS, help="Which scalar column to plot, e.g. rmse")
    ap.add_argument("--outdir", required=True, help="Output directory")
    ap.add_argument("--allow-contains", action="store_true", help="Pattern match using contains if exact match fails")

    # outputs
    ap.add_argument("--surface", action="store_true", help="Also write 3D surface plot")
    ap.add_argument("--elev", type=float, default=28.0, help="3D view elevation")
    ap.add_argument("--azim", type=float, default=-55.0, help="3D view azimuth")
    ap.add_argument("--cmap", default="viridis", help="Colormap name (matplotlib), default: viridis")

    # baseline comparison
    ap.add_argument("--baseline-pattern", default=None, help="Baseline pattern, e.g. zed_ape_se3 (single scalar baseline)")
    ap.add_argument("--baseline-ref", default="mean", choices=["mean", "I0H1"],
                    help="How to compute scalar baseline from files (mean over all, or use (0,1))")
    ap.add_argument("--delta-cmap", default="coolwarm", help="Colormap for improvement heatmap (delta), default: coolwarm")
    ap.add_argument("--ratio-cmap", default="viridis", help="Colormap for ratio heatmap, default: viridis")

    ap.add_argument("--gamma", action="store_true",
                    help="Write superposition deviation Gamma(I,H) as CSV (and optionally heatmap).")
    ap.add_argument("--gamma-heatmap", action="store_true",
                    help="Also write a heatmap for Gamma(I,H).")

    args = ap.parse_args()

    files = [Path(x) for x in args.files]
    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    # PG matrix
    mat_pg = build_matrix(files, pattern=args.pattern, metric=args.metric, allow_contains=args.allow_contains)

    # Optional baseline scalar
    baseline_val: Optional[float] = None
    if args.baseline_pattern:
        baseline_val = baseline_scalar_from_files(
            files,
            baseline_pattern=args.baseline_pattern,
            metric=args.metric,
            baseline_ref=args.baseline_ref,
            allow_contains=args.allow_contains,
        )

    # ---- core outputs: heatmap + slices + (optional) surface ----
    plot_heatmap(
        mat_pg,
        title=f"{args.pattern} :: {args.metric}",
        outpath=outdir / f"heatmap_{args.pattern}_{args.metric}.png",
        cmap_name=args.cmap,
        annotate=True,
    )

    plot_slices(
        mat_pg,
        title=f"{args.pattern} :: {args.metric}",
        outpath=outdir / f"slices_{args.pattern}_{args.metric}.png",
        baseline=baseline_val,
        baseline_label=f"{args.baseline_pattern} baseline" if args.baseline_pattern else "baseline",
    )

    if args.surface:
        plot_surface_3d_smooth(
            mat_pg,
            title=f"{args.pattern} :: {args.metric} (3D surface)",
            outpath=outdir / f"surface_{args.pattern}_{args.metric}.png",
            cmap_name=args.cmap,
            elev=args.elev,
            azim=args.azim,
        )

    # ---- baseline-vs-PG comparison outputs (meaningful) ----
    if baseline_val is not None:
        delta = baseline_val - mat_pg
        ratio = delta / baseline_val

        plot_heatmap(
            delta,
            title=f"Δ vs baseline: {args.baseline_pattern} - {args.pattern} :: {args.metric}",
            outpath=outdir / f"heatmap_delta_vs_{args.baseline_pattern}_{args.pattern}_{args.metric}.png",
            cmap_name=args.delta_cmap,
            annotate=True,
        )

        plot_heatmap(
            ratio * 100.0,
            title=f"Relative gain (%) vs baseline: {args.baseline_pattern} vs {args.pattern} :: {args.metric}",
            outpath=outdir / f"heatmap_ratio_vs_{args.baseline_pattern}_{args.pattern}_{args.metric}.png",
            cmap_name=args.ratio_cmap,
            annotate=True,
        )

        if args.surface:
            plot_surface_3d_smooth(
                delta,
                title=f"Δ surface vs baseline: {args.baseline_pattern} - {args.pattern} :: {args.metric}",
                outpath=outdir / f"surface_delta_vs_{args.baseline_pattern}_{args.pattern}_{args.metric}.png",
                cmap_name=args.delta_cmap,
                elev=args.elev,
                azim=args.azim,
            )

    if args.gamma:
        gamma = compute_superposition_gamma(mat_pg)
        gamma_csv = outdir / f"gamma_{args.pattern}_{args.metric}.csv"
        gamma.to_csv(gamma_csv, float_format="%.6f")

        if args.gamma_heatmap:
            # symmetric color limits around 0 look best for +/- deviations
            g = gamma.to_numpy(dtype=float)
            gabs = np.nanmax(np.abs(g[np.isfinite(g)])) if np.isfinite(g).any() else None
            plot_heatmap(
                gamma,
                title=f"Gamma (superposition deviation): {args.pattern} :: {args.metric}",
                outpath=outdir / f"heatmap_gamma_{args.pattern}_{args.metric}.png",
                cmap_name="coolwarm",
                annotate=True,
                vmin=(-gabs if gabs is not None else None),
                vmax=(gabs if gabs is not None else None),
            )

if __name__ == "__main__":
    main()

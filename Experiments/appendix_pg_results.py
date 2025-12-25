#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
from pathlib import Path

import pandas as pd


def tex_escape(s: str) -> str:
    return (
        s.replace("\\", r"\textbackslash{}")
         .replace("_", r"\_")
         .replace("%", r"\%")
         .replace("&", r"\&")
         .replace("#", r"\#")
         .replace("{", r"\{")
         .replace("}", r"\}")
         .replace("^", r"\^{}")
         .replace("~", r"\~{}")
    )


def tex_label(s: str) -> str:
    s = s.lower()
    s = re.sub(r"[^a-z0-9]+", "-", s)
    s = re.sub(r"-+", "-", s).strip("-")
    return s[:90]


def pick_one(folder: Path, glob_pat: str) -> Path | None:
    items = sorted(folder.glob(glob_pat))
    return items[0] if items else None


def pick_all(folder: Path, glob_pat: str) -> list[Path]:
    return sorted(folder.glob(glob_pat))


def csv_to_tabular(csv_path: Path, floatfmt: str = "{:.3f}") -> str:
    df = pd.read_csv(csv_path, index_col=0)

    # nice integer axes if possible
    try:
        df.index = df.index.astype(int)
    except Exception:
        pass
    try:
        df.columns = [int(c) for c in df.columns]
    except Exception:
        pass

    def fmt(x):
        try:
            if pd.isna(x):
                return ""
            return floatfmt.format(float(x))
        except Exception:
            return str(x)

    headers = ["I \\textbackslash H"] + [str(c) for c in df.columns]
    colspec = "r" + "r" * len(df.columns)

    lines = []
    lines.append(r"\begin{tabular}{" + colspec + r"}")
    lines.append(r"\toprule")
    lines.append(" & ".join(headers) + r" \\")
    lines.append(r"\midrule")
    for i, row in df.iterrows():
        vals = [fmt(v) for v in row.values]
        lines.append(str(i) + " & " + " & ".join(vals) + r" \\")
    lines.append(r"\bottomrule")
    lines.append(r"\end{tabular}")
    return "\n".join(lines)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out_root", default="out", help="Root folder (your out/)")
    ap.add_argument("--tex_out", default="appendix_experiment_outputs.tex", help="Generated LaTeX file")
    ap.add_argument("--figprefix", default="./Experiments/", help="Prefix for includegraphics paths, e.g. ./Experiments/")
    ap.add_argument("--float_spec", default="H", help="Figure float spec, e.g. H or htbp")

    # widths
    ap.add_argument("--w_full", default=r"\linewidth", help="Full-width figure/subfigure width")
    ap.add_argument("--w_half", default=r"0.49\linewidth", help="Half-width subfigure width")
    ap.add_argument("--w_third", default=r"0.32\linewidth", help="Third-width subfigure width")

    # table formatting
    ap.add_argument("--floatfmt", default="{:.3f}", help="Float formatting for CSV tables")
    ap.add_argument("--table_vspace", default="1.5em", help="Vertical space below table in subfigure")
    ap.add_argument("--table_raise", default="2.0em", help="Top vspace before table (align with heatmap)")

    # ordering / filtering
    ap.add_argument("--only_variants", default="", help="Comma-separated variant folder names to include (optional)")
    ap.add_argument("--only_patterns", default="", help="Comma-separated pattern folder names to include (optional)")
    ap.add_argument("--only_metrics", default="", help="Comma-separated metric folder names to include (optional)")

    # page breaks
    ap.add_argument("--clearpage_each_pattern", action="store_true", help="Insert \\clearpage after each pattern subsection")
    args = ap.parse_args()

    out_root = Path(args.out_root)
    if not out_root.exists():
        raise SystemExit(f"out_root not found: {out_root}")

    figprefix = args.figprefix
    if figprefix and not figprefix.endswith("/"):
        figprefix += "/"

    only_variants = {s.strip() for s in args.only_variants.split(",") if s.strip()}
    only_patterns = {s.strip() for s in args.only_patterns.split(",") if s.strip()}
    only_metrics = {s.strip() for s in args.only_metrics.split(",") if s.strip()}

    # Expect: out/<variant>/<pattern>/<metric>/
    variants = sorted([p for p in out_root.iterdir() if p.is_dir()])
    if only_variants:
        variants = [v for v in variants if v.name in only_variants]

    lines: list[str] = []
    lines.append(r"% Auto-generated file. Do not edit by hand.")
    lines.append(r"% Preamble requirements:")
    lines.append(r"% \usepackage{graphicx}")
    lines.append(r"% \usepackage{subcaption}")
    lines.append(r"% \usepackage{float}     % for [H]")
    lines.append(r"% \usepackage{booktabs}  % for tables")
    lines.append("")
    lines.append(r"\chapter{Experiment Output Figures}")
    lines.append(r"\label{chap:appendix-experiment-output-figures}")
    lines.append("")

    def fig_path(p: Path) -> str:
        return figprefix + p.as_posix()

    def add_figure_block(
        *,
        slices: Path | None,
        heatmap: Path | None,
        matrix: Path | None,
        surface: Path | None,
        delta_heatmap: Path | None,
        ratio_heatmap: Path | None,
        gamma_heatmap: Path | None,
        gamma_csv: Path | None,
        cap_main: str,
        lab: str,
    ) -> None:
        """
        Flexible layout:
          Row A: slices (full)
          Row B: heatmap + matrix (half/half)
          Row C (optional): surface (full)
          Row D (optional): delta + ratio (half/half)
          Row E (optional): gamma heatmap + gamma table (half/half)

        Only adds rows that have required assets.
        """
        if slices is None and heatmap is None and matrix is None and surface is None \
           and delta_heatmap is None and ratio_heatmap is None and gamma_heatmap is None and gamma_csv is None:
            return

        lines.append(r"\begin{figure}[" + args.float_spec + r"]")
        lines.append(r"\centering")

        # --- Row A: slices ---
        if slices is not None:
            lines.append(r"\begin{subfigure}[t]{" + args.w_full + r"}")
            lines.append(r"\centering")
            lines.append(r"\includegraphics[width=\linewidth]{" + fig_path(slices) + r"}")
            lines.append(r"\caption{Slices}")
            lines.append(r"\end{subfigure}")
            lines.append(r"\vspace{0.6em}")

        # --- Row B: heatmap + matrix ---
        if heatmap is not None and matrix is not None:
            lines.append(r"\begin{subfigure}[t]{" + args.w_half + r"}")
            lines.append(r"\centering")
            lines.append(r"\vspace{0pt}")
            lines.append(r"\includegraphics[width=\linewidth]{" + fig_path(heatmap) + r"}")
            lines.append(r"\caption{Heatmap}")
            lines.append(r"\end{subfigure}")
            lines.append(r"\hfill")

            lines.append(r"\begin{subfigure}[t]{" + args.w_half + r"}")
            lines.append(r"\centering")
            lines.append(r"\vspace{" + args.table_raise + r"}")
            lines.append(csv_to_tabular(matrix, floatfmt=args.floatfmt))
            lines.append(r"\vspace{" + args.table_vspace + r"}")
            lines.append(r"\caption{Matrix}")
            lines.append(r"\end{subfigure}")
            lines.append(r"\vspace{0.8em}")

        # --- Row C: surface (optional) ---
        if surface is not None:
            lines.append(r"\begin{subfigure}[t]{" + args.w_full + r"}")
            lines.append(r"\centering")
            lines.append(r"\includegraphics[width=0.80\linewidth]{" + fig_path(surface) + r"}")
            lines.append(r"\caption{3D surface}")
            lines.append(r"\end{subfigure}")
            lines.append(r"\vspace{0.8em}")

        # --- Row D: baseline comparison (delta + ratio) ---
        if delta_heatmap is not None and ratio_heatmap is not None:
            lines.append(r"\begin{subfigure}[t]{" + args.w_half + r"}")
            lines.append(r"\centering")
            lines.append(r"\vspace{0pt}")
            lines.append(r"\includegraphics[width=\linewidth]{" + fig_path(delta_heatmap) + r"}")
            lines.append(r"\caption{$\Delta$ vs baseline}")
            lines.append(r"\end{subfigure}")
            lines.append(r"\hfill")

            lines.append(r"\begin{subfigure}[t]{" + args.w_half + r"}")
            lines.append(r"\centering")
            lines.append(r"\vspace{0pt}")
            lines.append(r"\includegraphics[width=\linewidth]{" + fig_path(ratio_heatmap) + r"}")
            lines.append(r"\caption{Relative gain (\%)}")
            lines.append(r"\end{subfigure}")
            lines.append(r"\vspace{0.8em}")

        # --- Row E: gamma interaction (heatmap + table) ---
        if gamma_heatmap is not None and gamma_csv is not None:
            lines.append(r"\begin{subfigure}[t]{" + args.w_half + r"}")
            lines.append(r"\centering")
            lines.append(r"\vspace{0pt}")
            lines.append(r"\includegraphics[width=\linewidth]{" + fig_path(gamma_heatmap) + r"}")
            lines.append(r"\caption{Interaction heatmap ($\Gamma$)}")
            lines.append(r"\end{subfigure}")
            lines.append(r"\hfill")

            lines.append(r"\begin{subfigure}[t]{" + args.w_half + r"}")
            lines.append(r"\centering")
            lines.append(r"\vspace{" + args.table_raise + r"}")
            lines.append(csv_to_tabular(gamma_csv, floatfmt=args.floatfmt))
            lines.append(r"\vspace{" + args.table_vspace + r"}")
            lines.append(r"\caption{Interaction matrix ($\Gamma$)}")
            lines.append(r"\end{subfigure}")

        lines.append(r"\caption{" + tex_escape(cap_main) + r"}")
        lines.append(r"\label{fig:appendix-" + lab + r"}")
        lines.append(r"\end{figure}")
        lines.append("")

    for variant_dir in variants:
        variant = variant_dir.name
        pattern_dirs = sorted([p for p in variant_dir.iterdir() if p.is_dir()])
        if only_patterns:
            pattern_dirs = [p for p in pattern_dirs if p.name in only_patterns]
        if not pattern_dirs:
            continue

        lines.append(r"\section{" + tex_escape(variant) + r"}")
        lines.append(r"\label{sec:appendix-" + tex_label(variant) + r"}")
        lines.append("")

        for pattern_dir in pattern_dirs:
            pattern = pattern_dir.name
            metric_dirs = sorted([m for m in pattern_dir.iterdir() if m.is_dir()])
            if only_metrics:
                metric_dirs = [m for m in metric_dirs if m.name in only_metrics]
            if not metric_dirs:
                continue

            lines.append(r"\subsection{" + tex_escape(pattern) + r"}")
            lines.append(r"\label{sec:appendix-" + tex_label(variant + '-' + pattern) + r"}")
            lines.append("")

            for metric_dir in metric_dirs:
                metric = metric_dir.name

                # Core artifacts
                slices = pick_one(metric_dir, "slices_*.png")
                heatmap = pick_one(metric_dir, "heatmap_*.png")
                matrix = pick_one(metric_dir, "matrix_*.csv")

                # New artifacts
                surface = pick_one(metric_dir, "surface_*.png")
                delta_heatmap = pick_one(metric_dir, "heatmap_delta_vs_*.png")
                ratio_heatmap = pick_one(metric_dir, "heatmap_ratio_vs_*.png")
                gamma_heatmap = pick_one(metric_dir, "heatmap_gamma_*.png")
                gamma_csv = pick_one(metric_dir, "gamma_*.csv")

                # If nothing exists, skip
                if all(x is None for x in [slices, heatmap, matrix, surface, delta_heatmap, ratio_heatmap, gamma_heatmap, gamma_csv]):
                    continue

                cap_main = f"{variant} | {pattern} | {metric}"
                lab = tex_label(f"{variant}-{pattern}-{metric}")

                add_figure_block(
                    slices=slices,
                    heatmap=heatmap,
                    matrix=matrix,
                    surface=surface,
                    delta_heatmap=delta_heatmap,
                    ratio_heatmap=ratio_heatmap,
                    gamma_heatmap=gamma_heatmap,
                    gamma_csv=gamma_csv,
                    cap_main=cap_main,
                    lab=lab,
                )

            if args.clearpage_each_pattern:
                lines.append(r"\clearpage")
                lines.append("")

        lines.append(r"\clearpage")
        lines.append("")

    Path(args.tex_out).write_text("\n".join(lines), encoding="utf-8")
    print(f"[OK] Wrote {args.tex_out}")


if __name__ == "__main__":
    main()

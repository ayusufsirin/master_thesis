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

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out_root", default="out", help="Root folder (your out/)")
    ap.add_argument("--tex_out", default="appendix_experiment_outputs.tex", help="Generated LaTeX file")
    ap.add_argument("--figprefix", default="./Experiments/", help="Prefix for includegraphics paths, e.g. ./Experiments/")
    ap.add_argument("--figwidth_top", default=r"\linewidth", help="Width for slices (top row)")
    ap.add_argument("--figwidth_bottom", default=r"0.49\linewidth", help="Width for bottom row subfigures")
    ap.add_argument("--float_spec", default="H", help="Figure float spec, e.g. H or htbp")
    args = ap.parse_args()

    out_root = Path(args.out_root)
    if not out_root.exists():
        raise SystemExit(f"out_root not found: {out_root}")

    figprefix = args.figprefix
    if figprefix and not figprefix.endswith("/"):
        figprefix += "/"

    # Expect: out/<variant>/<pattern>/<metric>/
    variants = sorted([p for p in out_root.iterdir() if p.is_dir()])

    lines = []
    lines.append(r"% Auto-generated file. Do not edit by hand.")
    lines.append(r"% Preamble requirements:")
    lines.append(r"% \usepackage{graphicx}")
    lines.append(r"% \usepackage{subcaption}")
    lines.append(r"% \usepackage{float}     % for [H]")
    lines.append(r"% \usepackage{booktabs}  % for tables")
    lines.append("")
    # lines.append(r"\appendix")
    lines.append(r"\chapter{Slice Comparison Figures}")
    lines.append(r"\label{chap:appendix-slice-comparison-figures}")
    lines.append("")

    def fig_path(p: Path) -> str:
        # includegraphics path uses forward slashes
        return figprefix + p.as_posix()

    for variant_dir in variants:
        variant = variant_dir.name
        pattern_dirs = sorted([p for p in variant_dir.iterdir() if p.is_dir()])
        if not pattern_dirs:
            continue

        lines.append(r"\section{" + tex_escape(variant) + r"}")
        lines.append(r"\label{sec:appendix-" + tex_label(variant) + r"}")
        lines.append("")

        for pattern_dir in pattern_dirs:
            pattern = pattern_dir.name
            metric_dirs = sorted([m for m in pattern_dir.iterdir() if m.is_dir()])
            if not metric_dirs:
                continue

            lines.append(r"\subsection{" + tex_escape(pattern) + r"}")
            lines.append(r"\label{sec:appendix-" + tex_label(variant + '-' + pattern) + r"}")
            lines.append("")

            for metric_dir in metric_dirs:
                metric = metric_dir.name

                slices  = pick_one(metric_dir, "slices_*.png")
                heatmap = pick_one(metric_dir, "heatmap_*.png")
                matrix  = pick_one(metric_dir, "matrix_*.csv")

                # Require all three for the 2x2 layout (as you requested)
                if slices is None or heatmap is None or matrix is None:
                    continue

                cap_main = f"{variant} | {pattern} | {metric}"
                lab = tex_label(f"{variant}-{pattern}-{metric}")

                lines.append(r"\begin{figure}[" + args.float_spec + r"]")
                lines.append(r"\centering")

                # Row 1: slices spanning full width
                lines.append(r"\begin{subfigure}[t]{" + args.figwidth_top + r"}")
                lines.append(r"\centering")
                lines.append(r"\includegraphics[width=\linewidth]{" + fig_path(slices) + r"}")
                lines.append(r"\caption{Slices}")
                lines.append(r"\end{subfigure}")
                lines.append(r"\vspace{0.6em}")

                # Row 2: heatmap (left) + table (right)
                lines.append(r"\begin{subfigure}[t]{" + args.figwidth_bottom + r"}")
                lines.append(r"\centering")
                lines.append(r"\vspace{0pt}")
                lines.append(r"\includegraphics[width=\linewidth]{" + fig_path(heatmap) + r"}")
                lines.append(r"\caption{Heatmap}")
                lines.append(r"\end{subfigure}")
                lines.append(r"\hfill")

                lines.append(r"\begin{subfigure}[t]{" + args.figwidth_bottom + r"}")
                lines.append(r"\centering")
                lines.append(r"\vspace{2.0em}")
                lines.append(csv_to_tabular(matrix))
                lines.append(r"\vspace{1.5em}")
                lines.append(r"\caption{Matrix}")
                lines.append(r"\end{subfigure}")

                lines.append(r"\caption{" + tex_escape(cap_main) + r"}")
                lines.append(r"\label{fig:appendix-" + lab + r"}")
                lines.append(r"\end{figure}")
                lines.append("")

            lines.append(r"\clearpage")
            lines.append("")

    Path(args.tex_out).write_text("\n".join(lines), encoding="utf-8")
    print(f"[OK] Wrote {args.tex_out}")

if __name__ == "__main__":
    main()

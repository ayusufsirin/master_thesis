#!/usr/bin/env python3
import argparse
import os
import re
from pathlib import Path
from typing import List, Tuple, Dict, Any


def find_pngs(dir_path: Path, pattern: str) -> List[Path]:
    if not dir_path.exists():
        return []
    return sorted(p for p in dir_path.glob(pattern) if p.is_file())


def tex_escape(text: str) -> str:
    """
    Escape LaTeX special chars for captions (paths must NOT be escaped).
    """
    replacements = {
        "&": r"\&",
        "%": r"\%",
        "$": r"\$",
        "#": r"\#",
        "_": r"\_",
        "{": r"\{",
        "}": r"\}",
        "~": r"\textasciitilde{}",
        "^": r"\textasciicircum{}",
        "\\": r"\textbackslash{}",
    }
    for k, v in replacements.items():
        text = text.replace(k, v)
    return text


def parse_by_iter_name(name: str):
    """
    Expected: iter_<iter>_histories_vs_gt_<mode>_<align>[_view].png
    Returns: (iter, mode, align, view)   # view may be None
    """
    m = re.match(
        r"iter_(\d+)_histories_vs_gt_([^_]+)_([^_]+)(?:_([^_]+))?\.png$",
        name,
    )
    if not m:
        return None
    iter_val = int(m.group(1))
    mode = m.group(2)
    align = m.group(3)
    view = m.group(4)  # can be None if no suffix
    return iter_val, mode, align, view


def parse_by_hist_name(name: str):
    """
    Expected: hist_<hist>_iters_vs_gt_<mode>_<align>[_view].png
    Returns: (hist, mode, align, view)
    """
    m = re.match(
        r"hist_(\d+)_iters_vs_gt_([^_]+)_([^_]+)(?:_([^_]+))?\.png$",
        name,
    )
    if not m:
        return None
    hist_val = int(m.group(1))
    mode = m.group(2)
    align = m.group(3)
    view = m.group(4)
    return hist_val, mode, align, view


def parse_per_run_name(name: str) -> Tuple[str, str, str]:
    """
    Expected: <exp>_zed_pg_vs_gt_<mode>_<align>.png
    Returns: (exp_name, mode, align)
    """
    m = re.match(r"(.+)_zed_pg_vs_gt_([^_]+)_([^_]+)\.png$", name)
    if not m:
        return None
    return m.group(1), m.group(2), m.group(3)


def make_figure_block(graphics_prefix: str,
                      img_rel_path: str,
                      caption: str,
                      label: str) -> str:
    """
    Simple single-image figure.
    """
    return (
        "\\begin{figure}[H]\n"
        "\\centering\n"
        f"\\includegraphics[width=\\textwidth]{{{graphics_prefix}{img_rel_path}}}\n"
        f"\\caption{{{tex_escape(caption)}}}\n"
        f"\\label{{{label}}}\n"
        "\\end{figure}\n\n"
    )


def make_by_iter_group_block(
    graphics_prefix: str,
    group_key: Tuple[int, str, str],
    views: List[Tuple[str, str, str]],
) -> str:
    """
    Create one figure with multiple subfigures for a given (iter, mode, align) group.

    group_key: (iter_val, mode, align)
    views: list of (view_name, img_rel, label_suffix)
           where label_suffix is used after fig:pg_iter_... for subfigure labels.
    """
    iter_val, mode, align = group_key

    lines: List[str] = []
    lines.append("\\begin{figure}[H]")
    lines.append("    \\centering")

    # Subfigures
    for view_name, img_rel, sub_label in views:
        view_str = f", view: {view_name}" if view_name else ""
        sub_caption = (
            f"PG trajectories for iteration {iter_val} over all histories "
            f"(mode: {mode}, alignment: {align}{view_str})."
        )

        label = f"fig:pg_iter_{iter_val}_{mode}_{align}"
        if view_name:
            label += f"_{view_name}"

        lines.extend(
            [
                "    \\begin{subfigure}[t]{0.49\\linewidth}",
                "        \\centering",
                f"        \\includegraphics[width=\\textwidth]{{{graphics_prefix}{img_rel}}}",
                f"        \\caption{{{tex_escape(sub_caption)}}}",
                f"        \\label{{{label}}}",
                "    \\end{subfigure}",
            ]
        )

    lines.append("")

    overall_caption = (
        f"PG iteration {iter_val} trajectory comparison over all histories "
        f"(mode: {mode}, alignment: {align})."
    )
    overall_label = f"fig:appendix-pg_iter_{iter_val}_{mode}_{align}"

    lines.append(f"    \\caption{{{tex_escape(overall_caption)}}}")
    lines.append(f"    \\label{{{overall_label}}}")
    lines.append("\\end{figure}")
    lines.append("")

    return "\n".join(lines)


def make_by_hist_group_block(
    graphics_prefix: str,
    group_key: Tuple[int, str, str],
    views: List[Tuple[str, str, str]],
) -> str:
    """
    Create one figure with multiple subfigures for a given (hist, mode, align) group.

    group_key: (hist_val, mode, align)
    views: list of (view_name, img_rel, label_suffix)
    """
    hist_val, mode, align = group_key

    lines: List[str] = []
    lines.append("\\begin{figure}[H]")
    lines.append("    \\centering")

    for view_name, img_rel, sub_label in views:
        view_str = f", view: {view_name}" if view_name else ""
        sub_caption = (
            f"PG trajectories for history {hist_val} across different iterations "
            f"(mode: {mode}, alignment: {align}{view_str})."
        )

        label = f"fig:pg_hist_{hist_val}_{mode}_{align}"
        if view_name:
            label += f"_{view_name}"

        lines.extend(
            [
                "    \\begin{subfigure}[t]{0.49\\linewidth}",
                "        \\centering",
                f"        \\includegraphics[width=\\textwidth]{{{graphics_prefix}{img_rel}}}",
                f"        \\caption{{{tex_escape(sub_caption)}}}",
                f"        \\label{{{label}}}",
                "    \\end{subfigure}",
            ]
        )

    lines.append("")

    overall_caption = (
        f"PG iteration comparison for history {hist_val} "
        f"(mode: {mode}, alignment: {align})."
    )
    overall_label = f"fig:appendix-pg_hist_{hist_val}_{mode}_{align}"

    lines.append(f"    \\caption{{{tex_escape(overall_caption)}}}")
    lines.append(f"    \\label{{{overall_label}}}")
    lines.append("\\end{figure}")
    lines.append("")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="Generate LaTeX appendix file for evo trajectory plots."
    )
    parser.add_argument(
        "--root", default=".",
        help="Root folder that contains experiment directories and traj_plots (default: .)",
    )
    parser.add_argument(
        "--out", default=None,
        help="Output traj_plots directory (default: <root>/traj_plots)",
    )
    parser.add_argument(
        "--tex-path", default="appendix_traj_plots.tex",
        help="Path to generated LaTeX file (default: appendix_traj_plots.tex)",
    )
    parser.add_argument(
        "--graphics-prefix", default="",
        help="Prefix for \\includegraphics paths, e.g. ./Experiments/ (default: '')",
    )
    parser.add_argument(
        "--include-per-run", action="store_true",
        help="Also include per-run figures in the appendix.",
    )
    args = parser.parse_args()

    root = Path(args.root).resolve()
    out_dir = Path(args.out) if args.out is not None else root / "traj_plots"
    out_dir = out_dir.resolve()

    per_run_dir = out_dir / "per_run"
    by_iter_dir = out_dir / "by_iter"
    by_hist_dir = out_dir / "by_hist"

    # Make tex_path absolute so relpaths are well-defined
    tex_path = Path(args.tex_path).resolve()

    graphics_prefix = args.graphics_prefix

    # ---- rel_to_tex using os.path.relpath ----
    def rel_to_tex(p: Path) -> str:
        # path from folder containing tex file to the image
        rel = os.path.relpath(p, tex_path.parent)
        # normalize to forward slashes for LaTeX
        return rel.replace(os.sep, "/")

    lines: List[str] = []
    lines.append("% Auto-generated trajectory appendix")
    lines.append("% Do not edit by hand; regenerate via generate_traj_appendix.py")
    lines.append("")
    lines.append("\\chapter{Trajectory Comparison Plots}")
    lines.append("\\label{chap:appendix-traj}")
    lines.append("")

    # Common view order for grouping (speeds will be filtered out anyway)
    view_order_priority = {
        "rpy": 0,
        "xyz": 1,
        "trajectories": 2,
        "speeds": 99,  # kept here but filtered earlier
    }

    def sort_key(item: Tuple[str, Path]) -> Any:
        view_name, _ = item
        return (view_order_priority.get(view_name, 100), view_name)

    # ---------- by_iter (grouped into subfigures, speeds removed) ----------
    by_iter_pngs = find_pngs(by_iter_dir, "iter_*.png")
    if by_iter_pngs:
        lines.append("\\section{PG Iteration Histories (grouped by iteration)}")
        lines.append("")

        # Group by (iter, mode, align)
        groups: Dict[Tuple[int, str, str], List[Tuple[str, Path]]] = {}

        for img in by_iter_pngs:
            parsed = parse_by_iter_name(img.name)
            if parsed is None:
                continue
            iter_val, mode, align, view = parsed

            # REMOVE SPEED GRAPHS
            if view == "speeds":
                continue

            view_name = view if view is not None else ""
            key = (iter_val, mode, align)
            groups.setdefault(key, []).append((view_name, img))

        # Emit one figure per group
        for key in sorted(groups.keys()):
            items = sorted(groups[key], key=sort_key)

            views_for_block: List[Tuple[str, str, str]] = []
            for view_name, img_path in items:
                img_rel = rel_to_tex(img_path)
                sub_label_suffix = view_name if view_name else "noview"
                views_for_block.append((view_name, img_rel, sub_label_suffix))

            block = make_by_iter_group_block(graphics_prefix, key, views_for_block)
            lines.append(block)

    # ---------- by_hist (grouped into subfigures, speeds removed) ----------
    by_hist_pngs = find_pngs(by_hist_dir, "hist_*.png")
    if by_hist_pngs:
        lines.append("\\section{PG Iteration Comparison (grouped by history)}")
        lines.append("")

        # Group by (hist, mode, align)
        groups_hist: Dict[Tuple[int, str, str], List[Tuple[str, Path]]] = {}

        for img in by_hist_pngs:
            parsed = parse_by_hist_name(img.name)
            if parsed is None:
                continue
            hist_val, mode, align, view = parsed

            # REMOVE SPEED GRAPHS
            if view == "speeds":
                continue

            view_name = view if view is not None else ""
            key = (hist_val, mode, align)
            groups_hist.setdefault(key, []).append((view_name, img))

        for key in sorted(groups_hist.keys()):
            items = sorted(groups_hist[key], key=sort_key)

            views_for_block: List[Tuple[str, str, str]] = []
            for view_name, img_path in items:
                img_rel = rel_to_tex(img_path)
                sub_label_suffix = view_name if view_name else "noview"
                views_for_block.append((view_name, img_rel, sub_label_suffix))

            block = make_by_hist_group_block(graphics_prefix, key, views_for_block)
            lines.append(block)

    # ---------- per_run (optional, unchanged single-image figures) ----------
    if args.include_per_run:
        per_run_pngs = find_pngs(per_run_dir, "*_zed_pg_vs_gt_*.png")
        if per_run_pngs:
            lines.append("\\section{Per-run Trajectory Comparisons}")
            lines.append("")
            for img in per_run_pngs:
                parsed = parse_per_run_name(img.name)
                if parsed is None:
                    continue
                exp_name, mode, align = parsed
                caption = (
                    f"Ground truth, ZED odometry and PG odometry for experiment "
                    f"{exp_name} (mode: {mode}, alignment: {align})."
                )
                safe_exp = re.sub(r"[^a-zA-Z0-9]+", "_", exp_name)
                label = f"fig:traj_{safe_exp}_{mode}_{align}"
                img_rel = rel_to_tex(img)
                lines.append(make_figure_block(graphics_prefix, img_rel, caption, label))

    # Write file
    tex_path.parent.mkdir(parents=True, exist_ok=True)
    tex_path.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote LaTeX appendix to: {tex_path}")


if __name__ == "__main__":
    main()

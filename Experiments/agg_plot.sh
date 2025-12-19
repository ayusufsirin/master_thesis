#!/usr/bin/env bash
set -euo pipefail

# Folder that contains the experiment directories (0_2, 0_5, 10_2, 33_10, 100_1, ...)
ROOT="${1:-.}"
OUT="${2:-${ROOT}/traj_plots}"
MODE="${3:-xy}"         # xy or xyz
ALIGN="${4:-raw}"       # raw or aligned

mkdir -p "$OUT/per_run" "$OUT/by_iter" "$OUT/by_hist"

# Enable ** recursion and make non-matching globs expand to nothing
shopt -s globstar nullglob

# Helper: build evo_traj args for alignment
traj_align_args=()
if [[ "$ALIGN" == "aligned" ]]; then
  # SE(3) Umeyama alignment
  traj_align_args=(-a)
fi

# ---------- Safe helpers to locate TUM files inside one experiment ----------
# We *do not* use ls here, to avoid set -e killing the script when there is no match.

find_gt() {
  local exp_dir=$1
  local matches=("$exp_dir"/outputs/**/gps*_odometry.tum)
  # If nullglob -> no match => array empty
  if (( ${#matches[@]} > 0 )); then
    printf '%s\n' "${matches[0]}"
  fi
}

find_zed() {
  local exp_dir=$1
  local matches=("$exp_dir"/outputs/**/zed*_odom.tum)
  if (( ${#matches[@]} > 0 )); then
    printf '%s\n' "${matches[0]}"
  fi
}

find_pg() {
  local exp_dir=$1
  local matches=("$exp_dir"/outputs/**/pg*_odom.tum)
  if (( ${#matches[@]} > 0 )); then
    printf '%s\n' "${matches[0]}"
  fi
}

# ---------- 1) Per-run plots (GT vs ZED vs PG for each exp) ----------
for exp_dir in "$ROOT"/*_*; do
  [[ -d "$exp_dir" ]] || continue

  gt="$(find_gt "$exp_dir" || true)"
  zed="$(find_zed "$exp_dir" || true)"
  pg="$(find_pg "$exp_dir" || true)"

  [[ -n "$gt" && -n "$zed" && -n "$pg" ]] || continue

  exp_name="$(basename "$exp_dir")"
  evo_traj tum "$zed" "$pg" --ref "$gt" "${traj_align_args[@]}" \
    --plot --plot_mode "$MODE" \
    --save_plot "$OUT/per_run/${exp_name}_zed_pg_vs_gt_${MODE}_${ALIGN}.png"
done

# ---------- Detect available iters/hists from folder names like "100_2" ----------
# Only take entries that look like "<number>_<number>"
mapfile -t iters < <(ls -1 "$ROOT" | awk -F_ 'NF==2 && $1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ {print $1}' | sort -n | uniq)
mapfile -t hists < <(ls -1 "$ROOT" | awk -F_ 'NF==2 && $1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ {print $2}' | sort -n | uniq)

# ---------- 2) Group by PG-iter: overlay histories for each iter ----------
for iter in "${iters[@]}"; do
  files=()
  gt=""
  zed=""

  for hist in "${hists[@]}"; do
    exp_dir="$ROOT/${iter}_${hist}"
    [[ -d "$exp_dir" ]] || continue

    gt_candidate="$(find_gt "$exp_dir" || true)"
    zed_candidate="$(find_zed "$exp_dir" || true)"
    pg_candidate="$(find_pg "$exp_dir" || true)"

    [[ -n "$gt_candidate" && -n "$zed_candidate" && -n "$pg_candidate" ]] || continue

    gt="$gt_candidate"
    zed="$zed_candidate"
    files+=("$pg_candidate")
  done

  [[ -n "$gt" && -n "$zed" && ${#files[@]} -gt 0 ]] || continue

  evo_traj tum "$zed" "${files[@]}" --ref "$gt" "${traj_align_args[@]}" \
    --plot --plot_mode "$MODE" \
    --save_plot "$OUT/by_iter/iter_${iter}_histories_vs_gt_${MODE}_${ALIGN}.png"
done

# ---------- 3) Group by LU-history: overlay iters for each history ----------
for hist in "${hists[@]}"; do
  files=()
  gt=""
  zed=""

  for iter in "${iters[@]}"; do
    exp_dir="$ROOT/${iter}_${hist}"
    [[ -d "$exp_dir" ]] || continue

    gt_candidate="$(find_gt "$exp_dir" || true)"
    zed_candidate="$(find_zed "$exp_dir" || true)"
    pg_candidate="$(find_pg "$exp_dir" || true)"

    [[ -n "$gt_candidate" && -n "$zed_candidate" && -n "$pg_candidate" ]] || continue

    gt="$gt_candidate"
    zed="$zed_candidate"
    files+=("$pg_candidate")
  done

  [[ -n "$gt" && -n "$zed" && ${#files[@]} -gt 0 ]] || continue

  evo_traj tum "$zed" "${files[@]}" --ref "$gt" "${traj_align_args[@]}" \
    --plot --plot_mode "$MODE" \
    --save_plot "$OUT/by_hist/hist_${hist}_iters_vs_gt_${MODE}_${ALIGN}.png"
done

echo "Wrote plots under: $OUT"

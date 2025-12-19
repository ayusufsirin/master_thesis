#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
OUT="${2:-${ROOT}/traj_plots}"
MODE="${3:-xy}"         # xy or xyz
ALIGN="${4:-raw}"       # raw or aligned

mkdir -p "$OUT/per_run" "$OUT/by_iter" "$OUT/by_hist"

# For nicer legend names
TMP_LABEL_DIR="$OUT/tmp_labels"
mkdir -p "$TMP_LABEL_DIR"

shopt -s globstar nullglob

traj_align_args=()
if [[ "$ALIGN" == "aligned" ]]; then
  traj_align_args=(-a)
fi

find_gt() {
  local exp_dir=$1
  local matches=("$exp_dir"/outputs/**/gps*_odometry.tum)
  (( ${#matches[@]} > 0 )) && printf '%s\n' "${matches[0]}"
}

find_zed() {
  local exp_dir=$1
  local matches=("$exp_dir"/outputs/**/zed*_odom.tum)
  (( ${#matches[@]} > 0 )) && printf '%s\n' "${matches[0]}"
}

find_pg() {
  local exp_dir=$1
  local matches=("$exp_dir"/outputs/**/pg*_odom.tum)
  (( ${#matches[@]} > 0 )) && printf '%s\n' "${matches[0]}"
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

# ---------- Detect iters / hists ----------
mapfile -t iters < <(ls -1 "$ROOT" | awk -F_ 'NF==2 && $1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ {print $1}' | sort -n | uniq)
mapfile -t hists < <(ls -1 "$ROOT" | awk -F_ 'NF==2 && $1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ {print $2}' | sort -n | uniq)

# ---------- 2) Group by PG-iter: overlay histories for each iter ----------
for iter in "${iters[@]}"; do
  files=()
  labels=()
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
    labels+=("${iter}_${hist}")   # legend suffix
  done

  [[ -n "$gt" && -n "$zed" && ${#files[@]} -gt 0 ]] || continue

  # Build labeled *copies* for this iter
  tmp_files=()
  for i in "${!files[@]}"; do
    src="${files[$i]}"
    label="${labels[$i]}"
    link="$TMP_LABEL_DIR/pg_${label}.tum"
    cp -f "$src" "$link"          # <-- copy instead of symlink
    tmp_files+=("$link")
  done

  evo_traj tum "$zed" "${tmp_files[@]}" --ref "$gt" "${traj_align_args[@]}" \
    --plot --plot_mode "$MODE" \
    --save_plot "$OUT/by_iter/iter_${iter}_histories_vs_gt_${MODE}_${ALIGN}.png"
done

# ---------- 3) Group by history: overlay iters for each hist ----------
for hist in "${hists[@]}"; do
  files=()
  labels=()
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
    labels+=("${iter}_${hist}")
  done

  [[ -n "$gt" && -n "$zed" && ${#files[@]} -gt 0 ]] || continue

  tmp_files=()
  for i in "${!files[@]}"; do
    src="${files[$i]}"
    label="${labels[$i]}"
    link="$TMP_LABEL_DIR/pg_${label}.tum"
    cp -f "$src" "$link"          # <-- same here
    tmp_files+=("$link")
  done

  evo_traj tum "$zed" "${tmp_files[@]}" --ref "$gt" "${traj_align_args[@]}" \
    --plot --plot_mode "$MODE" \
    --save_plot "$OUT/by_hist/hist_${hist}_iters_vs_gt_${MODE}_${ALIGN}.png"
done

echo "Wrote plots under: $OUT"

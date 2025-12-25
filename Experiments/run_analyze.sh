#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

# -----------------------------
# Parallelism
# -----------------------------
JOBS="${JOBS:-$(nproc)}"

# -----------------------------
# Toggle extras
# -----------------------------
SURFACE="${SURFACE:-1}"          # 1 => also generate 3D surface plots
BASELINE="${BASELINE:-1}"        # 1 => also generate delta/ratio vs ZED baseline
GAMMA="${GAMMA:-1}"              # 1 => also generate superposition deviation Γ(I,H)
GAMMA_HEATMAP="${GAMMA_HEATMAP:-1}" # 1 => also plot heatmap for Γ(I,H)
BASELINE_REF="${BASELINE_REF:-mean}" # mean | I0H1 (as implemented in analyze.py)

# -----------------------------
# Plot styling
# -----------------------------
CMAP="${CMAP:-viridis}"
DELTA_CMAP="${DELTA_CMAP:-coolwarm}"
RATIO_CMAP="${RATIO_CMAP:-viridis}"
GAMMA_CMAP="${GAMMA_CMAP:-coolwarm}"

# -----------------------------
# Metrics to extract
# -----------------------------
metrics=(rmse mean median std min max sse)

# -----------------------------
# File variant → suffix mapping
# -----------------------------
variants=(
  "metrics_aligned_se3:se3"
  "metrics_aligned_sim3:sim3"
  "metrics_raw:raw"
)

# -----------------------------
# Base patterns (without suffix)
# -----------------------------
patterns=(
  "pg_ape"
  "pg_rpe_1m"
  "pg_rpe_1s"
  "pg_rpe_50m"
  "pg_rpe_100m"
  "pg_rpe_200m"
  "pg_rpe_300m"
  "pg_rpe_400m"
  "pg_rpe_500m"
  "pg_rpe_600m"
  "pg_rpe_700m"
  "pg_yaw_50m"
)

IMAGE="evo-cli"
ANALYZE="analyze.py"
mkdir -p out

jobs_file="$(mktemp)"
trap 'rm -f "$jobs_file"' EXIT

# Matplotlib concurrency safety + deterministic backend
ENV_MPL='-e MPLBACKEND=Agg -e MPLCONFIGDIR=/tmp/mplconfig'

for v in "${variants[@]}"; do
  IFS=":" read -r file suffix <<< "$v"

  inputs=( */outputs/"${file}.csv" )
  (( ${#inputs[@]} == 0 )) && continue

  # representative CSV for presence checks
  sample_csv="${inputs[0]}"

  for p in "${patterns[@]}"; do
    pattern="${p}_${suffix}"

    # map pg_* -> zed_* baseline for same suffix
    baseline_base="${p/#pg_/zed_}"
    baseline_pattern="${baseline_base}_${suffix}"

    for m in "${metrics[@]}"; do
      outdir="out/${file}/${pattern}/${m}"
      mkdir -p "$outdir"

      # -------- surface args --------
      surface_args="--cmap \"$CMAP\" --delta-cmap \"$DELTA_CMAP\" --ratio-cmap \"$RATIO_CMAP\""
      if [[ "$SURFACE" == "1" ]]; then
        surface_args="--surface $surface_args"
      fi

      # -------- gamma args --------
      gamma_args=""
      if [[ "$GAMMA" == "1" ]]; then
        gamma_args="--gamma"
        if [[ "$GAMMA_HEATMAP" == "1" ]]; then
          gamma_args="$gamma_args --gamma-heatmap"
        fi
        # gamma uses coolwarm internally in the patch I gave; keep cmap here only if you add it.
        # If you later add --gamma-cmap to analyze.py, you can pass it:
        # gamma_args="$gamma_args --gamma-cmap \"$GAMMA_CMAP\""
      fi

      # -------- baseline args (only if baseline exists) --------
      baseline_args=""
      if [[ "$BASELINE" == "1" ]]; then
        # CSV rows are like 'zed_ape_se3.zip' so match using grep for substring
        if grep -q "${baseline_pattern}" "$sample_csv"; then
          baseline_args="--baseline-pattern \"$baseline_pattern\" --baseline-ref \"$BASELINE_REF\""
        else
          # also allow '.zip' suffixed keys (common in your CSVs)
          if grep -q "${baseline_pattern}\.zip" "$sample_csv"; then
            baseline_args="--baseline-pattern \"$baseline_pattern\" --baseline-ref \"$BASELINE_REF\""
          fi
        fi
      fi

      # One command per line
      echo "docker run --rm -i $ENV_MPL \
        -v \"$PWD:/work\" -w /work --entrypoint python3 \"$IMAGE\" \"$ANALYZE\" \
        --files ${inputs[*]} \
        --pattern \"$pattern\" \
        --metric \"$m\" \
        --outdir \"$outdir\" \
        --allow-contains \
        $baseline_args \
        $surface_args \
        $gamma_args" >> "$jobs_file"
    done
  done
done

# Parallel execute lines as shell commands
cat "$jobs_file" | xargs -P "$JOBS" -I{} bash -lc "{}"

echo "[OK] Done (xargs -P). Outputs in ./out/"

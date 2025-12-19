#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

# -----------------------------
# Metrics to extract
# -----------------------------
metrics=(rmse mean median std min max sse)

# -----------------------------
# File variant → suffix mapping
# -----------------------------
# format: "csv_basename:suffix"
variants=(
  "metrics_aligned_se3:se3"
  "metrics_aligned_sim3:sim3"
  "metrics_raw:raw"
)

# -----------------------------
# Base patterns (without suffix)
# -----------------------------
patterns=(
#  "zed_ape"
#  "zed_rpe_1m"
#  "zed_rpe_1s"
#  "zed_rpe_50m"
#  "zed_rpe_100m"
#  "zed_rpe_200m"
#  "zed_rpe_300m"
#  "zed_rpe_400m"
#  "zed_rpe_500m"
#  "zed_rpe_600m"
#  "zed_rpe_700m"
#  "zed_yaw_50m"

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
JOBS="${JOBS:-$(nproc)}"
mkdir -p out

jobs_file="$(mktemp)"
trap 'rm -f "$jobs_file"' EXIT

for v in "${variants[@]}"; do
  IFS=":" read -r file suffix <<< "$v"

  inputs=( */outputs/"${file}.csv" )
  (( ${#inputs[@]} == 0 )) && continue

  for p in "${patterns[@]}"; do
    pattern="${p}_${suffix}"

    for m in "${metrics[@]}"; do
#      outdir="out"
      outdir="out/${file}/${pattern}/${m}"
      mkdir -p "$outdir"

      # One command per line
      echo "docker run --rm -i \-v \"$PWD:/work\" -w /work --entrypoint python3 \"$IMAGE\" \"$ANALYZE\" --files ${inputs[*]} --pattern \"$pattern\" --metric \"$m\" --outdir \"$outdir\"" \
        >> "$jobs_file"
    done
  done
done

# Parallel execute lines as shell commands
cat "$jobs_file" | xargs -P "$JOBS" -I{} bash -lc "{}"

echo "[OK] Done (xargs -P). Outputs in ./out/"

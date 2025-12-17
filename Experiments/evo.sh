#!/bin/bash
#set -euo pipefail
#
#: "${OUT_FOLDER:?Need OUT_FOLDER}"
#: "${GT_ODOM_BAG_FILE:?Need GT_ODOM_BAG_FILE}"
#: "${ZED_ODOM_BAG_FILE:?Need ZED_ODOM_BAG_FILE}"
#: "${PG_ODOM_BAG_FILE:?Need PG_ODOM_BAG_FILE}"

rm -rf "$OUT_FOLDER"
mkdir -p "$OUT_FOLDER"
cd "$OUT_FOLDER"

evo_config set plot_backend Agg

# -----------------------------
# Export TUM
# -----------------------------
evo_traj bag $GT_ODOM_BAG_FILE  /gps/fix/odometry   --save_as_tum
evo_traj bag $ZED_ODOM_BAG_FILE /zed/rtabmap/odom   --save_as_tum
evo_traj bag $PG_ODOM_BAG_FILE  /pg/rtabmap/odom    --save_as_tum

GT=gps_fix_odometry.tum
ZED=zed_rtabmap_odom.tum
PG=pg_rtabmap_odom.tum

TMAX=0.05

# ============================================================
# 1) RAW (no alignment)  -> preserves original start / frame
# ============================================================
mkdir -p raw
pushd raw >/dev/null

# APE (SE3-ish, but NO alignment applied)
evo_ape tum ../$GT ../$ZED --t_max_diff $TMAX --save_results zed_ape_raw.zip
evo_ape tum ../$GT ../$PG  --t_max_diff $TMAX --save_results pg_ape_raw.zip

# RPE translations at multiple distances (NO alignment)
evo_rpe tum ../$GT ../$ZED -r trans_part -d 1  -u m --pairs_from_reference --t_max_diff $TMAX --save_results zed_rpe_1m_raw.zip
evo_rpe tum ../$GT ../$PG  -r trans_part -d 1  -u m --pairs_from_reference --t_max_diff $TMAX --save_results pg_rpe_1m_raw.zip

evo_rpe tum ../$GT ../$ZED -r trans_part -d 50 -u m --pairs_from_reference --t_max_diff $TMAX --save_results zed_rpe_50m_raw.zip
evo_rpe tum ../$GT ../$PG  -r trans_part -d 50 -u m --pairs_from_reference --t_max_diff $TMAX --save_results pg_rpe_50m_raw.zip

evo_rpe tum ../$GT ../$ZED -r angle_deg  -d 50 -u m --pairs_from_reference --t_max_diff $TMAX --save_results zed_yaw_50m_raw.zip
evo_rpe tum ../$GT ../$PG  -r angle_deg  -d 50 -u m --pairs_from_reference --t_max_diff $TMAX --save_results pg_yaw_50m_raw.zip

for L in 100 200 300 400 500 600 700 800; do
  evo_rpe tum ../$GT ../$ZED -r trans_part -d $L -u m --pairs_from_reference --t_max_diff $TMAX --save_results zed_rpe_${L}m_raw.zip
  evo_rpe tum ../$GT ../$PG  -r trans_part -d $L -u m --pairs_from_reference --t_max_diff $TMAX --save_results pg_rpe_${L}m_raw.zip
done

# (Optional) 1-second-ish by frame distance (NO alignment)
# You should replace 20 with (approx 1 / median_dt) of YOUR dataset
evo_rpe tum ../$GT ../$ZED -r trans_part -d 20 -u f --t_max_diff $TMAX --save_results zed_rpe_1s_raw.zip
evo_rpe tum ../$GT ../$PG  -r trans_part -d 20 -u f --t_max_diff $TMAX --save_results pg_rpe_1s_raw.zip

# Summarize RAW metrics
evo_res zed_*_raw.zip pg_*_raw.zip --use_filenames --ignore_title --save_table ../metrics_raw.csv

# RAW XY plots (no -a, so they show "as is")
evo_traj tum ../$ZED --ref ../$GT --plot --plot_mode xy --save_plot ../zed_vs_gt_xy_raw.png
evo_traj tum ../$PG  --ref ../$GT --plot --plot_mode xy --save_plot ../pg_vs_gt_xy_raw.png
evo_traj tum ../$ZED ../$PG --ref ../$GT --plot --plot_mode xy --save_plot ../both_vs_gt_xy_raw.png

popd >/dev/null

# ============================================================
# 2) ALIGNED (best fit) -> compares shape quality
#    2a) SE3 alignment
# ============================================================
mkdir -p aligned_se3
pushd aligned_se3 >/dev/null

# APE SE3 aligned (-a)
evo_ape tum ../$GT ../$ZED -a --t_max_diff $TMAX --save_results zed_ape_se3.zip
evo_ape tum ../$GT ../$PG  -a --t_max_diff $TMAX --save_results pg_ape_se3.zip

# RPE aligned (-a) (kept consistent with your previous approach)
evo_rpe tum ../$GT ../$ZED -a -r trans_part -d 1  -u m --pairs_from_reference --t_max_diff $TMAX --save_results zed_rpe_1m_se3.zip
evo_rpe tum ../$GT ../$PG  -a -r trans_part -d 1  -u m --pairs_from_reference --t_max_diff $TMAX --save_results pg_rpe_1m_se3.zip

evo_rpe tum ../$GT ../$ZED -a -r trans_part -d 50 -u m --pairs_from_reference --t_max_diff $TMAX --save_results zed_rpe_50m_se3.zip
evo_rpe tum ../$GT ../$PG  -a -r trans_part -d 50 -u m --pairs_from_reference --t_max_diff $TMAX --save_results pg_rpe_50m_se3.zip

evo_rpe tum ../$GT ../$ZED -a -r angle_deg  -d 50 -u m --pairs_from_reference --t_max_diff $TMAX --save_results zed_yaw_50m_se3.zip
evo_rpe tum ../$GT ../$PG  -a -r angle_deg  -d 50 -u m --pairs_from_reference --t_max_diff $TMAX --save_results pg_yaw_50m_se3.zip

for L in 100 200 300 400 500 600 700 800; do
  evo_rpe tum ../$GT ../$ZED -a -r trans_part -d $L -u m --pairs_from_reference --t_max_diff $TMAX --save_results zed_rpe_${L}m_se3.zip
  evo_rpe tum ../$GT ../$PG  -a -r trans_part -d $L -u m --pairs_from_reference --t_max_diff $TMAX --save_results pg_rpe_${L}m_se3.zip
done

evo_rpe tum ../$GT ../$ZED -a -r trans_part -d 20 -u f --t_max_diff $TMAX --save_results zed_rpe_1s_se3.zip
evo_rpe tum ../$GT ../$PG  -a -r trans_part -d 20 -u f --t_max_diff $TMAX --save_results pg_rpe_1s_se3.zip

evo_res zed_*_se3.zip pg_*_se3.zip --use_filenames --ignore_title --save_table ../metrics_aligned_se3.csv

# ALIGNED XY plots (these will best-fit, so starts may shift)
evo_traj tum ../$ZED --ref ../$GT -a --plot --plot_mode xy --save_plot ../zed_vs_gt_xy_aligned_se3.png
evo_traj tum ../$PG  --ref ../$GT -a --plot --plot_mode xy --save_plot ../pg_vs_gt_xy_aligned_se3.png
evo_traj tum ../$ZED ../$PG --ref ../$GT -a --plot --plot_mode xy --save_plot ../both_vs_gt_xy_aligned_se3.png

popd >/dev/null

# ============================================================
# 2b) SIM3 alignment (SE3 + scale) -> when scale drift exists
# ============================================================
mkdir -p aligned_sim3
pushd aligned_sim3 >/dev/null

evo_ape tum ../$GT ../$ZED -a -s --t_max_diff $TMAX --save_results zed_ape_sim3.zip
evo_ape tum ../$GT ../$PG  -a -s --t_max_diff $TMAX --save_results pg_ape_sim3.zip

# RPE typically doesn't need scale correction; keep -a only
# (If you *really* want scale alignment everywhere, you can add -s where supported.)
evo_rpe tum ../$GT ../$ZED -a -r trans_part -d 50 -u m --pairs_from_reference --t_max_diff $TMAX --save_results zed_rpe_50m_sim3.zip
evo_rpe tum ../$GT ../$PG  -a -r trans_part -d 50 -u m --pairs_from_reference --t_max_diff $TMAX --save_results pg_rpe_50m_sim3.zip

evo_res zed_*_sim3.zip pg_*_sim3.zip --use_filenames --ignore_title --save_table ../metrics_aligned_sim3.csv

popd >/dev/null

echo "Done."
echo "CSV outputs:"
echo "  - $OUT_FOLDER/metrics_raw.csv"
echo "  - $OUT_FOLDER/metrics_aligned_se3.csv"
echo "  - $OUT_FOLDER/metrics_aligned_sim3.csv"
echo "Plots:"
echo "  - *_xy_raw.png"
echo "  - *_xy_aligned_se3.png"

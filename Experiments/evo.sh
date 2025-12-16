#!/bin/bash

rm -rf $OUT_FOLDER
mkdir -p $OUT_FOLDER
cd $OUT_FOLDER

evo_traj bag $GT_ODOM_BAG_FILE /gps/fix/odometry --save_as_tum
evo_traj bag $ZED_ODOM_BAG_FILE /zed/rtabmap/odom --save_as_tum
evo_traj bag $PG_ODOM_BAG_FILE /pg/rtabmap/odom --save_as_tum
evo_config set plot_backend Agg
GT=gps_fix_odometry.tum
ZED=zed_rtabmap_odom.tum
PG=pg_rtabmap_odom.tum
TMAX=0.05
evo_ape tum $GT $ZED -a -s --t_max_diff $TMAX --save_results zed_ape_sim3.zip
evo_ape tum $GT $PG  -a -s --t_max_diff $TMAX --save_results pg_ape_sim3.zip
evo_ape tum $GT $ZED -a     --t_max_diff $TMAX --save_results zed_ape_se3.zip
evo_ape tum $GT $PG  -a     --t_max_diff $TMAX --save_results pg_ape_se3.zip
evo_rpe tum $GT $ZED -a -r trans_part -d 1  -u m --pairs_from_reference --t_max_diff $TMAX --save_results zed_rpe_1m.zip
evo_rpe tum $GT $PG  -a -r trans_part -d 1  -u m --pairs_from_reference --t_max_diff $TMAX --save_results pg_rpe_1m.zip
evo_rpe tum $GT $ZED -a -r trans_part -d 50 -u m --pairs_from_reference --t_max_diff $TMAX --save_results zed_rpe_50m.zip
evo_rpe tum $GT $PG  -a -r trans_part -d 50 -u m --pairs_from_reference --t_max_diff $TMAX --save_results pg_rpe_50m.zip
evo_rpe tum $GT $ZED -a -r angle_deg -d 50 -u m --pairs_from_reference --t_max_diff $TMAX --save_results zed_yaw_50m.zip
evo_rpe tum $GT $PG  -a -r angle_deg -d 50 -u m --pairs_from_reference --t_max_diff $TMAX --save_results pg_yaw_50m.zip
for L in 100 200 300 400 500 600 700 800; do
  evo_rpe tum $GT $ZED -a -r trans_part -d $L -u m --pairs_from_reference --t_max_diff $TMAX --save_results zed_rpe_${L}m.zip
  evo_rpe tum $GT $PG  -a -r trans_part -d $L -u m --pairs_from_reference --t_max_diff $TMAX --save_results pg_rpe_${L}m.zip
done
# Find the median dt first:
evo_traj tum $ZED --full_check   # note the median dt => N ≈ 1/dt
# Example for ~20 Hz:
evo_rpe tum $GT $ZED -a -r trans_part -d 20 -u f --t_max_diff $TMAX --save_results zed_rpe_~1s.zip
evo_rpe tum $GT $PG  -a -r trans_part -d 20 -u f --t_max_diff $TMAX --save_results pg_rpe_~1s.zip
evo_res zed_*.zip pg_*.zip --use_filenames --save_table metrics_all.csv
# Plot XY
evo_traj tum $ZED --ref $GT -a --plot --plot_mode xy --save_plot zed_vs_gt_xy.png
evo_traj tum $PG  --ref $GT -a --plot --plot_mode xy --save_plot pg_vs_gt_xy.png
evo_traj tum $ZED $PG --ref $GT -a --plot --plot_mode xy --save_plot both_vs_gt_xy.png
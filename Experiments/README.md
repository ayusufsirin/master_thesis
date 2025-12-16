# ZED

# PG

| PG Iterations \ LU History | 0     | 2     | 5     | 10     | 
|----------------------------|-------|-------|-------|--------|
| 0                          | 0_0   | 0_2   | 0_5   | 0_10   |
| 10                         | 10_0  | 10_2  | 10_5  | 10_10  |
| 33                         | 33_0  | 33_2  | 33_5  | 33_10  |
| 100                        | 100_0 | 100_2 | 100_5 | 100_10 |

# 10_10

PARAMETERS
 * /lidar_upsample/odom_topic: /jackal_velocity_...
 * /lidar_upsample/pc_history_size: 10
 * /lidar_upsample/pc_topic: /velodyne_points
 * /lidar_upsample/point_cloud_cumulative: /cumulative_point...
 * /lidar_upsample/point_cloud_cumulative_origin: /cumulative_origi...
 * /lidar_upsample/point_cloud_transformed: /transformed_poin...
 * /lidar_upsample/publish_subtopics: True
 * /odom_to_tf/base_frame: base_link
 * /odom_to_tf/mode: predict
 * /odom_to_tf/odom_frame: odom
 * /odom_to_tf/odom_topic: /jackal_velocity_...
 * /odom_to_tf/rate_hz: 200.0
 * /papoulish_gerchberg/butterworth_order: 3
 * /papoulish_gerchberg/current_ncutoff: 0.16
 * /papoulish_gerchberg/current_ncutoff_h: 0.08
 * /papoulish_gerchberg/current_ncutoff_l: 0.08
 * /papoulish_gerchberg/current_threshold: 10
 * /papoulish_gerchberg/filter_type: gaussian
 * /papoulish_gerchberg/mortal_columns_left: 70
 * /papoulish_gerchberg/mortal_columns_right: 10
 * /papoulish_gerchberg/mortal_rows_bottom: 320
 * /papoulish_gerchberg/mortal_rows_top: 250
 * /papoulish_gerchberg/odom_topic: /jackal_velocity_...
 * /papoulish_gerchberg/pg_camera_info_topic: /islam/pg_camera_...
 * /papoulish_gerchberg/pg_depth_topic: /islam/pg_depth
 * /papoulish_gerchberg/pg_fused_pc_topic: /islam/pg_fused_p...
 * /papoulish_gerchberg/pg_odom_topic: /islam/pg_odom
 * /papoulish_gerchberg/pg_rgb_topic: /islam/pg_rgb
 * /papoulish_gerchberg/vlp_debug_pc_topic: /islam/vlp_debug_...
 * /papoulish_gerchberg/vlp_depth_topic: /islam/vlp_depth
 * /papoulish_gerchberg/vlp_filtered_pc_topic: /islam/vlp_filter...
 * /papoulish_gerchberg/vlp_topic: /cumulative_origi...
 * /papoulish_gerchberg/zed_camera_info_topic: /zed2i/zed_node/d...
 * /papoulish_gerchberg/zed_depth_topic: /zed2i/zed_node/d...
 * /papoulish_gerchberg/zed_original_pc_topic: /islam/zed_origin...
 * /papoulish_gerchberg/zed_pc_topic: /islam/zed_pointc...
 * /papoulish_gerchberg/zed_rgb_topic: /zed2i/zed_node/l...
 * /papoulish_gerchberg/zed_vlp_diff_max: 50.0
 * /pg/rtabmap/rgbd_odometry/Odom/AlignWithGround: false
 * /pg/rtabmap/rgbd_odometry/Odom/Strategy: 1
 * /pg/rtabmap/rgbd_odometry/OdomF2M/KeyFrameThr: 0.3
 * /pg/rtabmap/rgbd_odometry/Vis/CorNNDR: 0.7
 * /pg/rtabmap/rgbd_odometry/Vis/FeatureType: 2
 * /pg/rtabmap/rgbd_odometry/Vis/MaxFeatures: 2000
 * /pg/rtabmap/rgbd_odometry/Vis/MinInliers: 10
 * /pg/rtabmap/rgbd_odometry/approx_sync: True
 * /pg/rtabmap/rgbd_odometry/approx_sync_max_interval: 0.05
 * /pg/rtabmap/rgbd_odometry/config_path: 
 * /pg/rtabmap/rgbd_odometry/expected_update_rate: 0.0
 * /pg/rtabmap/rgbd_odometry/frame_id: base_link
 * /pg/rtabmap/rgbd_odometry/ground_truth_base_frame_id: 
 * /pg/rtabmap/rgbd_odometry/ground_truth_frame_id: 
 * /pg/rtabmap/rgbd_odometry/guess_frame_id: 
 * /pg/rtabmap/rgbd_odometry/guess_min_rotation: 0.0
 * /pg/rtabmap/rgbd_odometry/guess_min_translation: 0.0
 * /pg/rtabmap/rgbd_odometry/keep_color: False
 * /pg/rtabmap/rgbd_odometry/max_update_rate: 0.0
 * /pg/rtabmap/rgbd_odometry/odom_frame_id: odom
 * /pg/rtabmap/rgbd_odometry/publish_tf: False
 * /pg/rtabmap/rgbd_odometry/subscribe_rgbd: False
 * /pg/rtabmap/rgbd_odometry/sync_queue_size: 10
 * /pg/rtabmap/rgbd_odometry/topic_queue_size: 1
 * /pg/rtabmap/rgbd_odometry/wait_for_transform_duration: 0.2
 * /pg/rtabmap/rgbd_odometry/wait_imu_to_init: False
 * /pg/rtabmap/rtabmap/Mem/IncrementalMemory: true
 * /pg/rtabmap/rtabmap/Mem/InitWMWithAllNodes: false
 * /pg/rtabmap/rtabmap/approx_sync: True
 * /pg/rtabmap/rtabmap/config_path: 
 * /pg/rtabmap/rtabmap/database_path: ~/.ros/rtabmap.db
 * /pg/rtabmap/rtabmap/frame_id: base_link
 * /pg/rtabmap/rtabmap/gen_depth: False
 * /pg/rtabmap/rtabmap/gen_depth_decimation: 1
 * /pg/rtabmap/rtabmap/gen_depth_fill_holes_error: 0.1
 * /pg/rtabmap/rtabmap/gen_depth_fill_holes_size: 0
 * /pg/rtabmap/rtabmap/gen_depth_fill_iterations: 1
 * /pg/rtabmap/rtabmap/gen_scan: False
 * /pg/rtabmap/rtabmap/ground_truth_base_frame_id: 
 * /pg/rtabmap/rtabmap/ground_truth_frame_id: 
 * /pg/rtabmap/rtabmap/initial_pose: 
 * /pg/rtabmap/rtabmap/landmark_angular_variance: 9999.0
 * /pg/rtabmap/rtabmap/landmark_linear_variance: 0.0001
 * /pg/rtabmap/rtabmap/loc_thr: 0.0
 * /pg/rtabmap/rtabmap/map_frame_id: map
 * /pg/rtabmap/rtabmap/odom_frame_id: odom
 * /pg/rtabmap/rtabmap/odom_frame_id_init: 
 * /pg/rtabmap/rtabmap/odom_sensor_sync: False
 * /pg/rtabmap/rtabmap/odom_tf_angular_variance: 0.001
 * /pg/rtabmap/rtabmap/odom_tf_linear_variance: 0.001
 * /pg/rtabmap/rtabmap/publish_tf: False
 * /pg/rtabmap/rtabmap/scan_cloud_max_points: 0
 * /pg/rtabmap/rtabmap/subscribe_depth: True
 * /pg/rtabmap/rtabmap/subscribe_odom_info: True
 * /pg/rtabmap/rtabmap/subscribe_rgb: True
 * /pg/rtabmap/rtabmap/subscribe_rgbd: False
 * /pg/rtabmap/rtabmap/subscribe_scan: False
 * /pg/rtabmap/rtabmap/subscribe_scan_cloud: False
 * /pg/rtabmap/rtabmap/subscribe_scan_descriptor: False
 * /pg/rtabmap/rtabmap/subscribe_stereo: False
 * /pg/rtabmap/rtabmap/subscribe_user_data: False
 * /pg/rtabmap/rtabmap/sync_queue_size: 10
 * /pg/rtabmap/rtabmap/topic_queue_size: 1
 * /pg/rtabmap/rtabmap/wait_for_transform_duration: 0.2
 * /pg/rtabmap/rtabmap_viz/approx_sync: True
 * /pg/rtabmap/rtabmap_viz/frame_id: base_link
 * /pg/rtabmap/rtabmap_viz/odom_frame_id: odom
 * /pg/rtabmap/rtabmap_viz/subscribe_depth: True
 * /pg/rtabmap/rtabmap_viz/subscribe_odom_info: True
 * /pg/rtabmap/rtabmap_viz/subscribe_rgb: True
 * /pg/rtabmap/rtabmap_viz/subscribe_rgbd: False
 * /pg/rtabmap/rtabmap_viz/subscribe_scan: False
 * /pg/rtabmap/rtabmap_viz/subscribe_scan_cloud: False
 * /pg/rtabmap/rtabmap_viz/subscribe_scan_descriptor: False
 * /pg/rtabmap/rtabmap_viz/subscribe_stereo: False
 * /pg/rtabmap/rtabmap_viz/sync_queue_size: 10
 * /pg/rtabmap/rtabmap_viz/topic_queue_size: 1
 * /pg/rtabmap/rtabmap_viz/wait_for_transform_duration: 0.2
 * /pg/use_sim_time: True
 * /rosdistro: noetic
 * /rosversion: 1.17.4
 * /use_sim_time: True

# 0_10

PARAMETERS
 * /lidar_upsample/odom_topic: /jackal_velocity_...
 * /lidar_upsample/pc_history_size: 10
 * /lidar_upsample/pc_topic: /velodyne_points
 * /lidar_upsample/point_cloud_cumulative: /cumulative_point...
 * /lidar_upsample/point_cloud_cumulative_origin: /cumulative_origi...
 * /lidar_upsample/point_cloud_transformed: /transformed_poin...
 * /lidar_upsample/publish_subtopics: True
 * /odom_to_tf/base_frame: base_link
 * /odom_to_tf/mode: predict
 * /odom_to_tf/odom_frame: odom
 * /odom_to_tf/odom_topic: /jackal_velocity_...
 * /odom_to_tf/rate_hz: 200.0
 * /papoulish_gerchberg/butterworth_order: 3
 * /papoulish_gerchberg/current_ncutoff: 0.16
 * /papoulish_gerchberg/current_ncutoff_h: 0.08
 * /papoulish_gerchberg/current_ncutoff_l: 0.08
 * /papoulish_gerchberg/current_threshold: 0
 * /papoulish_gerchberg/filter_type: gaussian
 * /papoulish_gerchberg/mortal_columns_left: 70
 * /papoulish_gerchberg/mortal_columns_right: 10
 * /papoulish_gerchberg/mortal_rows_bottom: 320
 * /papoulish_gerchberg/mortal_rows_top: 250
 * /papoulish_gerchberg/odom_topic: /jackal_velocity_...
 * /papoulish_gerchberg/pg_camera_info_topic: /islam/pg_camera_...
 * /papoulish_gerchberg/pg_depth_topic: /islam/pg_depth
 * /papoulish_gerchberg/pg_fused_pc_topic: /islam/pg_fused_p...
 * /papoulish_gerchberg/pg_odom_topic: /islam/pg_odom
 * /papoulish_gerchberg/pg_rgb_topic: /islam/pg_rgb
 * /papoulish_gerchberg/vlp_debug_pc_topic: /islam/vlp_debug_...
 * /papoulish_gerchberg/vlp_depth_topic: /islam/vlp_depth
 * /papoulish_gerchberg/vlp_filtered_pc_topic: /islam/vlp_filter...
 * /papoulish_gerchberg/vlp_topic: /cumulative_origi...
 * /papoulish_gerchberg/zed_camera_info_topic: /zed2i/zed_node/d...
 * /papoulish_gerchberg/zed_depth_topic: /zed2i/zed_node/d...
 * /papoulish_gerchberg/zed_original_pc_topic: /islam/zed_origin...
 * /papoulish_gerchberg/zed_pc_topic: /islam/zed_pointc...
 * /papoulish_gerchberg/zed_rgb_topic: /zed2i/zed_node/l...
 * /papoulish_gerchberg/zed_vlp_diff_max: 50.0
 * /pg/rtabmap/rgbd_odometry/Odom/AlignWithGround: false
 * /pg/rtabmap/rgbd_odometry/Odom/Strategy: 1
 * /pg/rtabmap/rgbd_odometry/OdomF2M/KeyFrameThr: 0.3
 * /pg/rtabmap/rgbd_odometry/Vis/CorNNDR: 0.7
 * /pg/rtabmap/rgbd_odometry/Vis/FeatureType: 2
 * /pg/rtabmap/rgbd_odometry/Vis/MaxFeatures: 2000
 * /pg/rtabmap/rgbd_odometry/Vis/MinInliers: 10
 * /pg/rtabmap/rgbd_odometry/approx_sync: True
 * /pg/rtabmap/rgbd_odometry/approx_sync_max_interval: 0.05
 * /pg/rtabmap/rgbd_odometry/config_path: 
 * /pg/rtabmap/rgbd_odometry/expected_update_rate: 0.0
 * /pg/rtabmap/rgbd_odometry/frame_id: base_link
 * /pg/rtabmap/rgbd_odometry/ground_truth_base_frame_id: 
 * /pg/rtabmap/rgbd_odometry/ground_truth_frame_id: 
 * /pg/rtabmap/rgbd_odometry/guess_frame_id: 
 * /pg/rtabmap/rgbd_odometry/guess_min_rotation: 0.0
 * /pg/rtabmap/rgbd_odometry/guess_min_translation: 0.0
 * /pg/rtabmap/rgbd_odometry/keep_color: False
 * /pg/rtabmap/rgbd_odometry/max_update_rate: 0.0
 * /pg/rtabmap/rgbd_odometry/odom_frame_id: odom
 * /pg/rtabmap/rgbd_odometry/publish_tf: False
 * /pg/rtabmap/rgbd_odometry/subscribe_rgbd: False
 * /pg/rtabmap/rgbd_odometry/sync_queue_size: 10
 * /pg/rtabmap/rgbd_odometry/topic_queue_size: 1
 * /pg/rtabmap/rgbd_odometry/wait_for_transform_duration: 0.2
 * /pg/rtabmap/rgbd_odometry/wait_imu_to_init: False
 * /pg/rtabmap/rtabmap/Mem/IncrementalMemory: true
 * /pg/rtabmap/rtabmap/Mem/InitWMWithAllNodes: false
 * /pg/rtabmap/rtabmap/approx_sync: True
 * /pg/rtabmap/rtabmap/config_path: 
 * /pg/rtabmap/rtabmap/database_path: ~/.ros/rtabmap.db
 * /pg/rtabmap/rtabmap/frame_id: base_link
 * /pg/rtabmap/rtabmap/gen_depth: False
 * /pg/rtabmap/rtabmap/gen_depth_decimation: 1
 * /pg/rtabmap/rtabmap/gen_depth_fill_holes_error: 0.1
 * /pg/rtabmap/rtabmap/gen_depth_fill_holes_size: 0
 * /pg/rtabmap/rtabmap/gen_depth_fill_iterations: 1
 * /pg/rtabmap/rtabmap/gen_scan: False
 * /pg/rtabmap/rtabmap/ground_truth_base_frame_id: 
 * /pg/rtabmap/rtabmap/ground_truth_frame_id: 
 * /pg/rtabmap/rtabmap/initial_pose: 
 * /pg/rtabmap/rtabmap/landmark_angular_variance: 9999.0
 * /pg/rtabmap/rtabmap/landmark_linear_variance: 0.0001
 * /pg/rtabmap/rtabmap/loc_thr: 0.0
 * /pg/rtabmap/rtabmap/map_frame_id: map
 * /pg/rtabmap/rtabmap/odom_frame_id: odom
 * /pg/rtabmap/rtabmap/odom_frame_id_init: 
 * /pg/rtabmap/rtabmap/odom_sensor_sync: False
 * /pg/rtabmap/rtabmap/odom_tf_angular_variance: 0.001
 * /pg/rtabmap/rtabmap/odom_tf_linear_variance: 0.001
 * /pg/rtabmap/rtabmap/publish_tf: False
 * /pg/rtabmap/rtabmap/scan_cloud_max_points: 0
 * /pg/rtabmap/rtabmap/subscribe_depth: True
 * /pg/rtabmap/rtabmap/subscribe_odom_info: True
 * /pg/rtabmap/rtabmap/subscribe_rgb: True
 * /pg/rtabmap/rtabmap/subscribe_rgbd: False
 * /pg/rtabmap/rtabmap/subscribe_scan: False
 * /pg/rtabmap/rtabmap/subscribe_scan_cloud: False
 * /pg/rtabmap/rtabmap/subscribe_scan_descriptor: False
 * /pg/rtabmap/rtabmap/subscribe_stereo: False
 * /pg/rtabmap/rtabmap/subscribe_user_data: False
 * /pg/rtabmap/rtabmap/sync_queue_size: 10
 * /pg/rtabmap/rtabmap/topic_queue_size: 1
 * /pg/rtabmap/rtabmap/wait_for_transform_duration: 0.2
 * /pg/rtabmap/rtabmap_viz/approx_sync: True
 * /pg/rtabmap/rtabmap_viz/frame_id: base_link
 * /pg/rtabmap/rtabmap_viz/odom_frame_id: odom
 * /pg/rtabmap/rtabmap_viz/subscribe_depth: True
 * /pg/rtabmap/rtabmap_viz/subscribe_odom_info: True
 * /pg/rtabmap/rtabmap_viz/subscribe_rgb: True
 * /pg/rtabmap/rtabmap_viz/subscribe_rgbd: False
 * /pg/rtabmap/rtabmap_viz/subscribe_scan: False
 * /pg/rtabmap/rtabmap_viz/subscribe_scan_cloud: False
 * /pg/rtabmap/rtabmap_viz/subscribe_scan_descriptor: False
 * /pg/rtabmap/rtabmap_viz/subscribe_stereo: False
 * /pg/rtabmap/rtabmap_viz/sync_queue_size: 10
 * /pg/rtabmap/rtabmap_viz/topic_queue_size: 1
 * /pg/rtabmap/rtabmap_viz/wait_for_transform_duration: 0.2
 * /pg/use_sim_time: True
 * /rosdistro: noetic
 * /rosversion: 1.17.4
 * /use_sim_time: True

# 33_10

PARAMETERS
 * /lidar_upsample/odom_topic: /jackal_velocity_...
 * /lidar_upsample/pc_history_size: 10
 * /lidar_upsample/pc_topic: /velodyne_points
 * /lidar_upsample/point_cloud_cumulative: /cumulative_point...
 * /lidar_upsample/point_cloud_cumulative_origin: /cumulative_origi...
 * /lidar_upsample/point_cloud_transformed: /transformed_poin...
 * /lidar_upsample/publish_subtopics: True
 * /odom_to_tf/base_frame: base_link
 * /odom_to_tf/mode: predict
 * /odom_to_tf/odom_frame: odom
 * /odom_to_tf/odom_topic: /jackal_velocity_...
 * /odom_to_tf/rate_hz: 200.0
 * /papoulish_gerchberg/butterworth_order: 3
 * /papoulish_gerchberg/current_ncutoff: 0.16
 * /papoulish_gerchberg/current_ncutoff_h: 0.08
 * /papoulish_gerchberg/current_ncutoff_l: 0.08
 * /papoulish_gerchberg/current_threshold: 33
 * /papoulish_gerchberg/filter_type: gaussian
 * /papoulish_gerchberg/mortal_columns_left: 70
 * /papoulish_gerchberg/mortal_columns_right: 10
 * /papoulish_gerchberg/mortal_rows_bottom: 320
 * /papoulish_gerchberg/mortal_rows_top: 250
 * /papoulish_gerchberg/odom_topic: /jackal_velocity_...
 * /papoulish_gerchberg/pg_camera_info_topic: /islam/pg_camera_...
 * /papoulish_gerchberg/pg_depth_topic: /islam/pg_depth
 * /papoulish_gerchberg/pg_fused_pc_topic: /islam/pg_fused_p...
 * /papoulish_gerchberg/pg_odom_topic: /islam/pg_odom
 * /papoulish_gerchberg/pg_rgb_topic: /islam/pg_rgb
 * /papoulish_gerchberg/vlp_debug_pc_topic: /islam/vlp_debug_...
 * /papoulish_gerchberg/vlp_depth_topic: /islam/vlp_depth
 * /papoulish_gerchberg/vlp_filtered_pc_topic: /islam/vlp_filter...
 * /papoulish_gerchberg/vlp_topic: /cumulative_origi...
 * /papoulish_gerchberg/zed_camera_info_topic: /zed2i/zed_node/d...
 * /papoulish_gerchberg/zed_depth_topic: /zed2i/zed_node/d...
 * /papoulish_gerchberg/zed_original_pc_topic: /islam/zed_origin...
 * /papoulish_gerchberg/zed_pc_topic: /islam/zed_pointc...
 * /papoulish_gerchberg/zed_rgb_topic: /zed2i/zed_node/l...
 * /papoulish_gerchberg/zed_vlp_diff_max: 50.0
 * /pg/rtabmap/rgbd_odometry/Odom/AlignWithGround: false
 * /pg/rtabmap/rgbd_odometry/Odom/Strategy: 1
 * /pg/rtabmap/rgbd_odometry/OdomF2M/KeyFrameThr: 0.3
 * /pg/rtabmap/rgbd_odometry/Vis/CorNNDR: 0.7
 * /pg/rtabmap/rgbd_odometry/Vis/FeatureType: 2
 * /pg/rtabmap/rgbd_odometry/Vis/MaxFeatures: 2000
 * /pg/rtabmap/rgbd_odometry/Vis/MinInliers: 10
 * /pg/rtabmap/rgbd_odometry/approx_sync: True
 * /pg/rtabmap/rgbd_odometry/approx_sync_max_interval: 0.05
 * /pg/rtabmap/rgbd_odometry/config_path: 
 * /pg/rtabmap/rgbd_odometry/expected_update_rate: 0.0
 * /pg/rtabmap/rgbd_odometry/frame_id: base_link
 * /pg/rtabmap/rgbd_odometry/ground_truth_base_frame_id: 
 * /pg/rtabmap/rgbd_odometry/ground_truth_frame_id: 
 * /pg/rtabmap/rgbd_odometry/guess_frame_id: 
 * /pg/rtabmap/rgbd_odometry/guess_min_rotation: 0.0
 * /pg/rtabmap/rgbd_odometry/guess_min_translation: 0.0
 * /pg/rtabmap/rgbd_odometry/keep_color: False
 * /pg/rtabmap/rgbd_odometry/max_update_rate: 0.0
 * /pg/rtabmap/rgbd_odometry/odom_frame_id: odom
 * /pg/rtabmap/rgbd_odometry/publish_tf: False
 * /pg/rtabmap/rgbd_odometry/subscribe_rgbd: False
 * /pg/rtabmap/rgbd_odometry/sync_queue_size: 10
 * /pg/rtabmap/rgbd_odometry/topic_queue_size: 1
 * /pg/rtabmap/rgbd_odometry/wait_for_transform_duration: 0.2
 * /pg/rtabmap/rgbd_odometry/wait_imu_to_init: False
 * /pg/rtabmap/rtabmap/Mem/IncrementalMemory: true
 * /pg/rtabmap/rtabmap/Mem/InitWMWithAllNodes: false
 * /pg/rtabmap/rtabmap/approx_sync: True
 * /pg/rtabmap/rtabmap/config_path: 
 * /pg/rtabmap/rtabmap/database_path: ~/.ros/rtabmap.db
 * /pg/rtabmap/rtabmap/frame_id: base_link
 * /pg/rtabmap/rtabmap/gen_depth: False
 * /pg/rtabmap/rtabmap/gen_depth_decimation: 1
 * /pg/rtabmap/rtabmap/gen_depth_fill_holes_error: 0.1
 * /pg/rtabmap/rtabmap/gen_depth_fill_holes_size: 0
 * /pg/rtabmap/rtabmap/gen_depth_fill_iterations: 1
 * /pg/rtabmap/rtabmap/gen_scan: False
 * /pg/rtabmap/rtabmap/ground_truth_base_frame_id: 
 * /pg/rtabmap/rtabmap/ground_truth_frame_id: 
 * /pg/rtabmap/rtabmap/initial_pose: 
 * /pg/rtabmap/rtabmap/landmark_angular_variance: 9999.0
 * /pg/rtabmap/rtabmap/landmark_linear_variance: 0.0001
 * /pg/rtabmap/rtabmap/loc_thr: 0.0
 * /pg/rtabmap/rtabmap/map_frame_id: map
 * /pg/rtabmap/rtabmap/odom_frame_id: odom
 * /pg/rtabmap/rtabmap/odom_frame_id_init: 
 * /pg/rtabmap/rtabmap/odom_sensor_sync: False
 * /pg/rtabmap/rtabmap/odom_tf_angular_variance: 0.001
 * /pg/rtabmap/rtabmap/odom_tf_linear_variance: 0.001
 * /pg/rtabmap/rtabmap/publish_tf: False
 * /pg/rtabmap/rtabmap/scan_cloud_max_points: 0
 * /pg/rtabmap/rtabmap/subscribe_depth: True
 * /pg/rtabmap/rtabmap/subscribe_odom_info: True
 * /pg/rtabmap/rtabmap/subscribe_rgb: True
 * /pg/rtabmap/rtabmap/subscribe_rgbd: False
 * /pg/rtabmap/rtabmap/subscribe_scan: False
 * /pg/rtabmap/rtabmap/subscribe_scan_cloud: False
 * /pg/rtabmap/rtabmap/subscribe_scan_descriptor: False
 * /pg/rtabmap/rtabmap/subscribe_stereo: False
 * /pg/rtabmap/rtabmap/subscribe_user_data: False
 * /pg/rtabmap/rtabmap/sync_queue_size: 10
 * /pg/rtabmap/rtabmap/topic_queue_size: 1
 * /pg/rtabmap/rtabmap/wait_for_transform_duration: 0.2
 * /pg/rtabmap/rtabmap_viz/approx_sync: True
 * /pg/rtabmap/rtabmap_viz/frame_id: base_link
 * /pg/rtabmap/rtabmap_viz/odom_frame_id: odom
 * /pg/rtabmap/rtabmap_viz/subscribe_depth: True
 * /pg/rtabmap/rtabmap_viz/subscribe_odom_info: True
 * /pg/rtabmap/rtabmap_viz/subscribe_rgb: True
 * /pg/rtabmap/rtabmap_viz/subscribe_rgbd: False
 * /pg/rtabmap/rtabmap_viz/subscribe_scan: False
 * /pg/rtabmap/rtabmap_viz/subscribe_scan_cloud: False
 * /pg/rtabmap/rtabmap_viz/subscribe_scan_descriptor: False
 * /pg/rtabmap/rtabmap_viz/subscribe_stereo: False
 * /pg/rtabmap/rtabmap_viz/sync_queue_size: 10
 * /pg/rtabmap/rtabmap_viz/topic_queue_size: 1
 * /pg/rtabmap/rtabmap_viz/wait_for_transform_duration: 0.2
 * /pg/use_sim_time: True
 * /rosdistro: noetic
 * /rosversion: 1.17.4
 * /use_sim_time: True

Avg fusion time: 2.91 ms
Max fusion time: 3.71 ms
Min fusion time: 2.52 ms


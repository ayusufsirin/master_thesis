#!/bin/bash

exps=(
"0_1"
#"0_2"
#"0_5"
#"0_10"
#"10_2"
#"10_5"
#"10_10"
#"33_1"
#"33_2"
#"33_5"
#"33_10"
#"100_1"
#"100_2"
#"100_5"
#"100_10"
)

for exp in "${exps[@]}"
do
    docker run --rm -it \
        -v "$PWD:/work" \
        -w /work \
        -e GT_ODOM_BAG_FILE="/work/gt.bag" \
        -e ZED_ODOM_BAG_FILE="/work/zed*.bag" \
        -e PG_ODOM_BAG_FILE="/work/${exp}/${exp}*.bag" \
        -e OUT_FOLDER="/work/${exp}/outputs" \
        evo-cli evo.sh
done

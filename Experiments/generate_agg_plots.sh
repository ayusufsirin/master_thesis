#!/bin/bash

docker run --rm -it \
    -v "$PWD:/work" \
    -w /work \
    evo-cli \
    agg_plot.sh
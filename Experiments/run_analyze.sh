#!/bin/bash

docker run --rm -it \
    -v "$PWD:/work" \
    -w /work \
    --entrypoint python3 \
    evo-cli analyze.py --files */outputs/metrics_aligned_se3.csv --include "pg_" --pattern "pg_ape_se3" --metric rmse --outdir out

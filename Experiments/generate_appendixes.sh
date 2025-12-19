#!/bin/bash

docker run --rm -it \
    -v "$PWD:/work" \
    -w /work \
    --entrypoint python3 \
    evo-cli \
    appendix_pg_results.py --out_root out --tex_out appendix_pg_results.tex --include_tables
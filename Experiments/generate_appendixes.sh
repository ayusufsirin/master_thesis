#!/bin/bash

docker run --rm -it \
    -v "$PWD:/work" \
    -w /work \
    --entrypoint python3 \
    evo-cli \
    appendix_pg_results.py --out_root out --tex_out appendix_pg_results.tex

docker run --rm -it \
    -v "$PWD:/work" \
    -w /work \
    --entrypoint python3 \
    evo-cli \
    appendix_traj_plots.py \
      --root . \
      --out traj_plots \
      --tex-path appendix_traj_plots.tex \
      --graphics-prefix ./Experiments/ \
      --include-per-run
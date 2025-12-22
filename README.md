```bash
docker build . -t master_latex
```

```bash
docker run --rm -it --privileged --shm-size=1g -v $PWD:/ws/ -w /ws master_latex
```

```bash
latexmk -pdf -gg -interaction=nonstopmode main.tex
```

```bash
latexmk -pdf -interaction=nonstopmode -pvc
```

```bash
latexmk -pdf -interaction=nonstopmode -f -pvc main.tex
```

```bash
mmdc -s 5 -i mermaid/pg.mmd -o pg.png
```
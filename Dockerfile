FROM debian:bookworm-slim

# ───────────── Install wget for fetching certs ─────────────
RUN apt update -y && apt install -y wget

# ───────────── Aselsan Certs ─────────────
RUN wget --no-check-certificate https://gitlabce01.aselsan.com.tr/-/snippets/15/raw/main/AselsanCA.crt?inline=false -O AselsanCA.crt
RUN wget --no-check-certificate https://gitlabce01.aselsan.com.tr/-/snippets/15/raw/main/AselsanInternetCA.crt?inline=false -O AselsanInternetCA.crt
RUN cp AselsanCA.crt /usr/local/share/ca-certificates/
RUN cp AselsanInternetCA.crt /usr/local/share/ca-certificates/
RUN rm AselsanCA.crt AselsanInternetCA.crt
RUN update-ca-certificates

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# ---- System deps (LaTeX + Node + Mermaid/Chromium deps) ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git wget \
    make \
    python3 \
    # LaTeX
    latexmk \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-xetex \
    texlive-luatex \
    texlive-lang-all \
    texlive-science \
    # Mermaid CLI browser + deps (REAL chromium, not snap)
    chromium \
    chromium-sandbox \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libxrender1 \
    libxshmfence1 \
    libxss1 \
    libxtst6 \
    xdg-utils \
 && rm -rf /var/lib/apt/lists/*

# ---- Install Node.js (LTS) + npm ----
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get update && apt-get install -y --no-install-recommends nodejs \
 && rm -rf /var/lib/apt/lists/*

# ---- Create non-root user (recommended) ----
ARG USER=builder
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${USER} && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER}

# ---- npm config (Nexus registry etc.) ----
COPY .npmrc /home/${USER}/.npmrc
RUN chown ${USER}:${USER} /home/${USER}/.npmrc

# ---- Install mermaid-cli globally for that user ----
ENV NPM_CONFIG_PREFIX=/home/${USER}/.npm-global
ENV PATH=/home/${USER}/.npm-global/bin:$PATH

# (keep if your environment needs it; otherwise you can remove)
ENV NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt

USER ${USER}
WORKDIR /work

# Version fixed because of open issue: https://github.com/mermaid-js/mermaid/issues/5941
RUN npm install -g @mermaid-js/mermaid-cli@10.9.1

# Tell mermaid-cli which browser to use
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV PUPPETEER_ARGS="--no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage"

CMD ["latexmk", "-pdf", "-interaction=nonstopmode", "-f", "-pvc", "main.tex"]

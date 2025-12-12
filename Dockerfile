FROM ubuntu:22.04

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
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
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
    # Mermaid CLI headless chromium deps
    chromium-browser \
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
    xdg-utils

RUN apt-get install -y --no-install-recommends \
    texlive-science

# ---- Install Node.js (LTS) + npm ----
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get update && apt-get install -y --no-install-recommends nodejs \
 && rm -rf /var/lib/apt/lists/*

# ---- Create non-root user (recommended) ----
ARG USER=builder
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${USER} && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER}

# ---- Install mermaid-cli globally for that user ----
# npm config (Nexus registry etc.)
COPY .npmrc /home/${USER}/.npmrc
RUN chown ${USER}:${USER} /home/${USER}/.npmrc

ENV NPM_CONFIG_PREFIX=/home/${USER}/.npm-global
ENV PATH=/home/${USER}/.npm-global/bin:$PATH

ENV NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt

USER ${USER}
WORKDIR /work

RUN npm install -g @mermaid-js/mermaid-cli

# Tell mermaid-cli which browser to use (important in containers)
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Default command
CMD ["bash"]

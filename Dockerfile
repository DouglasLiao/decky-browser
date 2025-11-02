# Dockerfile para build do plugin Decky Browser
FROM node:18-alpine AS builder

# Instalar dependências do sistema
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    && npm install -g pnpm

WORKDIR /app

# Copiar arquivos de configuração
COPY package.json pnpm-lock.yaml* ./
COPY tsconfig.json ./
COPY rollup.config.js ./

# Instalar dependências
RUN pnpm install --frozen-lockfile

# Copiar código fonte
COPY src/ ./src/
COPY plugin.json ./

# Build do projeto
RUN pnpm run build

# Imagem final para distribuição
FROM alpine:latest

# Instalar rsync para facilitar a cópia de arquivos
RUN apk add --no-cache rsync

WORKDIR /plugin

# Copiar arquivos necessários
COPY --from=builder /app/dist/ ./dist/
COPY --from=builder /app/plugin.json ./
COPY --from=builder /app/package.json ./

# Criar script de instalação
RUN echo '#!/bin/sh' > install.sh && \
    echo 'echo "Installing Decky Browser Plugin..."' >> install.sh && \
    echo 'DECKY_HOME="${DECKY_HOME:-$HOME/homebrew}"' >> install.sh && \
    echo 'PLUGIN_DIR="$DECKY_HOME/plugins/decky-browser"' >> install.sh && \
    echo 'mkdir -p "$PLUGIN_DIR"' >> install.sh && \
    echo 'rsync -av /plugin/ "$PLUGIN_DIR/"' >> install.sh && \
    echo 'echo "Plugin installed successfully!"' >> install.sh && \
    echo 'echo "Restart Decky Loader to see the plugin."' >> install.sh && \
    chmod +x install.sh

# Script de desinstalação
RUN echo '#!/bin/sh' > uninstall.sh && \
    echo 'echo "Uninstalling Decky Browser Plugin..."' >> uninstall.sh && \
    echo 'DECKY_HOME="${DECKY_HOME:-$HOME/homebrew}"' >> uninstall.sh && \
    echo 'PLUGIN_DIR="$DECKY_HOME/plugins/decky-browser"' >> uninstall.sh && \
    echo 'rm -rf "$PLUGIN_DIR"' >> uninstall.sh && \
    echo 'echo "Plugin uninstalled successfully!"' >> uninstall.sh && \
    chmod +x uninstall.sh

CMD ["sh", "install.sh"]
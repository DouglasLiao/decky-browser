#!/bin/bash

# Script de inicialização do browser em container

export DISPLAY=:1

# Aguardar X server iniciar
sleep 2

# Configurar resolução
xrandr --output default --mode 1280x720 2>/dev/null || true

# Iniciar Chromium em modo kiosk
exec chromium-browser \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --disable-software-rasterizer \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --disable-features=TranslateUI \
    --disable-extensions \
    --disable-plugins \
    --disable-sync \
    --disable-translate \
    --disable-web-security \
    --disable-features=VizDisplayCompositor \
    --start-maximized \
    --kiosk \
    --app=https://www.google.com \
    --user-data-dir=/home/browser/.config/chromium
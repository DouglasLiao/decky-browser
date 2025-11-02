#!/bin/bash

set -e

echo "=== Decky Browser Plugin Packager ==="

# Verificar se o build foi feito
if [ ! -d "build-output" ]; then
    echo "❌ Pasta build-output não encontrada. Execute o build primeiro:"
    echo "   ./build-simple.sh build-native"
    exit 1
fi

# Criar pasta temporária para o plugin
TEMP_DIR=$(mktemp -d)
PLUGIN_DIR="$TEMP_DIR/decky-browser"

echo "📦 Criando estrutura do plugin..."

# Criar estrutura
mkdir -p "$PLUGIN_DIR"

# Copiar arquivos do build
cp -r build-output/* "$PLUGIN_DIR/"

# Copiar backend
cp main.py "$PLUGIN_DIR/"

# Copiar arquivos Docker
echo "🐳 Incluindo arquivos Docker..."
cp Dockerfile.browser "$PLUGIN_DIR/" 2>/dev/null || echo "⚠️  Dockerfile.browser não encontrado"
cp docker-compose.browser.yml "$PLUGIN_DIR/" 2>/dev/null || echo "⚠️  docker-compose.browser.yml não encontrado"
cp browser-supervisor.conf "$PLUGIN_DIR/" 2>/dev/null || echo "⚠️  browser-supervisor.conf não encontrado"
cp browser-start.sh "$PLUGIN_DIR/" 2>/dev/null || echo "⚠️  browser-start.sh não encontrado"
cp docker-browser.sh "$PLUGIN_DIR/" 2>/dev/null || echo "⚠️  docker-browser.sh não encontrado"
cp vnc-passwd "$PLUGIN_DIR/" 2>/dev/null || echo "⚠️  vnc-passwd não encontrado"

# Dar permissão de execução aos scripts
chmod +x "$PLUGIN_DIR"/*.sh 2>/dev/null || true

# Copiar documentação
cp README.md "$PLUGIN_DIR/" 2>/dev/null || echo "⚠️  README.md não encontrado"

# Criar ZIP
ZIP_NAME="decky-browser-$(date +%Y%m%d-%H%M%S).zip"
echo "📦 Criando $ZIP_NAME..."

cd "$TEMP_DIR"
zip -r "../$ZIP_NAME" decky-browser/

# Mover para diretório atual
mv "../$ZIP_NAME" "$OLDPWD/"

# Limpeza
rm -rf "$TEMP_DIR"

echo "✅ Plugin empacotado com sucesso!"
echo "📦 Arquivo: $ZIP_NAME"
echo ""
echo "🚀 Para instalar no Steam Deck:"
echo "   1. Transfira o arquivo ZIP para o Steam Deck"
echo "   2. Execute: unzip $ZIP_NAME -d ~/.local/share/decky/plugins/"
echo "   3. Reinicie o Decky Loader"
echo ""
echo "📋 Conteúdo do pacote:"
ls -la "$ZIP_NAME"

echo ""
echo "🔍 Verificando conteúdo do ZIP:"
unzip -l "$ZIP_NAME"
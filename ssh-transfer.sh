#!/bin/bash

# 🚀 Script de Transferência SSH para Steam Deck
# Transfira e instale o plugin Decky Browser via SSH

echo "=== Transferência do Decky Browser Plugin via SSH ==="

# Verificar se o ZIP existe
ZIP_FILE="decky-browser-20251102-103556.zip"
if [ ! -f "$ZIP_FILE" ]; then
    echo "❌ Arquivo $ZIP_FILE não encontrado!"
    echo "Execute primeiro: ./package-plugin.sh"
    exit 1
fi

echo "✅ Arquivo encontrado: $ZIP_FILE ($(du -h $ZIP_FILE | cut -f1))"

# Configurações SSH (ajuste conforme necessário)
echo ""
echo "📝 Configure as informações do Steam Deck:"
read -p "IP do Steam Deck (ex: 192.168.1.100): " STEAM_IP
read -p "Usuário SSH (padrão: deck): " STEAM_USER
STEAM_USER=${STEAM_USER:-deck}

echo ""
echo "🔄 Iniciando transferência..."

# 1. Transferir o arquivo
echo "📤 Copiando $ZIP_FILE para $STEAM_USER@$STEAM_IP..."
scp "$ZIP_FILE" "$STEAM_USER@$STEAM_IP:~/Downloads/"

if [ $? -eq 0 ]; then
    echo "✅ Transferência concluída!"
else
    echo "❌ Erro na transferência!"
    exit 1
fi

# 2. Executar instalação remota
echo ""
echo "🚀 Instalando plugin remotamente..."
ssh "$STEAM_USER@$STEAM_IP" << 'EOF'
echo "=== Instalação do Decky Browser Plugin ==="

# Navegar para Downloads
cd ~/Downloads

# Verificar se o arquivo chegou
if [ ! -f "decky-browser-20251102-103556.zip" ]; then
    echo "❌ Arquivo ZIP não encontrado!"
    exit 1
fi

echo "✅ Arquivo ZIP encontrado"

# Criar diretório se não existir
mkdir -p ~/.local/share/decky/plugins/

# Remover versão anterior se existir
if [ -d ~/.local/share/decky/plugins/decky-browser ]; then
    echo "🗑️ Removendo versão anterior..."
    rm -rf ~/.local/share/decky/plugins/decky-browser
fi

# Instalar plugin
echo "📦 Extraindo plugin..."
unzip -q decky-browser-20251102-103556.zip -d ~/.local/share/decky/plugins/

# Verificar instalação
if [ -d ~/.local/share/decky/plugins/decky-browser ]; then
    echo "✅ Plugin instalado com sucesso!"
    echo "📂 Localização: ~/.local/share/decky/plugins/decky-browser"
    
    # Mostrar arquivos instalados
    echo ""
    echo "📋 Arquivos instalados:"
    ls -la ~/.local/share/decky/plugins/decky-browser/ | head -10
    
    # Dar permissões corretas
    chmod -R 755 ~/.local/share/decky/plugins/decky-browser/
    chmod +x ~/.local/share/decky/plugins/decky-browser/*.sh 2>/dev/null || true
    
    echo ""
    echo "🎉 INSTALAÇÃO CONCLUÍDA!"
    echo ""
    echo "📝 Próximos passos:"
    echo "   1. Reinicie o Decky Loader"
    echo "   2. Procure por 'Simple Browser' no menu Decky"
    echo "   3. Teste ambas as opções de browser"
    echo ""
    echo "🐳 Browser Docker:"
    echo "   - Primeira execução demora ~2-3 minutos"
    echo "   - Imune a atualizações do Steam OS"
    echo "   - Interface em: http://localhost:6080"
    
else
    echo "❌ Erro na instalação!"
    exit 1
fi
EOF

echo ""
echo "🎯 Transferência e instalação concluídas!"
echo ""
echo "💡 Comandos úteis para SSH no Steam Deck:"
echo "   ssh $STEAM_USER@$STEAM_IP"
echo "   scp arquivo.zip $STEAM_USER@$STEAM_IP:~/Downloads/"
echo ""
echo "🔧 Para verificar status no Steam Deck:"
echo "   ls ~/.local/share/decky/plugins/decky-browser/"
echo "   systemctl --user status decky-loader"
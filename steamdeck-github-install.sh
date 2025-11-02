#!/bin/bash
# Instalação direta do Decky Browser via GitHub no Steam Deck
# Execute este script no terminal SSH do Steam Deck

echo "🚀 Instalação do Decky Browser via GitHub"
echo "📦 Repositório: https://github.com/DouglasLiao/decky-browser"

# Verificar se está no Steam Deck
if [[ ! -f /etc/steamos-release ]] && [[ ! -d /home/deck ]]; then
    echo "⚠️  Este script deve ser executado no Steam Deck"
fi

# Criar diretório de plugins se não existir
echo "📂 Preparando diretórios..."
mkdir -p ~/.local/share/decky/plugins/
cd ~/.local/share/decky/plugins/

# Remover versão anterior se existir
if [ -d "decky-browser" ]; then
    echo "🗑️  Removendo versão anterior..."
    rm -rf decky-browser
fi

# Baixar repositório
echo "📥 Baixando do GitHub..."
if command -v git &> /dev/null; then
    # Se git estiver disponível
    git clone https://github.com/DouglasLiao/decky-browser.git
    cd decky-browser
else
    # Usar wget para baixar ZIP
    echo "📦 Baixando ZIP do repositório..."
    wget -O decky-browser.zip https://github.com/DouglasLiao/decky-browser/archive/refs/heads/master.zip
    
    if [ $? -eq 0 ]; then
        echo "✅ Download concluído"
        unzip -q decky-browser.zip
        mv decky-browser-master decky-browser
        rm decky-browser.zip
        cd decky-browser
    else
        echo "❌ Erro no download"
        exit 1
    fi
fi

# Verificar se build-output existe (arquivos compilados)
if [ ! -d "build-output" ]; then
    echo "⚠️  Arquivos compilados não encontrados no repositório"
    echo "💡 Você precisa fazer o build primeiro ou baixar o ZIP release"
    echo ""
    echo "🔧 Alternativa: Baixar ZIP compilado"
    echo "   No seu PC: ./package-plugin.sh"
    echo "   Transferir: scp *.zip deck@steamdeck:~/Downloads/"
    exit 1
fi

# Copiar arquivos compilados para o diretório raiz
echo "📋 Organizando arquivos..."
cp -r build-output/* .
cp main.py .
cp plugin.json .

# Verificar arquivos essenciais
REQUIRED_FILES=("main.py" "index.js" "plugin.json")
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Arquivo essencial faltando: $file"
        exit 1
    fi
done

echo "✅ Arquivos essenciais encontrados"

# Dar permissões corretas
echo "🔧 Configurando permissões..."
chmod -R 755 .
chmod +x *.sh 2>/dev/null || true

# Verificar instalação
echo ""
echo "🎉 INSTALAÇÃO CONCLUÍDA!"
echo ""
echo "📂 Plugin instalado em:"
echo "   ~/.local/share/decky/plugins/decky-browser/"
echo ""
echo "📋 Arquivos instalados:"
ls -la ~/.local/share/decky/plugins/decky-browser/ | head -10

echo ""
echo "🔄 PRÓXIMOS PASSOS:"
echo "   1. Reinicie o Decky Loader"
echo "   2. Procure 'Simple Browser' no menu Decky"
echo "   3. Teste ambas as opções de browser"
echo ""
echo "🐳 Para usar o Browser Docker:"
echo "   - Primeira execução demora ~2-3 minutos"
echo "   - Interface disponível em: http://localhost:6080"
echo ""
echo "💡 Para verificar logs do Decky:"
echo "   journalctl --user -u decky-loader -f"
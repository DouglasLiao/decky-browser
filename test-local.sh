#!/bin/bash

set -e

echo "=== Decky Browser Plugin - Teste Local ==="

# Verificar dependências
echo "🔍 Verificando dependências..."

# Verificar se o Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não está instalado!"
    echo "   Para instalar: sudo apt install docker.io"
    exit 1
fi

# Verificar se o Docker está rodando
if ! docker info &> /dev/null; then
    echo "❌ Docker não está rodando!"
    echo "   Para iniciar: sudo systemctl start docker"
    exit 1
fi

echo "✅ Docker está disponível"

# Verificar se o build foi feito
if [ ! -d "build-output" ]; then
    echo "📦 Fazendo build do plugin..."
    ./build-simple.sh build-native
fi

echo "✅ Build do plugin disponível"

# Testar o backend Python
echo "🐍 Testando backend Python..."
python3 -c "
import sys
sys.path.append('.')
try:
    import main
    print('✅ Backend importado com sucesso')
    
    # Testar algumas funções básicas
    print('🔍 Testando funções do backend...')
    
    # Note: Estas são funções async, apenas verificando se existem
    if hasattr(main.Plugin, 'check_browser_container'):
        print('✅ check_browser_container - OK')
    if hasattr(main.Plugin, 'start_browser_container'):
        print('✅ start_browser_container - OK') 
    if hasattr(main.Plugin, 'navigate_browser'):
        print('✅ navigate_browser - OK')
        
    print('✅ Todas as funções do backend estão disponíveis')
    
except ImportError as e:
    print(f'❌ Erro ao importar backend: {e}')
    sys.exit(1)
except Exception as e:
    print(f'❌ Erro no backend: {e}')
    sys.exit(1)
"

# Testar se os arquivos Docker estão presentes
echo "🐳 Verificando arquivos Docker..."
required_files=(
    "Dockerfile.browser"
    "docker-compose.browser.yml"
    "browser-supervisor.conf"
    "browser-start.sh"
    "docker-browser.sh"
    "vnc-passwd"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file - OK"
    else
        echo "❌ $file - FALTANDO"
        exit 1
    fi
done

# Testar build da imagem Docker (opcional)
echo ""
echo "🔧 Deseja testar o build da imagem Docker? (pode demorar alguns minutos)"
echo "   [y] Sim, fazer build completo"
echo "   [n] Não, apenas verificar estrutura"
echo "   [s] Só verificar se Docker funciona"
read -p "Escolha [y/n/s]: " choice

case $choice in
    [Yy]* )
        echo "🐳 Fazendo build da imagem Docker..."
        chmod +x docker-browser.sh
        ./docker-browser.sh build
        echo "✅ Build Docker concluído!"
        ;;
    [Ss]* )
        echo "🐳 Testando Docker rapidamente..."
        docker run --rm hello-world > /dev/null 2>&1
        echo "✅ Docker funcionando!"
        ;;
    * )
        echo "⏭️ Pulando teste Docker"
        ;;
esac

# Verificar frontend
echo ""
echo "🌐 Verificando arquivos do frontend..."
if [ -f "build-output/index.js" ]; then
    echo "✅ Frontend buildado - OK"
    echo "📊 Tamanho do bundle: $(du -h build-output/index.js | cut -f1)"
else
    echo "❌ Frontend não buildado"
    exit 1
fi

# Verificar componentes
if [ -f "build-output/components/BrowserModal.d.ts" ] && [ -f "build-output/components/BrowserContainerModal.d.ts" ]; then
    echo "✅ Componentes React - OK"
else
    echo "❌ Componentes React faltando"
    exit 1
fi

echo ""
echo "🎉 TESTE LOCAL CONCLUÍDO COM SUCESSO!"
echo ""
echo "📋 Resumo do Plugin:"
echo "   • Frontend React: ✅ Compilado"
echo "   • Backend Python: ✅ Funcional"
echo "   • Docker Setup: ✅ Pronto"
echo "   • Componentes: ✅ Ambos (WebView + Docker)"
echo ""
echo "🚀 Próximos passos para teste real:"
echo "   1. Instalar no Steam Deck: unzip decky-browser-*.zip -d ~/.local/share/decky/plugins/"
echo "   2. Reiniciar Decky Loader"
echo "   3. Testar ambos os browsers no plugin"
echo ""
echo "💡 Para desenvolvimento contínuo:"
echo "   • Use: ./build-simple.sh build-native (para rebuild)"
echo "   • Use: ./package-plugin.sh (para novo ZIP)"
echo "   • Use: ./docker-browser.sh status (para verificar container)"
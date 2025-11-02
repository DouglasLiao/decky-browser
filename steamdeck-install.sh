#!/bin/bash

# Script de instalação OTIMIZADO para Steam Deck
# Funciona com download direto do GitHub (ZIP ou clone)

set -e

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Decky Browser Plugin - Instalador Steam Deck ===${NC}"

# Detectar se estamos no Steam Deck
IS_STEAM_DECK=false
if [ -f "/etc/os-release" ] && grep -q "steamdeck" /etc/os-release 2>/dev/null; then
    IS_STEAM_DECK=true
    echo -e "${GREEN}✓ Steam Deck detectado!${NC}"
else
    echo -e "${YELLOW}⚠ Sistema não é Steam Deck, mas continuando...${NC}"
fi

# Função para instalar via GitHub (download direto)
install_from_github() {
    local repo_url="https://github.com/douglasliao/decky-browser"
    local zip_url="${repo_url}/archive/refs/heads/main.zip"
    local temp_dir="/tmp/decky-browser-install"
    
    echo -e "${BLUE}Baixando plugin do GitHub...${NC}"
    
    # Limpar diretório temporário
    rm -rf "$temp_dir"
    mkdir -p "$temp_dir"
    cd "$temp_dir"
    
    # Baixar ZIP
    if command -v curl &> /dev/null; then
        curl -L "$zip_url" -o plugin.zip
    elif command -v wget &> /dev/null; then
        wget "$zip_url" -O plugin.zip
    else
        echo -e "${RED}✗ curl ou wget não encontrado!${NC}"
        return 1
    fi
    
    # Extrair
    echo -e "${BLUE}Extraindo arquivos...${NC}"
    unzip -q plugin.zip
    cd decky-browser-main || cd decky-browser-*
    
    # Usar arquivos pré-compilados se existirem
    if [ -d "build-output" ] && [ "$(ls -A build-output)" ]; then
        echo -e "${GREEN}✓ Usando arquivos pré-compilados${NC}"
        install_files "build-output"
    else
        echo -e "${RED}✗ Arquivos pré-compilados não encontrados!${NC}"
        echo -e "${BLUE}É necessário fazer build manual ou usar release com ZIP.${NC}"
        return 1
    fi
}

# Função para instalar arquivos
install_files() {
    local source_dir="$1"
    local decky_home="${DECKY_HOME:-/home/deck/homebrew}"
    local plugin_dir="$decky_home/plugins/decky-browser"
    
    echo -e "${BLUE}Instalando em: $plugin_dir${NC}"
    
    # Verificar se Decky Loader existe
    if [ ! -d "$decky_home" ]; then
        echo -e "${RED}✗ Decky Loader não encontrado em: $decky_home${NC}"
        echo -e "${YELLOW}Instale o Decky Loader primeiro: https://deckbrew.xyz${NC}"
        return 1
    fi
    
    # Criar diretório do plugin
    mkdir -p "$plugin_dir"
    
    # Copiar arquivos
    echo -e "${YELLOW}Copiando arquivos...${NC}"
    cp -r "$source_dir"/* "$plugin_dir/"
    
    # Copiar main.py se existir
    if [ -f "main.py" ]; then
        cp main.py "$plugin_dir/"
    fi
    
    # Verificar arquivos essenciais
    local missing_files=()
    [ ! -f "$plugin_dir/index.js" ] && missing_files+=("index.js")
    [ ! -f "$plugin_dir/main.py" ] && missing_files+=("main.py")
    [ ! -f "$plugin_dir/plugin.json" ] && missing_files+=("plugin.json")
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        echo -e "${RED}✗ Arquivos essenciais faltando: ${missing_files[*]}${NC}"
        return 1
    fi
    
    # Definir permissões
    chmod 644 "$plugin_dir"/*.{js,py,json} 2>/dev/null || true
    
    echo -e "${GREEN}✓ Plugin instalado com sucesso!${NC}"
    return 0
}

# Função para instalação local (se já tiver os arquivos)
install_local() {
    if [ -d "build-output" ] && [ "$(ls -A build-output)" ]; then
        install_files "build-output"
    elif [ -f "index.js" ] && [ -f "main.py" ] && [ -f "plugin.json" ]; then
        install_files "."
    else
        echo -e "${RED}✗ Arquivos necessários não encontrados no diretório atual!${NC}"
        echo -e "${BLUE}Arquivos necessários: index.js, main.py, plugin.json${NC}"
        return 1
    fi
}

# Função principal
main() {
    case "${1:-auto}" in
        local)
            echo -e "${BLUE}Instalando a partir do diretório atual...${NC}"
            install_local
            ;;
        github)
            echo -e "${BLUE}Instalando a partir do GitHub...${NC}"
            install_from_github
            ;;
        auto)
            echo -e "${BLUE}Detecção automática...${NC}"
            if install_local 2>/dev/null; then
                echo -e "${GREEN}✓ Instalação local bem-sucedida!${NC}"
            else
                echo -e "${YELLOW}Tentando download do GitHub...${NC}"
                install_from_github
            fi
            ;;
        help|--help|-h)
            echo "Uso: $0 [MÉTODO]"
            echo ""
            echo "Métodos:"
            echo "  auto     Detecta automaticamente (padrão)"
            echo "  local    Instala do diretório atual"
            echo "  github   Baixa e instala do GitHub"
            echo "  help     Mostra esta ajuda"
            echo ""
            echo "Variáveis de ambiente:"
            echo "  DECKY_HOME   Caminho do Decky Loader (padrão: /home/deck/homebrew)"
            exit 0
            ;;
        *)
            echo -e "${RED}✗ Método desconhecido: $1${NC}"
            echo "Use: $0 help para ver opções"
            exit 1
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}🎉 Instalação concluída!${NC}"
        echo ""
        echo -e "${YELLOW}Próximos passos:${NC}"
        echo -e "${BLUE}1. Reinicie o Steam Deck OU${NC}"
        echo -e "${BLUE}2. Menu rápido (...) → Configurações → Plugins → Reload${NC}"
        echo -e "${BLUE}3. Procure por 'Simple Browser' na lista de plugins${NC}"
        echo -e "${BLUE}4. Clique no ícone de globo para abrir${NC}"
        
        if [ "$IS_STEAM_DECK" = true ]; then
            echo ""
            echo -e "${GREEN}💡 Dica Steam Deck: Use o trackpad direito para navegar no browser!${NC}"
        fi
    else
        echo ""
        echo -e "${RED}✗ Falha na instalação!${NC}"
        echo -e "${BLUE}Verifique os logs acima para mais detalhes.${NC}"
        exit 1
    fi
}

# Executar
main "$@"
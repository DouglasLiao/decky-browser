#!/bin/bash

# Script para build e instalação do Decky Browser Plugin

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Decky Browser Plugin Builder ===${NC}"

# Função para mostrar ajuda
show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  build      Build the plugin using Docker"
    echo "  install    Build and install the plugin"
    echo "  dev        Start development mode with hot reload"
    echo "  clean      Clean build artifacts and Docker images"
    echo "  help       Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  DECKY_HOME    Path to Decky Loader installation (default: \$HOME/homebrew)"
    echo ""
    echo "Examples:"
    echo "  $0 build                    # Build the plugin"
    echo "  $0 install                  # Build and install to Steam Deck"
    echo "  DECKY_HOME=/custom/path $0 install  # Install to custom location"
}

# Função para build
build_plugin() {
    echo -e "${YELLOW}Building Decky Browser Plugin...${NC}"
    
    # Criar diretório de output se não existir
    mkdir -p build-output
    
    # Build usando Docker Compose
    docker-compose run --rm decky-browser-build
    
    echo -e "${GREEN}✓ Build completed successfully!${NC}"
    echo -e "${BLUE}Built files available in: ./build-output${NC}"
}

# Função para instalação
install_plugin() {
    echo -e "${YELLOW}Building and installing Decky Browser Plugin...${NC}"
    
    # Verificar se DECKY_HOME está definido
    DECKY_HOME="${DECKY_HOME:-$HOME/homebrew}"
    
    if [ ! -d "$DECKY_HOME" ]; then
        echo -e "${RED}✗ Decky Loader not found at: $DECKY_HOME${NC}"
        echo -e "${YELLOW}Please install Decky Loader first or set DECKY_HOME environment variable${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Installing to: $DECKY_HOME/plugins/decky-browser${NC}"
    
    # Build e install usando Docker Compose
    DECKY_HOME="$DECKY_HOME" docker-compose run --rm decky-browser-install
    
    echo -e "${GREEN}✓ Plugin installed successfully!${NC}"
    echo -e "${YELLOW}Please restart Decky Loader to see the plugin.${NC}"
}

# Função para desenvolvimento
dev_mode() {
    echo -e "${YELLOW}Starting development mode...${NC}"
    echo -e "${BLUE}Files will be watched for changes and automatically rebuilt.${NC}"
    echo -e "${BLUE}Press Ctrl+C to stop.${NC}"
    
    docker-compose up decky-browser-dev
}

# Função para limpeza
clean_all() {
    echo -e "${YELLOW}Cleaning build artifacts and Docker images...${NC}"
    
    # Remover containers
    docker-compose down --remove-orphans 2>/dev/null || true
    
    # Remover imagens
    docker rmi decky-browser_decky-browser-build 2>/dev/null || true
    docker rmi decky-browser_decky-browser-dev 2>/dev/null || true
    
    # Remover build output
    rm -rf build-output
    rm -rf node_modules
    rm -rf dist
    
    echo -e "${GREEN}✓ Cleanup completed!${NC}"
}

# Verificar se Docker está disponível
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker is not installed or not available${NC}"
    echo -e "${YELLOW}Please install Docker to use this script${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}✗ Docker Compose is not installed or not available${NC}"
    echo -e "${YELLOW}Please install Docker Compose to use this script${NC}"
    exit 1
fi

# Parse command
case "${1:-help}" in
    build)
        build_plugin
        ;;
    install)
        install_plugin
        ;;
    dev)
        dev_mode
        ;;
    clean)
        clean_all
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}✗ Unknown command: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
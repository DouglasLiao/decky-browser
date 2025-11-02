#!/bin/bash

# Script de build alternativo sem Docker Compose
# Para uso quando Docker Compose não está disponível

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Decky Browser Plugin Builder (Docker Only) ===${NC}"

# Função para mostrar ajuda
show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  build      Build the plugin using Docker"
    echo "  install    Build and install the plugin"
    echo "  clean      Clean build artifacts"
    echo "  help       Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  DECKY_HOME    Path to Decky Loader installation (default: \$HOME/homebrew)"
}

# Função para build
build_plugin() {
    echo -e "${YELLOW}Building Decky Browser Plugin with Docker...${NC}"
    
    # Criar diretório de output se não existir
    mkdir -p build-output
    
    # Build da imagem Docker
    docker build -t decky-browser:latest .
    
    # Extrair arquivos built
    docker run --rm -v "$(pwd)/build-output:/output" decky-browser:latest sh -c "cp -r /plugin/* /output/"
    
    echo -e "${GREEN}✓ Build completed successfully!${NC}"
    echo -e "${BLUE}Built files available in: ./build-output${NC}"
}

# Função para build nativo (sem Docker)
build_native() {
    echo -e "${YELLOW}Building natively (without Docker)...${NC}"
    
    # Verificar se Node.js está instalado
    if ! command -v node &> /dev/null; then
        echo -e "${RED}✗ Node.js is not installed${NC}"
        echo -e "${YELLOW}Please install Node.js 16+ or use Docker build${NC}"
        exit 1
    fi
    
    # Verificar se pnpm está instalado, se não, usar npm
    if command -v pnpm &> /dev/null; then
        PACKAGE_MANAGER="pnpm"
        INSTALL_CMD="pnpm install"
        BUILD_CMD="pnpm run build"
    elif command -v yarn &> /dev/null; then
        PACKAGE_MANAGER="yarn"
        INSTALL_CMD="yarn install"
        BUILD_CMD="yarn run build"
    else
        PACKAGE_MANAGER="npm"
        INSTALL_CMD="npm install"
        BUILD_CMD="npm run build"
    fi
    
    echo -e "${BLUE}Using package manager: $PACKAGE_MANAGER${NC}"
    
    # Instalar dependências
    echo -e "${YELLOW}Installing dependencies...${NC}"
    $INSTALL_CMD
    
    # Build
    echo -e "${YELLOW}Building project...${NC}"
    $BUILD_CMD
    
    # Copiar arquivos para build-output
    mkdir -p build-output
    cp -r dist/* build-output/ 2>/dev/null || true
    cp plugin.json build-output/ 2>/dev/null || true
    cp package.json build-output/ 2>/dev/null || true
    
    echo -e "${GREEN}✓ Native build completed successfully!${NC}"
    echo -e "${BLUE}Built files available in: ./build-output${NC}"
}

# Função para instalação
install_plugin() {
    echo -e "${YELLOW}Installing Decky Browser Plugin...${NC}"
    
    # Verificar se DECKY_HOME está definido
    DECKY_HOME="${DECKY_HOME:-$HOME/homebrew}"
    
    if [ ! -d "$DECKY_HOME" ]; then
        echo -e "${RED}✗ Decky Loader not found at: $DECKY_HOME${NC}"
        echo -e "${YELLOW}Please install Decky Loader first or set DECKY_HOME environment variable${NC}"
        exit 1
    fi
    
    # Build primeiro se não existe
    if [ ! -d "build-output" ] || [ -z "$(ls -A build-output)" ]; then
        echo -e "${BLUE}No build found, building first...${NC}"
        if command -v docker &> /dev/null; then
            build_plugin
        else
            build_native
        fi
    fi
    
    PLUGIN_DIR="$DECKY_HOME/plugins/decky-browser"
    echo -e "${BLUE}Installing to: $PLUGIN_DIR${NC}"
    
    # Criar diretório do plugin
    mkdir -p "$PLUGIN_DIR"
    
    # Copiar arquivos
    cp -r build-output/* "$PLUGIN_DIR/"
    
    echo -e "${GREEN}✓ Plugin installed successfully!${NC}"
    echo -e "${YELLOW}Please restart Decky Loader to see the plugin.${NC}"
}

# Função para limpeza
clean_all() {
    echo -e "${YELLOW}Cleaning build artifacts...${NC}"
    
    # Remover diretórios de build
    rm -rf build-output
    rm -rf node_modules
    rm -rf dist
    
    # Remover imagem Docker se existir
    if command -v docker &> /dev/null; then
        docker rmi decky-browser:latest 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✓ Cleanup completed!${NC}"
}

# Parse command
case "${1:-help}" in
    build)
        if command -v docker &> /dev/null; then
            build_plugin
        else
            echo -e "${YELLOW}Docker not found, using native build...${NC}"
            build_native
        fi
        ;;
    build-docker)
        if command -v docker &> /dev/null; then
            build_plugin
        else
            echo -e "${RED}✗ Docker is not installed${NC}"
            exit 1
        fi
        ;;
    build-native)
        build_native
        ;;
    install)
        install_plugin
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
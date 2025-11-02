#!/bin/bash

# Script para buildar e gerenciar o browser em container Docker

set -e

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Decky Browser - Docker Container Manager ===${NC}"

show_help() {
    echo "Uso: $0 [COMANDO]"
    echo ""
    echo "Comandos:"
    echo "  build       Buildar imagem Docker do browser"
    echo "  start       Iniciar container do browser"
    echo "  stop        Parar container do browser"
    echo "  restart     Reiniciar container do browser"
    echo "  status      Verificar status do container"
    echo "  logs        Ver logs do container"
    echo "  clean       Limpar imagens e containers"
    echo "  install     Buildar imagem e instalar plugin"
    echo "  help        Mostrar esta ajuda"
    echo ""
    echo "URLs de acesso:"
    echo "  noVNC Web:  http://localhost:6080"
    echo "  VNC Direct: localhost:5901"
}

build_browser_image() {
    echo -e "${YELLOW}Buildando imagem Docker do browser...${NC}"
    
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}✗ Docker não encontrado!${NC}"
        return 1
    fi
    
    # Buildar imagem do browser
    docker build -f Dockerfile.browser -t decky-browser:latest .
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Imagem Docker do browser buildada com sucesso!${NC}"
        return 0
    else
        echo -e "${RED}✗ Erro ao buildar imagem Docker!${NC}"
        return 1
    fi
}

start_container() {
    echo -e "${YELLOW}Iniciando container do browser...${NC}"
    
    # Parar container existente se houver
    docker stop decky-browser-isolated 2>/dev/null || true
    docker rm decky-browser-isolated 2>/dev/null || true
    
    # Iniciar container
    docker run -d \
        --name decky-browser-isolated \
        -p 6080:6080 \
        -p 5901:5901 \
        --restart unless-stopped \
        --security-opt seccomp:unconfined \
        decky-browser:latest
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Container iniciado com sucesso!${NC}"
        echo -e "${BLUE}Acesse em: http://localhost:6080${NC}"
        
        # Aguardar container ficar pronto
        echo -e "${YELLOW}Aguardando container ficar pronto...${NC}"
        for i in {1..30}; do
            if curl -s http://localhost:6080 >/dev/null 2>&1; then
                echo -e "${GREEN}✓ Browser está pronto!${NC}"
                break
            fi
            echo -n "."
            sleep 1
        done
        echo ""
        
        return 0
    else
        echo -e "${RED}✗ Erro ao iniciar container!${NC}"
        return 1
    fi
}

stop_container() {
    echo -e "${YELLOW}Parando container do browser...${NC}"
    
    docker stop decky-browser-isolated 2>/dev/null || true
    docker rm decky-browser-isolated 2>/dev/null || true
    
    echo -e "${GREEN}✓ Container parado!${NC}"
}

restart_container() {
    echo -e "${YELLOW}Reiniciando container do browser...${NC}"
    stop_container
    sleep 2
    start_container
}

check_status() {
    echo -e "${BLUE}Status do container:${NC}"
    
    # Verificar se container está rodando
    if docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep decky-browser-isolated; then
        echo ""
        echo -e "${GREEN}✓ Container está rodando${NC}"
        
        # Verificar se serviço está acessível
        if curl -s http://localhost:6080 >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Serviço web está acessível em: http://localhost:6080${NC}"
        else
            echo -e "${YELLOW}⚠ Container rodando mas serviço não está acessível${NC}"
        fi
    else
        echo -e "${RED}✗ Container não está rodando${NC}"
    fi
}

show_logs() {
    echo -e "${BLUE}Logs do container:${NC}"
    docker logs -f decky-browser-isolated
}

clean_all() {
    echo -e "${YELLOW}Limpando containers e imagens...${NC}"
    
    # Parar e remover container
    docker stop decky-browser-isolated 2>/dev/null || true
    docker rm decky-browser-isolated 2>/dev/null || true
    
    # Remover imagem
    docker rmi decky-browser:latest 2>/dev/null || true
    
    # Remover volumes órfãos
    docker volume prune -f 2>/dev/null || true
    
    echo -e "${GREEN}✓ Limpeza concluída!${NC}"
}

install_all() {
    echo -e "${BLUE}Instalação completa: Browser + Plugin${NC}"
    
    # 1. Buildar imagem do browser
    if ! build_browser_image; then
        return 1
    fi
    
    # 2. Buildar plugin
    echo -e "${YELLOW}Buildando plugin...${NC}"
    if ! ./build-simple.sh build-native; then
        echo -e "${RED}✗ Erro ao buildar plugin!${NC}"
        return 1
    fi
    
    # 3. Iniciar container
    if ! start_container; then
        return 1
    fi
    
    # 4. Instalar plugin
    echo -e "${YELLOW}Instalando plugin...${NC}"
    if ! ./build-simple.sh install; then
        echo -e "${RED}✗ Erro ao instalar plugin!${NC}"
        return 1
    fi
    
    echo -e "${GREEN}🎉 Instalação completa concluída!${NC}"
    echo ""
    echo -e "${BLUE}Próximos passos:${NC}"
    echo -e "${YELLOW}1. Reinicie o Decky Loader${NC}"
    echo -e "${YELLOW}2. Procure por 'Simple Browser' na lista${NC}"
    echo -e "${YELLOW}3. Use 'Browser Isolado (Docker)' para o container${NC}"
    echo -e "${YELLOW}4. Acesse diretamente: http://localhost:6080${NC}"
}

# Parse do comando
case "${1:-help}" in
    build)
        build_browser_image
        ;;
    start)
        start_container
        ;;
    stop)
        stop_container
        ;;
    restart)
        restart_container
        ;;
    status)
        check_status
        ;;
    logs)
        show_logs
        ;;
    clean)
        clean_all
        ;;
    install)
        install_all
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}✗ Comando desconhecido: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
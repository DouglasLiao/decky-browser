#!/bin/bash

# Script para criar um pacote ZIP de instalação do Decky Browser Plugin
# Para uso no Steam Deck sem necessidade de Docker ou build local

set -e

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Criando pacote ZIP do Decky Browser Plugin ===${NC}"

# Nome do arquivo ZIP
ZIP_NAME="decky-browser-plugin.zip"
TEMP_DIR="decky-browser-package"

# Limpar diretório temporário se existir
rm -rf "$TEMP_DIR"
rm -f "$ZIP_NAME"

# Criar diretório temporário
mkdir -p "$TEMP_DIR"

echo -e "${YELLOW}Fazendo build do plugin...${NC}"

# Fazer build se não existir
if [ ! -d "build-output" ] || [ -z "$(ls -A build-output)" ]; then
    ./build-simple.sh build-native
fi

echo -e "${YELLOW}Copiando arquivos necessários...${NC}"

# Copiar arquivos do build
cp -r build-output/* "$TEMP_DIR/"

# Copiar o main.py (backend Python)
cp main.py "$TEMP_DIR/"

# Copiar scripts de auto-instalação
cp auto_install.py "$TEMP_DIR/"
cp dev_init.sh "$TEMP_DIR/"

# Criar script de instalação para Steam Deck
cat > "$TEMP_DIR/install.sh" << 'EOF'
#!/bin/bash

# Script de instalação do Decky Browser Plugin para Steam Deck
# Execute este script no modo desktop do Steam Deck

set -e

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Instalando Decky Browser Plugin ===${NC}"

# Verificar se está no Steam Deck
if [ ! -f "/etc/os-release" ] || ! grep -q "steamdeck" /etc/os-release 2>/dev/null; then
    echo -e "${YELLOW}Aviso: Este script foi feito para Steam Deck, mas pode funcionar em outros sistemas Linux.${NC}"
fi

# Determinar o diretório do Decky Loader
DECKY_HOME="${DECKY_HOME:-$HOME/homebrew}"

if [ ! -d "$DECKY_HOME" ]; then
    echo -e "${RED}✗ Decky Loader não encontrado em: $DECKY_HOME${NC}"
    echo -e "${YELLOW}Certifique-se de que o Decky Loader está instalado.${NC}"
    echo -e "${BLUE}Para instalar o Decky Loader, visite: https://deckbrew.xyz${NC}"
    exit 1
fi

# Diretório do plugin
PLUGIN_DIR="$DECKY_HOME/plugins/decky-browser"

echo -e "${BLUE}Instalando em: $PLUGIN_DIR${NC}"

# Criar diretório do plugin se não existir
mkdir -p "$PLUGIN_DIR"

# Copiar arquivos
echo -e "${YELLOW}Copiando arquivos do plugin...${NC}"
cp -r ./* "$PLUGIN_DIR/" 2>/dev/null || true

# Remover o próprio script de instalação do diretório do plugin
rm -f "$PLUGIN_DIR/install.sh" 2>/dev/null || true
rm -f "$PLUGIN_DIR/README-INSTALL.txt" 2>/dev/null || true

# Verificar se os arquivos essenciais estão presentes
if [ ! -f "$PLUGIN_DIR/index.js" ]; then
    echo -e "${RED}✗ Erro: index.js não encontrado!${NC}"
    exit 1
fi

if [ ! -f "$PLUGIN_DIR/main.py" ]; then
    echo -e "${RED}✗ Erro: main.py não encontrado!${NC}"
    exit 1
fi

if [ ! -f "$PLUGIN_DIR/plugin.json" ]; then
    echo -e "${RED}✗ Erro: plugin.json não encontrado!${NC}"
    exit 1
fi

# Definir permissões
chmod 644 "$PLUGIN_DIR"/*.json 2>/dev/null || true
chmod 644 "$PLUGIN_DIR"/*.js 2>/dev/null || true
chmod 644 "$PLUGIN_DIR"/*.py 2>/dev/null || true

echo -e "${GREEN}✓ Plugin instalado com sucesso!${NC}"
echo -e "${YELLOW}Próximos passos:${NC}"
echo -e "${BLUE}1. Reinicie o Decky Loader ou reinicie o Steam Deck${NC}"
echo -e "${BLUE}2. Abra o menu rápido (botão ... do Steam Deck)${NC}"
echo -e "${BLUE}3. Procure por 'Simple Browser' na lista de plugins${NC}"
echo -e "${BLUE}4. Clique no ícone de globo para abrir o browser${NC}"
echo ""
echo -e "${GREEN}Instalação concluída!${NC}"
EOF

# Criar instruções de instalação
cat > "$TEMP_DIR/README-INSTALL.txt" << 'EOF'
=== INSTRUÇÕES DE INSTALAÇÃO - DECKY BROWSER PLUGIN ===

PASSO 1: PREPARAÇÃO
- Certifique-se de que o Decky Loader está instalado no seu Steam Deck
- Se não estiver instalado, visite: https://deckbrew.xyz
- Baixe e extraia este arquivo ZIP

PASSO 2: INSTALAÇÃO AUTOMÁTICA (RECOMENDADO)
1. Abra o modo desktop no Steam Deck
2. Abra o gerenciador de arquivos (Dolphin)
3. Navegue até a pasta onde extraiu este ZIP
4. Clique duas vezes no arquivo "install.sh"
5. Ou abra um terminal e execute: bash install.sh

PASSO 3: INSTALAÇÃO MANUAL (SE AUTOMÁTICA FALHAR)
1. Abra o gerenciador de arquivos
2. Navegue até: /home/deck/homebrew/plugins/
3. Crie uma pasta chamada: decky-browser
4. Copie todos os arquivos desta pasta (exceto install.sh e este README) para:
   /home/deck/homebrew/plugins/decky-browser/

PASSO 4: ATIVAR O PLUGIN
1. Reinicie o Steam Deck OU
2. Vá em Configurações > Plugins > Reload no Decky Loader
3. Abra o menu rápido (botão ...)
4. Procure por "Simple Browser" na lista de plugins
5. Clique no ícone de globo para abrir

ARQUIVOS INCLUSOS:
- index.js      -> Frontend do plugin (obrigatório)
- main.py       -> Backend do plugin (obrigatório)  
- plugin.json   -> Configuração do plugin (obrigatório)
- package.json  -> Metadados do plugin
- install.sh    -> Script de instalação automática

TROUBLESHOOTING:
- Se o plugin não aparecer, verifique se todos os arquivos estão em:
  /home/deck/homebrew/plugins/decky-browser/
- Certifique-se de que o Decky Loader está funcionando
- Reinicie o Steam Deck se necessário
- Verifique os logs em: Configurações > Plugins > View Logs

FUNCIONALIDADES:
- Browser leve baseado em WebView
- Navegação com botões voltar/avançar/refresh/home
- Barra de endereços com auto-detecção de protocolo
- Interface otimizada para Steam Deck
- Homepage configurada para Google

Para mais informações, visite o repositório do projeto.
EOF

# Tornar o script de instalação executável
chmod +x "$TEMP_DIR/install.sh"

echo -e "${YELLOW}Criando arquivo ZIP...${NC}"

# Criar o arquivo ZIP
cd "$TEMP_DIR"
zip -r "../$ZIP_NAME" ./*
cd ..

# Limpar diretório temporário
rm -rf "$TEMP_DIR"

echo -e "${GREEN}✓ Pacote ZIP criado com sucesso: $ZIP_NAME${NC}"
echo ""
echo -e "${BLUE}=== INSTRUÇÕES PARA O STEAM DECK ===${NC}"
echo -e "${YELLOW}1. Transfira o arquivo '$ZIP_NAME' para o Steam Deck${NC}"
echo -e "${YELLOW}2. Extraia o ZIP em qualquer local${NC}"
echo -e "${YELLOW}3. Execute o script install.sh ou copie manualmente${NC}"
echo ""
echo -e "${GREEN}O plugin está pronto para instalação!${NC}"
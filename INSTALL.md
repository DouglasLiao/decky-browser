# Guia de Instalação - Decky Browser Plugin

## 📋 Pré-requisitos

### No Steam Deck:
- **Decky Loader instalado**: Siga o guia oficial em [deckbrew.xyz](https://deckbrew.xyz)
- **Modo Desktop ativado**: Para instalação manual se necessário

### Para desenvolvimento (opcional):
- **Docker** (recomendado para builds consistentes)
- **Node.js 16+** e **pnpm** (para build nativo)
- **Git** (para clonar o repositório)

## 🚀 Instalação Rápida

### Método 1: Build e Instalação Automática (Recomendado)

```bash
# 1. Clone o repositório
git clone https://github.com/douglasliao/decky-browser.git
cd decky-browser

# 2. Build e instalação em um comando
./build-simple.sh install
```

### Método 2: Usando Docker

```bash
# Se você tem Docker Compose instalado
./build.sh install

# Ou apenas Docker
./build-simple.sh build-docker
```

## 📁 Instalação Manual

Se preferir instalar manualmente:

```bash
# 1. Build do plugin
./build-simple.sh build

# 2. Criar diretório do plugin
mkdir -p $HOME/homebrew/plugins/decky-browser

# 3. Copiar arquivos
cp -r build-output/* $HOME/homebrew/plugins/decky-browser/
cp main.py $HOME/homebrew/plugins/decky-browser/

# 4. Reiniciar o Decky Loader
```

## 🐳 Instalação com Docker

### Docker Compose (Método Completo)

```bash
# Build e instalação
docker-compose run --rm decky-browser-build

# Para desenvolvimento com hot reload
docker-compose up decky-browser-dev
```

### Docker Simples

```bash
# Build da imagem
docker build -t decky-browser:latest .

# Extrair arquivos built
docker run --rm -v "$(pwd)/build-output:/output" decky-browser:latest
```

## 🛠️ Desenvolvimento

### Setup do Ambiente

```bash
# Instalar dependências
pnpm install

# Build em modo watch
pnpm run watch

# Build de produção
pnpm run build
```

### Hot Reload com Docker

```bash
# Inicia servidor de desenvolvimento
./build.sh dev

# Ou com script simples
./build-simple.sh build-native
```

## 📍 Localizações Importantes

### Diretórios do Decky Loader:
- **Padrão**: `$HOME/homebrew/`
- **Plugins**: `$HOME/homebrew/plugins/`
- **Este plugin**: `$HOME/homebrew/plugins/decky-browser/`

### Arquivos de build:
- **Código fonte**: `src/`
- **Build output**: `build-output/`
- **Distribuição**: `dist/`

## 🔧 Comandos Úteis

```bash
# Comandos do script de build
./build-simple.sh help          # Mostrar ajuda
./build-simple.sh build         # Build automático (Docker ou nativo)
./build-simple.sh build-native  # Build nativo (sem Docker)
./build-simple.sh build-docker  # Build com Docker
./build-simple.sh install       # Build e instalação
./build-simple.sh clean         # Limpar arquivos de build

# Comandos do Docker Compose
./build.sh build               # Build com Docker Compose
./build.sh install             # Build e instalação
./build.sh dev                 # Modo desenvolvimento
./build.sh clean               # Limpeza completa
```

## 🐛 Resolução de Problemas

### Plugin não aparece no Decky Loader

1. **Verificar instalação**:
   ```bash
   ls -la $HOME/homebrew/plugins/decky-browser/
   ```

2. **Verificar arquivos necessários**:
   - `index.js` (frontend compilado)
   - `main.py` (backend Python)
   - `plugin.json` (metadados)

3. **Reiniciar Decky Loader**:
   - Vá para Configurações → Plugins → Reload

### Erro de build

1. **Limpar e rebuild**:
   ```bash
   ./build-simple.sh clean
   ./build-simple.sh build
   ```

2. **Verificar dependências**:
   ```bash
   node --version  # Deve ser 16+
   pnpm --version
   ```

3. **Instalar dependências manualmente**:
   ```bash
   rm -rf node_modules pnpm-lock.yaml
   pnpm install
   ```

### Erro do Docker

1. **Verificar Docker**:
   ```bash
   docker --version
   docker-compose --version
   ```

2. **Permissions do Docker**:
   ```bash
   sudo usermod -aG docker $USER
   # Reiniciar sessão
   ```

3. **Build sem cache**:
   ```bash
   docker build --no-cache -t decky-browser:latest .
   ```

### WebView não funciona

1. **Verificar conectividade**
2. **Testar URLs diferentes**
3. **Verificar logs do Decky**:
   ```bash
   journalctl -f -u plugin_loader
   ```

## 📝 Estrutura de Arquivos Necessários

Após a instalação, seu diretório deve ter:

```
$HOME/homebrew/plugins/decky-browser/
├── index.js           # Frontend compilado
├── main.py           # Backend Python
├── plugin.json       # Metadados do plugin
└── package.json      # Informações npm
```

## 🔄 Atualização do Plugin

```bash
# No diretório do projeto
git pull origin main
./build-simple.sh install
```

## 📞 Suporte

- **Issues**: Crie uma issue no GitHub
- **Logs**: `journalctl -f -u plugin_loader`
- **Debug**: Ative developer tools no Decky

---

**💡 Dica**: Use `./build-simple.sh` se não tiver Docker Compose, ou `./build.sh` se tiver o ambiente completo.
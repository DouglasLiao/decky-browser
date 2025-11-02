# Decky Browser Plugin

Um plugin de browser simples e leve para o Decky Loader no Steam Deck.

## 🚀 Características

- **Browser leve**: Baseado em WebView para máxima performance
- **Interface simples**: Navegação intuitiva com botões de voltar, avançar, home e refresh
- **Barra de endereços**: Digite URLs ou termos de busca diretamente
- **Integração nativa**: Funciona perfeitamente com o Decky Loader
- **Build automatizado**: Sistema completo de build e instalação usando Docker

## 📋 Pré-requisitos

- Steam Deck com Decky Loader instalado
- Docker e Docker Compose (para build)
- Git (para clonar o repositório)

## 🛠️ Instalação

### Método 1: Build e instalação automática

```bash
# Clone o repositório
git clone https://github.com/seuusuario/decky-browser.git
cd decky-browser

# Build e instalação automática
./build.sh install
```

### Método 2: Build manual

```bash
# Build apenas (sem instalar)
./build.sh build

# Instalar manualmente
cp -r build-output/* $HOME/homebrew/plugins/decky-browser/
```

### Método 3: Instalação customizada

```bash
# Para instalação em local customizado
DECKY_HOME=/caminho/customizado ./build.sh install
```

## 🔧 Desenvolvimento

Para desenvolver o plugin com hot reload:

```bash
# Modo desenvolvimento
./build.sh dev
```

## 🐳 Comandos Docker

O script `build.sh` oferece várias opções:

- `./build.sh build` - Compila o plugin
- `./build.sh install` - Compila e instala
- `./build.sh dev` - Modo desenvolvimento com hot reload
- `./build.sh clean` - Limpa arquivos de build e imagens Docker
- `./build.sh help` - Mostra a ajuda

## 📁 Estrutura do Projeto

```
decky-browser/
├── src/
│   ├── components/
│   │   └── BrowserModal.tsx    # Componente principal do browser
│   └── index.tsx               # Ponto de entrada do plugin
├── dist/                       # Arquivos compilados
├── build-output/               # Output do build Docker
├── Dockerfile                  # Configuração do container
├── docker-compose.yml          # Serviços Docker
├── build.sh                    # Script de build automatizado
├── package.json                # Dependências npm
├── tsconfig.json              # Configuração TypeScript
├── rollup.config.js           # Configuração do bundler
└── plugin.json                # Metadados do plugin
```

## 🎮 Como Usar

1. Abra o Decky Loader no Steam Deck
2. Encontre o plugin "Simple Browser" na lista
3. Clique no ícone do browser para abrir
4. Use a barra de endereços para navegar
5. Use os botões de navegação (voltar, avançar, home, refresh)

## 🌐 Funcionalidades do Browser

- **Navegação básica**: Voltar, avançar, refresh e home
- **Barra de endereços**: Suporte a URLs completas ou busca no Google
- **Auto-detecção de protocolo**: Adiciona automaticamente `https://` se necessário
- **Interface responsiva**: Otimizada para o Steam Deck
- **WebView nativo**: Performance otimizada

## 🔒 Segurança

- User-Agent personalizado para compatibilidade
- Suporte a popups controlado
- Navegação em ambiente isolado

## 🐛 Troubleshooting

### Plugin não aparece no Decky
- Verifique se o Decky Loader foi reiniciado após a instalação
- Confirme se os arquivos estão em `$HOME/homebrew/plugins/decky-browser/`
- Verifique os logs do Decky Loader

### Erro de build
- Certifique-se de que o Docker está rodando
- Execute `./build.sh clean` e tente novamente
- Verifique se tem espaço em disco suficiente

### WebView não carrega
- Verifique a conexão de internet
- Alguns sites podem bloquear WebViews
- Tente uma URL diferente

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📝 Licença

Este projeto está licenciado sob a GPL-2.0 License - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👏 Reconhecimentos

- [Decky Loader](https://github.com/SteamDeckHomebrew/decky-loader) - Framework de plugins
- Comunidade Steam Deck Homebrew
- Contribuidores do projeto

---

**Nota**: Este é um browser básico para uso casual. Para navegação intensiva, recomenda-se usar o browser nativo do Steam Deck.
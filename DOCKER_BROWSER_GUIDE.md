# 🐳 Browser Isolado em Docker - Guia Completo

## 🎯 Por que usar Browser Docker?

### **Problema das Atualizações do Steam Deck:**
- Atualizações do SteamOS podem quebrar plugins
- WebView integrado depende do sistema do Steam Deck
- Bibliotecas do sistema podem mudar com updates

### **Solução: Browser em Container Isolado:**
- ✅ **Independente do sistema**: Roda em container Docker separado
- ✅ **À prova de atualizações**: Não é afetado por updates do Steam Deck
- ✅ **Browser completo**: Chromium full-featured
- ✅ **Persistente**: Dados e configurações mantidos
- ✅ **Isolado**: Ambiente seguro e controlado

## 🚀 Instalação e Uso

### **Método 1: Instalação Automática**
```bash
# Instalar tudo (plugin + browser Docker)
./docker-browser.sh install
```

### **Método 2: Passo a Passo**
```bash
# 1. Buildar imagem Docker
./docker-browser.sh build

# 2. Iniciar container
./docker-browser.sh start

# 3. Buildar e instalar plugin
./build-simple.sh install
```

### **No Steam Deck:**
1. Abrir Decky Loader
2. Procurar "Simple Browser"
3. Escolher **"Browser Isolado (Docker)"**
4. Container inicia automaticamente
5. Browser completo disponível!

## 🔧 Gerenciamento do Container

### **Comandos do docker-browser.sh:**
```bash
./docker-browser.sh build      # Buildar imagem
./docker-browser.sh start      # Iniciar container
./docker-browser.sh stop       # Parar container
./docker-browser.sh restart    # Reiniciar container
./docker-browser.sh status     # Ver status
./docker-browser.sh logs       # Ver logs
./docker-browser.sh clean      # Limpar tudo
./docker-browser.sh install    # Instalação completa
```

### **Acesso Direto:**
- **Web Interface**: http://localhost:6080
- **VNC Direct**: localhost:5901 (senha: decky123)

## 🏗️ Arquitetura do Sistema

### **Componentes:**
```
┌─────────────────────────────────────────────┐
│              Steam Deck                     │
│  ┌─────────────────────────────────────┐    │
│  │         Decky Loader                │    │
│  │  ┌─────────────────────────────┐    │    │
│  │  │     Browser Plugin          │    │    │
│  │  │  ┌─────────────────────┐    │    │    │
│  │  │  │   WebView Mode      │    │    │    │
│  │  │  └─────────────────────┘    │    │    │
│  │  │  ┌─────────────────────┐    │    │    │
│  │  │  │   Docker Mode       │◄───┼────┼────┼─┐
│  │  │  └─────────────────────┘    │    │    │ │
│  │  └─────────────────────────────┘    │    │ │
│  └─────────────────────────────────────┘    │ │
└─────────────────────────────────────────────┘ │
                                                │
┌─────────────────────────────────────────────┐ │
│            Docker Container                 │ │
│  ┌─────────────────────────────────────┐    │ │
│  │         Browser Isolado             │◄───┘
│  │                                     │
│  │  • Chromium Browser                 │
│  │  • X Virtual Framebuffer           │
│  │  • VNC Server                       │
│  │  • noVNC Web Interface              │
│  │  • Dados persistentes              │
│  └─────────────────────────────────────┘
└─────────────────────────────────────────────┘
```

### **Fluxo de Funcionamento:**
1. **Plugin detecta** se Docker está disponível
2. **Verifica status** do container browser
3. **Inicia container** se necessário (automático)
4. **Conecta via iframe** ao noVNC (port 6080)
5. **Usuario navega** normalmente no browser

## 🔒 Segurança e Isolamento

### **Benefícios de Segurança:**
- Browser roda em ambiente isolado
- Sem acesso direto ao sistema Steam Deck
- Dados do browser separados do sistema
- Container pode ser removido/recriado facilmente

### **Configurações de Segurança:**
- Container sem privilégios elevados
- Acesso limitado ao sistema host
- Dados persistentes em volume Docker
- Comunicação apenas via portas definidas

## 📊 Comparação: WebView vs Docker

| Aspecto | WebView Nativo | Browser Docker |
|---------|----------------|----------------|
| **Performance** | ⭐⭐⭐ Rápido | ⭐⭐ Bom |
| **Recursos** | ⭐⭐ Básico | ⭐⭐⭐ Completo |
| **Isolamento** | ❌ Integrado | ✅ Total |
| **Atualizações** | ❌ Vulnerável | ✅ À prova |
| **Persistência** | ❌ Temporário | ✅ Persistente |
| **Uso de RAM** | ⭐⭐⭐ Baixo | ⭐⭐ Médio |
| **Compatibilidade** | ⭐⭐ Limitada | ⭐⭐⭐ Total |

## 🛠️ Configuração Avançada

### **Personalizar Container:**
Edite o `Dockerfile.browser` para:
- Adicionar extensões
- Modificar configurações do Chromium
- Instalar plugins adicionais
- Configurar proxy/VPN

### **Portas Customizadas:**
```bash
# Modificar docker-compose.browser.yml
ports:
  - "8080:6080"  # Web interface
  - "5902:5901"  # VNC
```

### **Volume Persistente:**
```bash
# Ver dados do browser
docker volume inspect decky-browser_browser_data

# Backup dos dados
docker run --rm -v decky-browser_browser_data:/data -v $(pwd):/backup ubuntu tar czf /backup/browser-backup.tar.gz -C /data .
```

## 🐛 Troubleshooting

### **Container não inicia:**
```bash
# Verificar logs
./docker-browser.sh logs

# Verificar status do Docker
docker --version
systemctl status docker
```

### **Browser não carrega:**
```bash
# Verificar se container está rodando
./docker-browser.sh status

# Testar acesso direto
curl http://localhost:6080
```

### **Erro de permissão:**
```bash
# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER
# Reiniciar sessão
```

### **Limpeza completa:**
```bash
# Remover tudo e recomeçar
./docker-browser.sh clean
./docker-browser.sh install
```

## 💡 Dicas e Truques

### **Performance:**
- Container usa ~200-400MB RAM
- Melhor performance com SSD
- Fechar abas desnecessárias

### **Navegação:**
- Use trackpad direito para scroll
- Ctrl+T para nova aba
- Ctrl+W para fechar aba
- F11 para fullscreen

### **Desenvolvimento:**
- Logs em `/var/log/supervisor/`
- Configurações em `/home/browser/.config/chromium`
- Modificar `browser-start.sh` para customizações

---

## 🎉 Resultado Final

Com o browser Docker você tem:

✅ **Browser completo e isolado**  
✅ **À prova de atualizações do Steam Deck**  
✅ **Persistência de dados e configurações**  
✅ **Ambiente seguro e controlado**  
✅ **Acesso via plugin ou web direto**  
✅ **Fácil gerenciamento e manutenção**

**Perfeito para uso intensivo no Steam Deck!** 🎮
# 📦 Instalação via ZIP no Steam Deck

## 🎯 Guia Rápido de Instalação

### ✅ Pré-requisitos
- Steam Deck com Decky Loader instalado
- Arquivo `decky-browser-plugin.zip` (já criado pelo script)

### 📱 Passo a Passo no Steam Deck

#### **Método 1: Instalação Automática (Recomendado)**

1. **Transferir o arquivo ZIP**
   - Copie `decky-browser-plugin.zip` para o Steam Deck
   - Pode usar USB, rede, ou download direto

2. **Extrair o arquivo**
   - Vá para o modo desktop (ícone do desktop no Steam)
   - Abra o gerenciador de arquivos (Dolphin)
   - Navegue até onde está o ZIP
   - Clique com botão direito → "Extrair aqui"

3. **Executar instalação**
   - Entre na pasta extraída
   - Clique duas vezes em `install.sh`
   - OU abra terminal e digite: `bash install.sh`

4. **Ativar o plugin**
   - Volte para o modo gaming
   - Reinicie o Steam Deck OU
   - Menu rápido (...) → Configurações → Plugins → Reload

#### **Método 2: Instalação Manual**

Se o script automático não funcionar:

1. **Extrair o ZIP** (mesmo processo acima)

2. **Copiar arquivos manualmente**
   - Abra o gerenciador de arquivos
   - Navegue até: `/home/deck/homebrew/plugins/`
   - Crie pasta: `decky-browser`
   - Copie todos os arquivos da pasta extraída para:
     `/home/deck/homebrew/plugins/decky-browser/`

3. **Verificar arquivos**
   - Certifique-se que estão presentes:
     - `index.js`
     - `main.py`  
     - `plugin.json`

4. **Reiniciar**
   - Reinicie o Steam Deck ou reload no Decky

### 🎮 Como Usar

1. **Abrir o plugin**
   - Menu rápido (...) no Steam Deck
   - Procure "Simple Browser" na lista
   - Clique no ícone de globo 🌐

2. **Navegar**
   - Use a barra de endereços
   - Botões: ← → ↻ 🏠
   - Digite URLs ou termos de busca

### 🔧 Localizações Importantes

```
Steam Deck paths:
├── Decky Loader: /home/deck/homebrew/
├── Plugins: /home/deck/homebrew/plugins/
└── Este plugin: /home/deck/homebrew/plugins/decky-browser/
```

### 🐛 Solução de Problemas

#### Plugin não aparece
- Verifique se está em `/home/deck/homebrew/plugins/decky-browser/`
- Confira se tem os 3 arquivos essenciais
- Reinicie o Steam Deck

#### Erro de instalação
- Tente instalação manual
- Verifique se Decky Loader está funcionando
- Logs em: Configurações → Plugins → View Logs

#### Browser não abre
- Verifique conexão de internet
- Tente URLs diferentes
- Reinicie o plugin

### 📋 Arquivos do ZIP

O arquivo `decky-browser-plugin.zip` contém:

- ✅ `index.js` - Frontend compilado (obrigatório)
- ✅ `main.py` - Backend Python (obrigatório)
- ✅ `plugin.json` - Configurações (obrigatório)
- 📜 `install.sh` - Script de instalação automática
- 📖 `README-INSTALL.txt` - Instruções detalhadas
- 📦 `package.json` - Metadados do plugin

### 🎯 Dicas

- **Use WiFi estável** durante a instalação
- **Modo desktop** é necessário para instalação
- **Backups**: O Decky permite desativar plugins facilmente
- **Atualizações**: Substitua os arquivos para atualizar

---

## 🚀 Comandos Úteis (Se necessário)

No terminal do Steam Deck:

```bash
# Verificar se Decky está instalado
ls -la /home/deck/homebrew/

# Verificar plugins instalados  
ls -la /home/deck/homebrew/plugins/

# Ver logs do Decky
journalctl -u plugin_loader -f

# Permissões (se necessário)
chmod 644 /home/deck/homebrew/plugins/decky-browser/*
```

---

**💡 Nota**: O arquivo ZIP já está pronto para uso! Basta transferir para o Steam Deck e seguir as instruções.
# 🔧 Modo Dev - Instalação Automática via ZIP

## 🎯 O que é isso?

Este sistema permite que você **coloque um ZIP no modo dev do Decky Loader** e ele **automaticamente extraia e instale** o plugin!

## 🚀 Como usar no Steam Deck:

### **Passo 1: Preparar o ZIP**
```bash
# No seu computador, criar o ZIP
./create-zip.sh
```

### **Passo 2: Copiar para Steam Deck**
Transfira o arquivo `decky-browser-plugin.zip` para o Steam Deck

### **Passo 3: Modo Dev do Decky**
1. **Extrair o ZIP** em qualquer pasta (ex: `/home/deck/decky-browser/`)
2. **Abrir Decky Loader** no Steam Deck
3. **Configurações** → **Developer** → **Add Plugin**
4. **Apontar para a pasta** onde extraiu o ZIP
5. O sistema **detectará automaticamente** e **instalará** o plugin!

## 🔧 Como funciona:

### **Auto-detecção**
- O `main.py` detecta se há um ZIP na pasta
- Executa o `auto_install.py` automaticamente
- Extrai e instala os arquivos necessários
- Reinicia o plugin

### **Arquivos importantes**
- `auto_install.py` - Script de auto-instalação
- `dev_init.sh` - Inicializador para modo dev
- `main.py` - Backend com detecção automática

## 📁 Estrutura para Modo Dev:

```
pasta-extraida/
├── decky-browser-plugin.zip    # ZIP original (detectado)
├── auto_install.py             # Auto-instalador
├── dev_init.sh                 # Script de inicialização
├── main.py                     # Backend modificado
├── index.js                    # Frontend (fallback)
├── plugin.json                 # Configuração
└── install.sh                  # Instalador manual (backup)
```

## 🎮 Fluxo no Steam Deck:

1. **Extrair ZIP** em `/home/deck/meu-plugin/`
2. **Decky** → **Developer** → **Add Plugin** → apontar para `/home/deck/meu-plugin/`
3. **Sistema detecta** o ZIP dentro da pasta
4. **Automaticamente extrai** para `/home/deck/homebrew/plugins/decky-browser/`
5. **Plugin aparece** na lista normalmente!

## ⚙️ Configurações Especiais:

### **plugin.json** com flags de dev:
```json
{
  "name": "Simple Browser",
  "author": "Douglas Liao", 
  "description": "A simple browser plugin for Steam Deck - Auto-installs from ZIP",
  "flags": ["_dev"],
  "auto_install": true
}
```

### **main.py** com detecção:
- Detecta ZIP na pasta atual
- Executa auto-instalação automaticamente
- Logs detalhados para debug

## 🐛 Troubleshooting:

### **Plugin não instala automaticamente**
- Verifique se o ZIP está na mesma pasta
- Confira os logs: `journalctl -f -u plugin_loader`
- Execute manualmente: `python3 auto_install.py`

### **Erro de permissão**
```bash
chmod +x dev_init.sh
chmod +x auto_install.py
```

### **Modo dev não encontra**
- Certifique-se de apontar para a pasta **extraída**
- Não aponte para o ZIP diretamente

## 💡 Vantagens:

✅ **Fácil para usuários**: Só extrair e apontar  
✅ **Automático**: Não precisa copiar arquivos manualmente  
✅ **Compatível**: Funciona com modo dev normal  
✅ **Fallback**: Se falhar, ainda pode instalar manualmente  
✅ **Debug**: Logs detalhados para troubleshooting  

## 🎯 Casos de Uso:

- **Desenvolvimento**: Testar plugin rapidamente
- **Distribuição**: Facilitar instalação para usuários
- **Updates**: Atualizar plugin facilmente
- **Debug**: Testar diferentes versões

---

**🚀 Agora você pode usar o modo dev do Decky com instalação automática via ZIP!**
#!/bin/bash

# Script de inicialização para modo dev do Decky Loader
# Este script é executado automaticamente quando o plugin é carregado em modo dev

# Executar o auto-instalador Python
python3 auto_install.py

# Se a instalação foi bem-sucedida, continuar com o carregamento normal
if [ $? -eq 0 ]; then
    echo "✓ Auto-instalação concluída com sucesso!"
else
    echo "✗ Falha na auto-instalação. Verifique os logs."
fi
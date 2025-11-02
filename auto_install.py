#!/usr/bin/env python3

"""
Auto-installer para modo dev do Decky Loader
Este script detecta se existe um ZIP do plugin e o instala automaticamente
"""

import os
import sys
import zipfile
import shutil
import json
import subprocess
from pathlib import Path

# Cores para output
class Colors:
    GREEN = '\033[0;32m'
    RED = '\033[0;31m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

def log(message, color=Colors.BLUE):
    print(f"{color}{message}{Colors.NC}")

def log_success(message):
    log(f"✓ {message}", Colors.GREEN)

def log_error(message):
    log(f"✗ {message}", Colors.RED)

def log_warning(message):
    log(f"⚠ {message}", Colors.YELLOW)

def find_decky_home():
    """Encontra o diretório do Decky Loader"""
    possible_paths = [
        os.path.expanduser("~/homebrew"),
        "/home/deck/homebrew",
        os.environ.get("DECKY_HOME", "")
    ]
    
    for path in possible_paths:
        if path and os.path.exists(path):
            return path
    
    return None

def find_zip_file():
    """Procura por arquivo ZIP do plugin"""
    current_dir = Path.cwd()
    
    # Procurar por ZIP na pasta atual
    zip_files = list(current_dir.glob("*browser*.zip"))
    zip_files.extend(current_dir.glob("decky-*.zip"))
    
    if zip_files:
        return zip_files[0]
    
    return None

def extract_and_install_zip(zip_path, target_dir):
    """Extrai e instala o ZIP"""
    log(f"Extraindo {zip_path}...")
    
    # Criar diretório temporário
    temp_dir = Path("/tmp/decky_auto_install")
    if temp_dir.exists():
        shutil.rmtree(temp_dir)
    temp_dir.mkdir(parents=True)
    
    try:
        # Extrair ZIP
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(temp_dir)
        
        # Encontrar arquivos essenciais
        extracted_files = list(temp_dir.rglob("*"))
        
        # Procurar pelos arquivos necessários
        index_js = None
        main_py = None
        plugin_json = None
        
        for file_path in extracted_files:
            if file_path.name == "index.js":
                index_js = file_path
            elif file_path.name == "main.py":
                main_py = file_path
            elif file_path.name == "plugin.json":
                plugin_json = file_path
        
        if not all([index_js, main_py, plugin_json]):
            log_error("Arquivos essenciais não encontrados no ZIP!")
            return False
        
        # Criar diretório do plugin
        target_path = Path(target_dir)
        target_path.mkdir(parents=True, exist_ok=True)
        
        # Copiar arquivos
        log("Copiando arquivos...")
        shutil.copy2(index_js, target_path)
        shutil.copy2(main_py, target_path)
        shutil.copy2(plugin_json, target_path)
        
        # Copiar outros arquivos se existirem
        for file_path in extracted_files:
            if file_path.is_file() and file_path.name not in ["index.js", "main.py", "plugin.json", "install.sh", "README-INSTALL.txt"]:
                try:
                    shutil.copy2(file_path, target_path)
                except:
                    pass  # Ignorar erros de arquivos opcionais
        
        log_success("Arquivos copiados com sucesso!")
        return True
        
    except Exception as e:
        log_error(f"Erro ao extrair ZIP: {e}")
        return False
    finally:
        # Limpar diretório temporário
        if temp_dir.exists():
            shutil.rmtree(temp_dir)

def check_existing_installation(plugin_dir):
    """Verifica se o plugin já está instalado"""
    required_files = ["index.js", "main.py", "plugin.json"]
    
    for file_name in required_files:
        if not os.path.exists(os.path.join(plugin_dir, file_name)):
            return False
    
    return True

def create_dev_symlink(source_dir, target_dir):
    """Cria um symlink para modo dev"""
    try:
        if os.path.exists(target_dir):
            if os.path.islink(target_dir):
                os.unlink(target_dir)
            else:
                shutil.rmtree(target_dir)
        
        os.symlink(source_dir, target_dir)
        log_success(f"Symlink criado: {target_dir} -> {source_dir}")
        return True
    except Exception as e:
        log_error(f"Erro ao criar symlink: {e}")
        return False

def main():
    log("=== Auto-instalador Decky Browser Plugin ===")
    
    # Encontrar Decky Loader
    decky_home = find_decky_home()
    if not decky_home:
        log_error("Decky Loader não encontrado!")
        log("Instale o Decky Loader primeiro: https://deckbrew.xyz")
        return 1
    
    log(f"Decky Loader encontrado em: {decky_home}")
    
    plugin_dir = os.path.join(decky_home, "plugins", "decky-browser")
    
    # Verificar se já está instalado
    if check_existing_installation(plugin_dir):
        log_success("Plugin já está instalado!")
        
        # Se estamos em modo dev, criar symlink para pasta atual
        current_dir = str(Path.cwd())
        if current_dir != plugin_dir:
            log("Criando symlink para modo dev...")
            create_dev_symlink(current_dir, plugin_dir)
        
        return 0
    
    # Procurar por ZIP
    zip_file = find_zip_file()
    if zip_file:
        log(f"ZIP encontrado: {zip_file}")
        
        if extract_and_install_zip(zip_file, plugin_dir):
            log_success("Plugin instalado automaticamente!")
            
            # Tentar recarregar Decky Loader
            try:
                log("Tentando recarregar Decky Loader...")
                subprocess.run(["systemctl", "--user", "restart", "plugin_loader"], 
                             capture_output=True, check=False)
            except:
                pass
            
            log_warning("Reinicie o Decky Loader para ver o plugin.")
            return 0
        else:
            log_error("Falha na instalação do ZIP!")
            return 1
    
    # Se chegou aqui, verificar se há arquivos built localmente
    current_dir = Path.cwd()
    if (current_dir / "index.js").exists() and (current_dir / "main.py").exists():
        log("Arquivos built encontrados localmente, copiando...")
        
        try:
            os.makedirs(plugin_dir, exist_ok=True)
            shutil.copy2(current_dir / "index.js", plugin_dir)
            shutil.copy2(current_dir / "main.py", plugin_dir)
            
            if (current_dir / "plugin.json").exists():
                shutil.copy2(current_dir / "plugin.json", plugin_dir)
            
            log_success("Plugin instalado a partir dos arquivos locais!")
            return 0
            
        except Exception as e:
            log_error(f"Erro ao copiar arquivos locais: {e}")
            return 1
    
    log_error("Nenhum método de instalação disponível!")
    log("Certifique-se de que:")
    log("1. Existe um arquivo ZIP do plugin na pasta atual, OU")
    log("2. Os arquivos index.js, main.py e plugin.json estão na pasta atual")
    return 1

if __name__ == "__main__":
    sys.exit(main())
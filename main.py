import asyncio
import decky_plugin
import os
import sys
import subprocess
import json
import aiohttp
from pathlib import Path

class Plugin:
    def __init__(self):
        self.container_name = "decky-browser-isolated"
        self.browser_port = 6080
        self.browser_url = f"http://localhost:{self.browser_port}"

    # Asyncio-compatible long-running code, executed in a task when the plugin is loaded
    async def _main(self):
        decky_plugin.logger.info("Decky Browser Plugin loaded!")
        
        # Verificar se estamos em modo dev e executar auto-instalação se necessário
        await self._check_dev_mode_and_auto_install()
        
        # Verificar status do container Docker
        await self._check_docker_availability()

    async def _check_docker_availability(self):
        """Verifica se Docker está disponível"""
        try:
            result = subprocess.run(["docker", "--version"], 
                                  capture_output=True, text=True, timeout=5)
            if result.returncode == 0:
                decky_plugin.logger.info("Docker detectado e disponível")
                return True
            else:
                decky_plugin.logger.warning("Docker não encontrado")
                return False
        except Exception as e:
            decky_plugin.logger.warning(f"Docker não disponível: {e}")
            return False

    async def check_browser_container(self):
        """Verifica se o container do browser está rodando"""
        try:
            # Verificar se container existe e está rodando
            result = subprocess.run([
                "docker", "ps", "--format", "json", 
                "--filter", f"name={self.container_name}"
            ], capture_output=True, text=True, timeout=10)
            
            if result.returncode == 0 and result.stdout.strip():
                # Container está rodando
                container_info = json.loads(result.stdout.strip())
                
                # Verificar se a porta está acessível
                try:
                    async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=5)) as session:
                        async with session.get(self.browser_url) as response:
                            if response.status == 200:
                                return {
                                    "running": True,
                                    "url": self.browser_url,
                                    "container_id": container_info.get("ID", ""),
                                    "status": "healthy"
                                }
                except Exception:
                    pass
                
                return {
                    "running": True,
                    "url": self.browser_url,
                    "container_id": container_info.get("ID", ""),
                    "status": "starting"
                }
            else:
                return {
                    "running": False,
                    "url": "",
                    "container_id": "",
                    "status": "stopped"
                }
                
        except Exception as e:
            decky_plugin.logger.error(f"Erro ao verificar container: {e}")
            return {
                "running": False,
                "url": "",
                "container_id": "",
                "status": "error",
                "error": str(e)
            }

    async def start_browser_container(self):
        """Inicia o container do browser"""
        try:
            decky_plugin.logger.info("Iniciando container do browser...")
            
            # Parar container existente se houver
            await self._stop_container_if_exists()
            
            # Obter diretório do plugin
            plugin_dir = Path(__file__).parent
            compose_file = plugin_dir / "docker-compose.browser.yml"
            
            if not compose_file.exists():
                # Criar compose file se não existir
                await self._create_compose_file(plugin_dir)
            
            # Iniciar container usando docker-compose
            result = subprocess.run([
                "docker-compose", "-f", str(compose_file),
                "up", "-d", "decky-browser-container"
            ], capture_output=True, text=True, timeout=60)
            
            if result.returncode == 0:
                decky_plugin.logger.info("Container iniciado com sucesso")
                
                # Aguardar container ficar pronto
                await self._wait_for_container_ready()
                
                return {
                    "success": True,
                    "url": self.browser_url,
                    "message": "Container iniciado com sucesso"
                }
            else:
                error_msg = result.stderr or result.stdout
                decky_plugin.logger.error(f"Erro ao iniciar container: {error_msg}")
                return {
                    "success": False,
                    "error": error_msg
                }
                
        except Exception as e:
            decky_plugin.logger.error(f"Erro ao iniciar container: {e}")
            return {
                "success": False,
                "error": str(e)
            }

    async def _stop_container_if_exists(self):
        """Para container existente se houver"""
        try:
            subprocess.run([
                "docker", "stop", self.container_name
            ], capture_output=True, timeout=30)
            
            subprocess.run([
                "docker", "rm", self.container_name
            ], capture_output=True, timeout=30)
        except Exception:
            pass  # Ignorar erros se container não existir

    async def _wait_for_container_ready(self, max_wait=30):
        """Aguarda container ficar pronto"""
        for i in range(max_wait):
            try:
                async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=2)) as session:
                    async with session.get(self.browser_url) as response:
                        if response.status == 200:
                            return True
            except Exception:
                pass
            
            await asyncio.sleep(1)
        
        return False

    async def _create_compose_file(self, plugin_dir):
        """Cria arquivo docker-compose se não existir"""
        compose_content = f"""version: '3.8'

services:
  decky-browser-container:
    image: decky-browser:latest
    container_name: {self.container_name}
    ports:
      - "{self.browser_port}:{self.browser_port}"
      - "5901:5901"
    volumes:
      - browser_data:/home/browser/.config/chromium
    environment:
      - DISPLAY=:1
    restart: unless-stopped
    security_opt:
      - seccomp:unconfined

volumes:
  browser_data:
    driver: local
"""
        
        compose_file = plugin_dir / "docker-compose.browser.yml"
        with open(compose_file, 'w') as f:
            f.write(compose_content)

    async def restart_browser_container(self):
        """Reinicia o container do browser"""
        try:
            decky_plugin.logger.info("Reiniciando container do browser...")
            
            # Parar container
            await self._stop_container_if_exists()
            
            # Aguardar um pouco
            await asyncio.sleep(2)
            
            # Iniciar novamente
            return await self.start_browser_container()
            
        except Exception as e:
            decky_plugin.logger.error(f"Erro ao reiniciar container: {e}")
            return {
                "success": False,
                "error": str(e)
            }

    async def navigate_browser(self, url: str):
        """Navega para uma URL no browser do container"""
        try:
            # Para navegação, podemos usar comandos JavaScript via API se disponível
            # Por enquanto, apenas registrar a navegação
            decky_plugin.logger.info(f"Navegando para: {url}")
            
            # Em uma implementação completa, poderíamos:
            # 1. Usar API do browser via WebDriver
            # 2. Enviar comandos via WebSocket
            # 3. Manipular via JavaScript injection
            
            return {
                "success": True,
                "url": url
            }
            
        except Exception as e:
            decky_plugin.logger.error(f"Erro ao navegar: {e}")
            return {
                "success": False,
                "error": str(e)
            }

    async def _check_dev_mode_and_auto_install(self):
        """Verifica modo dev e executa auto-instalação se necessário"""
        try:
            # Verificar se estamos em modo dev
            current_file = Path(__file__)
            plugin_dir = current_file.parent
            
            # Se há um ZIP na pasta do plugin, significa que pode precisar de instalação
            zip_files = list(plugin_dir.glob("*browser*.zip"))
            zip_files.extend(plugin_dir.glob("decky-*.zip"))
            
            if zip_files:
                decky_plugin.logger.info("ZIP detectado, verificando se auto-instalação é necessária...")
                
                # Verificar se o auto_install.py existe e executá-lo
                auto_install_script = plugin_dir / "auto_install.py"
                if auto_install_script.exists():
                    import subprocess
                    result = subprocess.run([sys.executable, str(auto_install_script)], 
                                          capture_output=True, text=True)
                    
                    if result.returncode == 0:
                        decky_plugin.logger.info("Auto-instalação concluída com sucesso!")
                    else:
                        decky_plugin.logger.warning(f"Auto-instalação falhou: {result.stderr}")
                
        except Exception as e:
            decky_plugin.logger.error(f"Erro na verificação de modo dev: {e}")

    async def _unload(self):
        decky_plugin.logger.info("Decky Browser Plugin unloaded!")

    # Function called first during the unload process, utilize this to handle your plugin being removed
    async def _uninstall(self):
        decky_plugin.logger.info("Decky Browser Plugin uninstalled!")
        
        # Opcionalmente parar container ao desinstalar
        try:
            await self._stop_container_if_exists()
        except Exception:
            pass

    async def get_browser_settings(self):
        """Get browser settings"""
        try:
            # Aqui você poderia carregar configurações salvas
            return {
                "homepage": "https://www.google.com",
                "allow_popups": True,
                "user_agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
            }
        except Exception as e:
            decky_plugin.logger.error(f"Error getting browser settings: {e}")
            return {}

    async def save_browser_settings(self, settings: dict):
        """Save browser settings"""
        try:
            # Aqui você poderia salvar as configurações
            decky_plugin.logger.info(f"Saving browser settings: {settings}")
            return True
        except Exception as e:
            decky_plugin.logger.error(f"Error saving browser settings: {e}")
            return False

    async def get_bookmarks(self):
        """Get user bookmarks"""
        try:
            # Retorna bookmarks pré-definidos por enquanto
            return [
                {"name": "Google", "url": "https://www.google.com"},
                {"name": "GitHub", "url": "https://github.com"},
                {"name": "YouTube", "url": "https://www.youtube.com"},
                {"name": "Reddit", "url": "https://www.reddit.com"},
                {"name": "Steam Store", "url": "https://store.steampowered.com"}
            ]
        except Exception as e:
            decky_plugin.logger.error(f"Error getting bookmarks: {e}")
            return []

    async def add_bookmark(self, name: str, url: str):
        """Add a new bookmark"""
        try:
            # Aqui você poderia salvar o bookmark
            decky_plugin.logger.info(f"Adding bookmark: {name} - {url}")
            return True
        except Exception as e:
            decky_plugin.logger.error(f"Error adding bookmark: {e}")
            return False

    async def remove_bookmark(self, url: str):
        """Remove a bookmark"""
        try:
            # Aqui você poderia remover o bookmark
            decky_plugin.logger.info(f"Removing bookmark: {url}")
            return True
        except Exception as e:
            decky_plugin.logger.error(f"Error removing bookmark: {e}")
            return False

    async def clear_browser_data(self):
        """Clear browser data (cache, cookies, etc.)"""
        try:
            # Aqui você poderia implementar limpeza de dados
            decky_plugin.logger.info("Clearing browser data")
            return True
        except Exception as e:
            decky_plugin.logger.error(f"Error clearing browser data: {e}")
            return False
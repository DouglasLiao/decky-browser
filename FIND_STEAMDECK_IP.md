# 🔍 Como Encontrar o IP do Steam Deck para SSH

## 📱 **Método 1: Interface Gráfica do Steam Deck**

### No Steam Deck:
1. **Modo Desktop**: Pressione `Steam + X` para sair do modo Gaming
2. **Configurações de Rede**:
   - Clique no ícone de rede (Wi-Fi/Ethernet) na barra inferior
   - Ou vá em `Sistema > Configurações > Rede`
3. **Ver Detalhes**:
   - Clique na rede conectada
   - Procure por "Endereço IPv4" ou "IP Address"
   - Anote o IP (ex: `192.168.1.100`)

## 💻 **Método 2: Terminal no Steam Deck**

### Abrir Terminal (Konsole):
1. No modo Desktop, pressione `Ctrl + Alt + T`
2. Ou procure por "Konsole" no menu de aplicativos

### Comandos para encontrar IP:
```bash
# Comando mais simples
ip addr show | grep inet

# Ou mais específico para Wi-Fi
ip addr show wlan0 | grep inet

# Ou para Ethernet
ip addr show eth0 | grep inet

# Comando alternativo
hostname -I

# Ver todas as interfaces
ifconfig
```

## 🌐 **Método 3: Do Seu Computador**

### Escanear a rede local:
```bash
# Descobrir sua rede (ex: 192.168.1.0/24)
ip route | grep default

# Escanear dispositivos na rede
nmap -sn 192.168.1.0/24 | grep -B2 -A1 "deck"

# Ou usar arp
arp -a | grep -i deck
```

### Ping para testar:
```bash
# Testar se o IP responde
ping 192.168.1.100

# Testar SSH especificamente
ssh deck@192.168.1.100 "echo 'Conexão OK'"
```

## 🔧 **Método 4: Habilitar SSH no Steam Deck**

### Se SSH não estiver funcionando:
```bash
# No Steam Deck (Konsole):
sudo systemctl enable sshd
sudo systemctl start sshd

# Definir senha para usuário deck (se necessário)
passwd

# Verificar se SSH está rodando
sudo systemctl status sshd

# Ver portas abertas
ss -tlnp | grep :22
```

## 📋 **Exemplo Prático Completo**

### 1. No Steam Deck (encontrar IP):
```bash
# Abrir Konsole e executar:
ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1
```

### 2. Do seu computador (testar conexão):
```bash
# Substituir IP_ENCONTRADO pelo IP real
ping IP_ENCONTRADO

# Testar SSH
ssh deck@IP_ENCONTRADO
```

### 3. Transferir arquivo:
```bash
# No diretório do projeto
scp decky-browser-20251102-103556.zip deck@IP_ENCONTRADO:~/Downloads/
```

## 🔍 **Identificar o Steam Deck na Rede**

### Características típicas:
- **Hostname**: `steamdeck` ou `deck`
- **MAC Address**: Começa com `02:00:00` (Steam Deck)
- **Sistema**: Arch Linux
- **Serviços**: SSH na porta 22

### Comando para identificar:
```bash
# Escanear e mostrar hostnames
nmap -sn 192.168.1.0/24 | grep -B1 -A1 "steamdeck\|deck"

# Ver tabela ARP com nomes
arp -a
```

## ⚡ **Script Rápido para Encontrar Steam Deck**

```bash
#!/bin/bash
echo "🔍 Procurando Steam Deck na rede..."

# Descobrir rede local
NETWORK=$(ip route | grep default | awk '{print $3}' | sed 's/\.[0-9]*$/.0\/24/')

echo "📡 Escaneando rede: $NETWORK"

# Escanear
nmap -sn $NETWORK 2>/dev/null | grep -B1 -A1 "steamdeck\|deck" || {
    echo "🤔 Steam Deck não encontrado por hostname"
    echo "📋 Dispositivos encontrados:"
    nmap -sn $NETWORK 2>/dev/null | grep "Nmap scan report"
}
```

## 💡 **Dicas Importantes**

### ✅ **Antes de conectar**:
- Steam Deck deve estar no **modo Desktop**
- **Wi-Fi/Ethernet conectado** à mesma rede
- **SSH habilitado** (comando acima)
- **Senha definida** para usuário `deck`

### 🔧 **Solução de problemas**:
```bash
# Se não conseguir conectar:
sudo systemctl restart sshd

# Se porta 22 estiver ocupada:
sudo ss -tlnp | grep :22

# Ver logs de SSH:
sudo journalctl -u sshd -f
```

### 🎯 **IPs mais comuns**:
- `192.168.1.x` (redes domésticas)
- `192.168.0.x` (alguns roteadores)
- `10.0.0.x` (algumas redes empresariais)

**Tente esses métodos e me diga qual IP você encontrou!** 🚀
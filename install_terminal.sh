#!/bin/bash

echo "🚀 Iniciando a instalação do ambiente de terminal..."

# 1. Instalar pacotes do sistema via DNF
echo "📦 Instalando pacotes base..."
sudo dnf install -y zsh fzf bat git curl util-linux-user kitty tar xdg-utils

# 2. Instalar Oh My Zsh (modo autônomo garantido)
echo "🐚 Instalando Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  # A flag --unattended é o padrão moderno e evita que a instalação trave
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "✅ Oh My Zsh já está instalado."
fi

# 3. Baixar Powerlevel10k e Plugins
echo "🔌 Baixando tema e plugins..."
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Trava de segurança: Garante que as pastas base existem antes de clonar
mkdir -p "$ZSH_CUSTOM/themes"
mkdir -p "$ZSH_CUSTOM/plugins"

if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# 4. Extrair as configurações personalizadas
echo "📂 Baixando configurações do GitHub..."

# Link direto para o seu repositório (Assumindo que a branch principal é 'main')
GITHUB_TAR_URL="https://raw.githubusercontent.com/murillous/fedora-terminal-dotfiles/main/terminal-setup.tar.gz"

# O parâmetro -f (fail) faz o curl avisar se der erro 404
curl -L -f -o "$HOME/terminal-setup.tar.gz" "$GITHUB_TAR_URL"

if [ -f "$HOME/terminal-setup.tar.gz" ]; then
  echo "✅ Arquivo baixado com sucesso! Extraindo..."
  mkdir -p "$HOME/.local/share/fonts"

  tar -xzvf "$HOME/terminal-setup.tar.gz" -C "$HOME"

  echo "🔤 Atualizando cache de fontes..."
  fc-cache -f -v

  # Limpa o arquivo compactado para não ocupar espaço
  rm "$HOME/terminal-setup.tar.gz"
else
  echo "❌ ERRO CRÍTICO: Não foi possível baixar o terminal-setup.tar.gz do GitHub."
  echo "Verifique se o repositório é Público e se o link RAW está correto."
  exit 1
fi

# 5. Mudar o shell padrão no sistema (Fallback triplo)
echo "🔄 Configurando o Zsh como padrão..."
ZSH_PATH=$(which zsh)

# Tenta usar usermod (mais robusto no Fedora executando com sudo)
sudo usermod --shell "$ZSH_PATH" "$USER" 2>/dev/null || \
# Fallback para chsh se usermod falhar
sudo chsh -s "$ZSH_PATH" "$USER" 2>/dev/null

# 6. NVM + Node LTS
# PROFILE=/dev/null impede o instalador de editar o .zshrc (o carregamento do nvm já vem nas dotfiles)
echo "🟢 Instalando NVM e Node LTS..."
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash
fi
\. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'

# pnpm global, com permissão para rodar os scripts de instalação do próprio pnpm
echo "📦 Instalando o pnpm..."
grep -qx 'allow-scripts=pnpm' "$HOME/.npmrc" 2>/dev/null || echo 'allow-scripts=pnpm' >> "$HOME/.npmrc"
npm install -g pnpm

# 7. Claude Code + skills do Matt Pocock + Caveman
echo "🤖 Instalando Claude Code..."
export PATH="$HOME/.local/bin:$PATH"
if ! command -v claude >/dev/null 2>&1; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

echo "🧠 Instalando as skills do Matt Pocock..."
claude plugin marketplace add anthropics/claude-plugins-official 2>/dev/null
claude plugin install mattpocock-skills@claude-plugins-official

echo "🪨 Instalando o Caveman..."
# < /dev/tty: o script roda via "curl | bash", então perguntas não podem ler do stdin
npm install -g @caveman-ai/cli
caveman setup --install < /dev/tty
caveman setup --agent-native claude < /dev/tty

# 8. Docker + Docker Compose
echo "🐳 Instalando Docker e Docker Compose..."
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager addrepo --overwrite --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
# Permite usar o docker sem sudo (vale a partir do próximo login)
sudo usermod -aG docker "$USER"

# 9. Google Chrome como navegador padrão
echo "🌐 Instalando o Google Chrome..."
if ! rpm -q google-chrome-stable >/dev/null 2>&1; then
  # O RPM oficial também adiciona o repositório do Google para atualizações
  sudo dnf install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
fi
xdg-settings set default-web-browser google-chrome.desktop
xdg-mime default google-chrome.desktop x-scheme-handler/http x-scheme-handler/https text/html

# 10. Ajustes do KDE Plasma: Kitty como terminal padrão, Meta+Return e janelas instáveis
echo "🖥️  Configurando o KDE Plasma..."
kwriteconfig6 --file kdeglobals --group General --key TerminalApplication kitty
kwriteconfig6 --file kdeglobals --group General --key TerminalService kitty.desktop
kwriteconfig6 --file kglobalshortcutsrc --group services --group kitty.desktop --key _launch "Meta+Return"
kwriteconfig6 --file kwinrc --group Plugins --key wobblywindowsEnabled true
# Aplica o efeito na hora (o atalho vale a partir do próximo login)
dbus-send --session --type=method_call --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure 2>/dev/null

# 11. Chaves e configuração SSH
# As chaves NÃO ficam no repositório (ele é público). Elas são copiadas de uma pasta local,
# ex.: um pendrive ou backup. Informe via SSH_BACKUP_DIR ou digite quando for perguntado.
echo "🔑 Configurando o SSH..."
if [ -z "$SSH_BACKUP_DIR" ] && [ -r /dev/tty ]; then
  read -r -p "Caminho da pasta com o backup do .ssh (Enter para pular): " SSH_BACKUP_DIR < /dev/tty
fi

mkdir -p "$HOME/.ssh"
if [ -n "$SSH_BACKUP_DIR" ] && [ -d "$SSH_BACKUP_DIR" ]; then
  cp -r "$SSH_BACKUP_DIR"/. "$HOME/.ssh/"
  echo "✅ Arquivos SSH copiados de $SSH_BACKUP_DIR"
else
  echo "⏭️  Nenhuma pasta de backup SSH informada, pulando a cópia."
fi

# Permissões exigidas pelo OpenSSH: pasta 700, chaves privadas e config 600, públicas 644
chmod 700 "$HOME/.ssh"
find "$HOME/.ssh" -mindepth 1 -type d -exec chmod 700 {} +
find "$HOME/.ssh" -type f -exec chmod 600 {} +
find "$HOME/.ssh" -type f \( -name "*.pub" -o -name "known_hosts*" \) -exec chmod 644 {} +

echo "✅ Instalação concluída com sucesso no Fedora!"
echo "➡️  Nota: O Kitty já está configurado (via dotfiles) para forçar o uso do Zsh."
echo "⚠️  Faça logout e login de novo para valer o grupo docker e o atalho Meta+Return."

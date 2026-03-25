#!/bin/bash

echo "🚀 Iniciando a instalação do ambiente de terminal..."

# 1. Instalar pacotes do sistema via DNF
echo "📦 Instalando pacotes base..."
sudo dnf install -y zsh fzf bat git curl util-linux-user kitty tar

# 2. Instalar Oh My Zsh (modo autônomo)
echo "🐚 Instalando Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  env CHSH=no RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh já está instalado."
fi

# 3. Baixar Powerlevel10k e Plugins
echo "🔌 Baixando tema e plugins..."
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# 4. Baixar e extrair as configurações personalizadas
echo "📂 Baixando configurações do GitHub..."

# 👇 SUBSTITUA a URL abaixo pela URL RAW do seu terminal-setup.tar.gz no GitHub
GITHUB_TAR_URL="https://raw.githubusercontent.com/murillous/fedora-terminal-dotfiles/main/terminal-setup.tar.gz"

curl -L -o "$HOME/terminal-setup.tar.gz" "$GITHUB_TAR_URL"

if [ -f "$HOME/terminal-setup.tar.gz" ]; then
  mkdir -p "$HOME/.local/share/fonts"
  
  tar -xzvf "$HOME/terminal-setup.tar.gz" -C "$HOME"
  
  echo "🔤 Atualizando cache de fontes..."
  fc-cache -f -v
  
  # Limpa o arquivo baixado para não ocupar espaço
  rm "$HOME/terminal-setup.tar.gz"
else
  echo "⚠️ ATENÇÃO: Falha ao baixar o arquivo do GitHub!"
fi
# 5. Mudar o shell padrão no sistema (Fallback triplo)
echo "🔄 Configurando o Zsh como padrão..."
ZSH_PATH=$(which zsh)

# Tenta usar usermod (mais robusto no Fedora executando com sudo)
sudo usermod --shell "$ZSH_PATH" "$USER" 2>/dev/null || \
# Fallback para chsh se usermod falhar
sudo chsh -s "$ZSH_PATH" "$USER" 2>/dev/null

echo "✅ Instalação concluída com sucesso!"
echo "➡️  Nota: O Kitty já está configurado para forçar o uso do Zsh."

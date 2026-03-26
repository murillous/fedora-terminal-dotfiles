#!/bin/bash

echo "🚀 Iniciando a instalação do ambiente de terminal..."

# 1. Instalar pacotes do sistema via DNF
echo "📦 Instalando pacotes base..."
sudo dnf install -y zsh fzf bat git curl util-linux-user kitty tar

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

echo "✅ Instalação concluída com sucesso no Fedora 42!"
echo "➡️  Nota: O Kitty já está configurado (via dotfiles) para forçar o uso do Zsh."
echo "Feche este terminal e abra um novo para ver o ambiente pronto."

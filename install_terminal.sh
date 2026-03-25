# 4. Extrair as configurações personalizadas
echo "📂 Baixando configurações do GitHub..."

# Link direto e infalível para o seu repositório
GITHUB_TAR_URL="https://raw.githubusercontent.com/murillous/fedora-terminal-dotfiles/main/terminal-setup.tar.gz"

# O parâmetro -f (fail) faz o curl avisar se der erro 404
curl -L -f -o "$HOME/terminal-setup.tar.gz" "$GITHUB_TAR_URL"

if [ -f "$HOME/terminal-setup.tar.gz" ]; then
  echo "✅ Arquivo baixado com sucesso! Extraindo..."
  mkdir -p "$HOME/.local/share/fonts"
  
  tar -xzvf "$HOME/terminal-setup.tar.gz" -C "$HOME"
  
  echo "🔤 Atualizando cache de fontes..."
  fc-cache -f -v
  
  # Limpa a sujeira
  rm "$HOME/terminal-setup.tar.gz"
else
  echo "❌ ERRO CRÍTICO: Não foi possível baixar o terminal-setup.tar.gz do GitHub."
  echo "Verifique se o repositório é Público e se o link RAW está correto."
  exit 1
fi

#!/bin/bash

echo "🧹 Iniciando a remoção das personalizações do terminal..."

# 1. Voltar o shell padrão para o Bash
echo "🔄 Restaurando o bash como shell padrão..."
BASH_PATH=$(which bash)
sudo usermod --shell "$BASH_PATH" "$USER" 2>/dev/null || sudo chsh -s "$BASH_PATH" "$USER" 2>/dev/null

# 2. Remover Oh My Zsh, temas, plugins e configs do Zsh
echo "🗑️ Removendo Oh My Zsh e configurações do Zsh..."
rm -rf "$HOME/.oh-my-zsh"
rm -f "$HOME/.zshrc"
rm -f "$HOME/.p10k.zsh"
rm -f "$HOME/.zcompdump"* # Remove o cache de autocompletar do zsh

# 3. Remover configurações do Kitty
echo "🐈 Removendo configurações do Kitty..."
# Isso apaga a pasta do kitty inteira. Se o Kitty for aberto de novo, 
# ele recria essa pasta automaticamente com as configurações de fábrica.
rm -rf "$HOME/.config/kitty"

# 4. Remover as fontes personalizadas (CaskaydiaCove)
echo "🔤 Removendo as fontes CaskaydiaCove..."
if [ -d "$HOME/.local/share/fonts" ]; then
  # Apaga apenas os arquivos que têm Caskaydia no nome para não quebrar outras fontes
  find "$HOME/.local/share/fonts" -name "*Caskaydia*" -type f -delete
  echo "Atualizando cache de fontes..."
  fc-cache -f -v
fi

echo "✅ Personalizações removidas com sucesso!"
echo "➡️  Feche o terminal e abra novamente para voltar a usar o Bash padrão."

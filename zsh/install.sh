export ZSH="$HOME/.dotfiles/oh-my-zsh"

# Install oh-my-zsh
if [ ! -d "$HOME/.dotfiles/oh-my-zsh" ]; then
  (curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --unattended --keep-zshrc)
else
  echo "\t oh-my-zsh is already installed."
fi

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Node version manager
export NVM_DIR="$HOME/.nvm"

# .NET Configuration
export DOTNET_ROOT="/usr/local/share/dotnet"

export JAVA_HOME='/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home'
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)

# Set location for config files
export XDG_CONFIG_HOME="$HOME/.config"

# Set Starship config
export STARSHIP_CONFIG=$DOTFILES/config/starship/starship.toml

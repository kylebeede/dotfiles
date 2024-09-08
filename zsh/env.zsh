# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

export LDFLAGS="-L/usr/local/opt/ruby/lib"
export CPPFLAGS="-I/usr/local/opt/ruby/include"
export PKG_CONFIG_PATH="/usr/local/opt/ruby/lib/pkgconfig"
export NVM_DIR="$HOME/.nvm"
export DOTNET_ROOT="/usr/local/Cellar/dotnet/7.0.100/libexec"
export DOTNET_VERSION="7.0.100"
export MsBuildSDKsPath="/usr/local/Cellar/dotnet/7.0.100/libexec/sdk"
export BUN_INSTALL="$HOME/.bun"

# Set Starship config
export STARSHIP_CONFIG=$DOTFILES/config/starship/starship.toml

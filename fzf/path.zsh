# taken from ~/.fzf.zsh. Not sure how this works with oh-my-zsh plugin
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/usr/local/opt/fzf/bin"
fi

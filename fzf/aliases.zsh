# open fzf-selected files in Neovim
fzf_open_in_nvim() {
  local files
  files=$(fzf --multi)  # Allow multiple file selection
  if [[ -n "$files" ]]; then
    nvim $files
  fi
}

alias fn="fzf_open_in_nvim"

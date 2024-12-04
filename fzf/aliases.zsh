function fzf_open_in_nvim() {
  local dir="${1:-.}"
  local selected_files

  if [ ! -d "$dir" ]; then
    echo "Error: '$dir' is not a valid directory"
    return 1
  fi

  selected_files=$(cd "$dir" && find . -type f | sed 's|^\./||' | fzf --multi)

  if [ -n "$selected_files" ]; then
    echo "$selected_files" | xargs -I {} nvim "$dir/{}"
  fi
}

alias fid="fzf_open_in_nvim"

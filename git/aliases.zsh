# Use `hub` as git wrapper:
hub_path=$(which hub)
if (( $+commands[hub] ))
then
  alias git=$hub_path
fi

alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gp='git push origin master'

# Remove `+` and `-` from start of diff lines; just rely upon color.
alias gd='git diff --color | sed "s/^\([^-+ ]*\)[-+ ]/\\1/" | less -r'

alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit -a'
alias gcan='git commit -a --no-edit'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gb='git branch'
alias gs='git status -sb'
alias gac='git add -A && git commit -m'

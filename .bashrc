export PATH=/usr/local/bin:/usr/local/sbin:$PATH
export GPG_TTY=$(tty)

if [[ -d "${HOME}/.nvm" ]]; then
  export NVM_DIR="${HOME}/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
fi

export PATH="${PATH}:${HOME}/apprunner/AppRunner:${HOME}/.rvm/bin"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

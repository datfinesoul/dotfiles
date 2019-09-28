#!/usr/bin/env bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

function finish {
  echo .
}
trap finish EXIT

if [[ -d "${HOME}/.dotfiles" ]]; then
  git clone "https://github.com/datfinesoul/dotfiles.git" "${HOME}/.dotfiles"
else
  echo "${HOME}/.dotfiles already exits, EXIT";
  false
fi
cd "${HOME}/.dotfiles"

echo "core installed in ${HOME}/.dotfiles, run ./setup"

#!/usr/bin/env bash

set -o nounset; set -o errexit; set -o pipefail;

# all . files that are not vim swapfiles and not .gitignore
mapfile -t DOTFILES < <(find . -maxdepth 1 -type f -name ".*" ! -name ".*.swp" ! -name ".gitignore" -exec basename {} \;)
# append directories to array, ignore .git
mapfile -O ${#DOTFILES[@]} -t DOTFILES < <(find . -maxdepth 1 -type d -name ".*" ! -name ".git" ! -name "." -exec basename {} \;)
for INDEX in "${!DOTFILES[@]}"; do

	FILE="${DOTFILES[${INDEX}]}"
	BACKUP_FILE="$(readlink -f "./backup/${FILE}")"
	HOME_FILE="$(readlink -f "${HOME}/${FILE}")"
	DOT_FILE="$(readlink -f "./${FILE}")"

	# skip anything already in backup (this includes .gitignore always)
	if [[ -e "${BACKUP_FILE}" ]]; then
		echo ".. skip ${FILE}, backup already exists"
		continue
	fi
	# skip symlinked files
	if [[ -h "${HOME_FILE}" || "${HOME_FILE}" == "${DOT_FILE}" ]]; then
		echo ".. skip ${FILE}, already symlinked"
		continue
	fi
	# backup files
	if [[ -e "${HOME_FILE}" ]]; then
		echo ".. backup ${FILE}"
		\mv "${HOME_FILE}" "${BACKUP_FILE}"
	fi
	echo ".. link ${HOME_FILE} to ${DOT_FILE}"
	ln -s "${DOT_FILE}" "${HOME_FILE}"
	#printf "%s\t%s\n" "${INDEX}" "${FILE}"
done

# fix to not hardcode the .dotfiles path
BASE16=.config/base16-shell
rsync -avz $HOME/.dotfiles/ubuntu/$BASE16/ $HOME/$BASE16

KITTY=.config/kitty
rsync -avz $HOME/.dotfiles/ubuntu/$KITTY/ $HOME/$KITTY



#!/usr/bin/env bash

set -o nounset; set -o errexit; set -o pipefail;

# all . files that are not vim swapfiles
DOTFILES=($(find . -type f -name ".*" ! -name ".*.swp" -d 1 -exec basename {} \;))
for INDEX in "${!DOTFILES[@]}"; do
	FILE="${DOTFILES[${INDEX}]}"
	BACKUP_FILE="$(greadlink -f "./backup/${FILE}")"
	HOME_FILE="$(greadlink -f "${HOME}/${FILE}")"
	DOT_FILE="$(greadlink -f "./${FILE}")"
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
		\cp "${HOME_FILE}" "${BACKUP_FILE}"
	fi
	echo ".. link ${HOME_FILE} to ${DOT_FILE}"
	ln -s "${DOT_FILE}" "${HOME_FILE}"
	#printf "%s\t%s\n" "${INDEX}" "${FILE}"
done

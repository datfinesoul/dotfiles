#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

#### GENERAL PACKAGES
sudo apt-get -y install $(< ./install.packages)

#### Kitty

if [[ -f "$HOME/.local/kitty.app/bin/kitty" ]]; then
	echo -e '\n[x] skip kitty'
else
	curl -L https://sw.kovidgoyal.net/kitty/installer.sh | \
		sh /dev/stdin launch=n

	ln -sf $HOME/.local/kitty.app/bin/kitty $HOME/.local/bin/
	cp $HOME/.local/kitty.app/share/applications/kitty.desktop $HOME/.local/share/applications
	rsync -avz $HOME/.local/kitty.app/share/icons/* $HOME/.local/share/icons/

	sed -i "s/Icon\=kitty/Icon\=\/home\/$USER\/.local\/kitty.app\/share\/icons\/hicolor\/256x256\/apps\/kitty.png/g" \
		$HOME/.local/share/applications/kitty.desktop
fi

#### Enable F(x) keys by default on apple keyboards if driver is installed
# 0 = Fn key disabled
# 1 = Fn key pressed by default
# 2 = Fn key released by default
echo 2 | sudo tee /sys/module/hid_apple/parameters/fnmode
#!/usr/bin/env bash

cat $HOME/.local/share/applications/kitty.desktop | \
	sed -E "s/^(Icon=).*/\1${HOME//\//\\\/}\/.local\/kitty.app\/share\/icons\/256x256\/apps\/kitty.png/g"


#!/usr/bin/env bash

set -o nounset; set -o errexit; set -o pipefail;

[ -d /usr/share/fonts/opentype ] || sudo mkdir /usr/share/fonts/opentype
sudo git clone --depth 1 https://github.com/adobe-fonts/source-code-pro.git /usr/share/fonts/opentype/scp
sudo fc-cache -f -v
sudo rm -rf /usr/share/fonts/opentype/scp/.git*

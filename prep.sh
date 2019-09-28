#!/bin/bash
sudo apt -y install zsh ncdu pigz
sudo chsh -s $(which zsh) $USER
if [[ ! -d "$HOME/.bin" ]]; then mkdir $HOME/.bin; fi
source <(curl -s https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)
curl -Lso $HOME/.bin/termupdate.sh && chmod +x $HOME/.bin/termupdate.sh && $HOME/.bin/termupdate.sh
# source <(curl -s https://seanhelling.com/sh/update-term.sh)
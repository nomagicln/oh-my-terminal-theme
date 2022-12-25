#!/usr/bin/env zsh
cd $(dirname $(realpath $0))
cp -f themes/nomagic.zsh-theme ${ZSH}/custom/themes/
sed -i 's/^ZSH_THEME=.*$/ZSH_THEME="nomagic"/' ~/.zshrc
source ~/.zshrc
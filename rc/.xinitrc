# xinit  The ~/.xinitrc file is a shell script read by xinit and by its front-end startx.  https://wiki.archlinux.org/index.php/Xinit

# does this solve uxterm display of chinese characters problem? arch works well with this lines uncommented.
# export LANG=zh_CN.UTF-8
# export LANGUAGE=zh_CN:en_US
# export LC_CTYPE=en_US.UTF-8

# move this to ~/.xprofile, in Manjaro linux, seems here not exported.
# also move 'setxkbmap -option ctrl:nocaps' to there.
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources   # https://wiki.archlinux.org/index.php/X_resources#xinitrc

# if [ -f $HOME/.Xmodmap ]; then
# 	/usr/bin/xmodmap $HOME/.Xmodmap
# fi

# export XDG_CURRENT_DESKTOP=Budgie:GNOME
# exec budgie-desktop

# swo/rc/.xinitrc, see swo/rc/.Xresources

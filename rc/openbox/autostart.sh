setxkbmap -option ctrl:nocaps
xrdb -merge -I$HOME ~/.Xresources
xscreensaver -nosplash &
tint2 &         # tint2 task bar
# xterm -fullscreen -e tmux a&
# xterm -fullscreen -e tmux new\; neww \; last-window &
# gnome-terminal --full-screen -e tmux new\; neww \; last-window &
gnome-terminal --full-screen -e /home/qeatzy/notes/swo/rc/tmux-a-or-new &
# mount vm_shared   # only root is allowed to mount? /etc/rc.local not work, why?
# firefox &
# fcitx &


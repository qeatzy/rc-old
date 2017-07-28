# no longer needed, check tty in ~/.zshrc is enough.
# win10 path ZDOTDIR=E:\notes\swo\rc\config\vscode
# https://unix.stackexchange.com/questions/131716/start-zsh-with-a-custom-zshrc
# https://stackoverflow.com/questions/2727172/how-to-load-different-zshrc-file-via-commandline-option
source /home/zyq3e/notes/.preshellrc
dir='/usr/bin'; case ":$PATH:" in *$dir*) ;; *) export PATH="$dir:$PATH" ;; esac
indp_shellrc='.indp_shellrc.vscode_zsh'
source 'E:/notes/.zshrc'
alias pip='C:/pkg/dt/python3.7.4/python.exe -m pip' 
alias python='C:/pkg/dt/python3.7.4/python.exe'


unalias c
# check-tty.sh
function c() {
case $(tty) in 
  (/dev/[tp]ty[1-9]) echo 'console version';; 
              (*) echo 'not console version';; 
esac
}

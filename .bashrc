# custFile for bash, sourced by ~/.bashrc
# . ~/notes/.bashrc     # append this line to ~/.bashrc to make sourced an interactive bash is invoked.
# check also ~/.bash_profile
tmp="${BASH_SOURCE[0]}"; mydir="$(dirname $(if [ -L $tmp ]; then readlink $tmp; else echo $tmp; fi))"
# tmp="${BASH_SOURCE[0]}"; rtmp="$(realpath $tmp)"; mydir="$(dirname $rtmp)";
. "$mydir"/.indp_shellrc
R() { . "$mydir"/.preshellrc; }

# . ~/notes/.indp_shellrc
# ln -s ~/notes/.indp_shellrc ~/zzz.sh
# . ~/zzz.sh

# set vi mode editing
# set -o vi
# insert-mode key bindings
#+ bind <Esc-.> to yank-last-arg, Nth last if type Nth time.
#+ for zsh, bindkey "\e." insert-last-word
#+ in zsh, bindkey -M viins 'kj' vi-cmd-mode
#+ bind 'kj' to return to vi-cmd-mode when in insert mode

# "bind, see " key " inputrc
bind '"\C-p":history-search-backward'
bind '"\ep":history-search-backward'
bind '"\e.":yank-last-arg'
bind '"Tab":complete'
bind '"\C-n":menu-complete'
bind '"\C-l":menu-complete-backward'
bind '"\ew":unix-filename-rubout'
bind '"\eh":unix-filename-rubout'
# bind '"\C-u":unix-line-discard'
bind '"\C-a":beginning-of-line'
bind '"\C-e":end-of-line'
bind '"\C-w":backward-kill-word'
bind '"\C-k":kill-line'
bind '"\C-o":undo'
bind '"\C-o":revert-line'
bind '"\C-f":forward-char'
bind '"\C-b":backward-char'
# bind '"\ef":forward-word'
# bind '"\eb":backward-word'
# keybindings are now defined in .inputrc
# -- eg, !! last command , !-3 last third command, !222 222th command in .bash_history
# Another small one: Alt+# comments out the current line and moves it into the history buffer.  https://unix.stackexchange.com/a/78845/202329

# "inputrc, "readline setting, add below lines to, eg, ~/.inputrc , if not been included yet.
# set show-mode-in-prompt on
# set show-all-if-ambiguous on
# set completion-ignore-case on
# set bell-style none

# "completion, see " history
shopt -s nocaseglob     # ~/.inputrc文件中添加： set completion-ignore-case on
complete -c h   # https://unix.stackexchange.com/a/345205/202329
complete -c v   # version
complete -c w   # alias w='whatis'
complete -c wh  # alias wh='command -v'
_my_complete_ai_apt_install_alias() {
    # see file apt apt-get dpkg git in /usr/share/bash-completion/completions
    # a working example very similar to below for 'apt install' alias. Bash下实现alias补全 http://adam8157.info/blog/2010/05/bash-alias-completion/
    # git alias example  https://stackoverflow.com/questions/342969/how-do-i-get-bash-completion-to-work-with-aliases/1793178
    # a general solution  https://github.com/cykerway/complete-alias    https://unix.stackexchange.com/a/332522/202329
    local cur;
    cur=$(_get_cword);
    COMPREPLY=( $( apt-cache --no-generate pkgnames "$cur" 2> /dev/null ) )
    return 0
}
complete -F _my_complete_ai_apt_install_alias $default ai show vl  # both for apt
# todo: complete for alias apt not work, error completion: function _apt not found.
# alias apt='sudo apt'
# complete -F _apt apt

# "history setting ~/.bash_history
# use `^[^#].*\_$\n\_^[^#]` to search two consecutive line that are not comments in bash history file.
## and search `^\s*$` for blank lines, to remove blank entries.
shopt -s globstar   # pattern "**" used in pathname expansion context will match all files and zero or more directories and subdirectories.
shopt -s histappend
shopt -s histverify     # If you have the histverify option set (shopt -s histverify), you will always have the opportunity to edit the result of history substitutions.  http://unix.stackexchange.com/a/4086
# HISTFILE  # could set to a synced folder
HISTFILESIZE=-1
HISTSIZE=-1 # bug? on some system this makes <C-p> <Up> unusable
HISTSIZE=10000000
HISTCONTROL=ignoreboth	# ignoredups and ignorespace (line begin with space are not stored)
HISTIGNORE='?:??:???:history *:fg *:wh *:pd *:mcd *:vi *:*|v-:l[sl] *:fag *:ssh *:[huv] *:&'
# https://superuser.com/questions/232885/can-you-share-wisdom-on-using-histignore-in-bash
HISTTIMEFORMAT='%F %T '	# Record timestamps, use `date -d @${timestamp} '+%D-%T'` (depend on your timezone)
shopt -s cmdhist	# attempt to save all lines of a multiple-line command in the same history entry	
# PROMPT_COMMAND='history -a'	# Store history immediately
# export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ;} history -a" # https://github.com/wting/autojump
#+ execute last command
alias r='fc -s'
alias bP='bind -P |vim -i NONE "+setl bt=nofile |setf text" -c "nnoremap q :q<Enter>" -'

anyjobs() { [[ "$1" != 0 ]] && echo "$1"; } # https://unix.stackexchange.com/a/446149/202329
# prompt setting
PS1='\e[1;34m$(pp="$PWD/" q=${pp#"$HOME/"} p=${q%?};((${#p}>19))&&echo "${p::9}…${p:(-9)}"||echo "$p") \A $(anyjobs \j)\$ \e[m' # none if $HOME, ${t%?} to remove last char of string t. 
# PS1='\e[1;34m$(p=${PWD/#"$HOME/"/};((${#p}>19))&&echo "${p::9}…${p:(-9)}"||echo "$p") \A $(anyjobs \j)\$ \e[m'    # full pathname if $HOME
# PS1='\e[1;34m [$(p=${PWD/#"$HOME"/\047~\047};((${#p}>30))&&echo "${p::10}…${p:(-19)}"||echo "\w")]$(anyjobs \j)\$ \e[m'
# PS1='\e[1;34m /\W \t \j\$ \e[m'
    # https://askubuntu.com/questions/17723/trim-the-terminal-command-prompt-working-directory

function settitle() { echo -ne '\e]0;'"${1--bash}"'\a'; }

# "alias
#alias vim='d:/pkg/dt/vim/vim.exe'
# alias mysql='/c/Program\ Files/MySQL/MySQL\ Server\ 5.7/bin/mysql.exe'

# "server, "reid
function nsp() { # nvidia-smi parser, output most idle gpu number.
    $HOME/reid/code/scripts/parse-nvidia-smi-for-memory-usage.py
}
function ds() { # date string
    echo $(\date "+%Y-%m-%d_%H-%M-%S").echo.txt
}

# Try the cdable_vars shell option in bash. You switch it on with shopt -s cdable_vars.  https://unix.stackexchange.com/a/31222/202329
# pushd -n; cd ~1; cd ~2; https://unix.stackexchange.com/a/31278/202329
# shopt -s autocd   # bash 4+
# export CDPATH=".:$HOME/code/reid" #https://unix.stackexchange.com/a/31179/202329
export FIGNORE="git:.svn" # http://brettterpstra.com/2014/07/12/making-cd-in-bash-a-little-better/
    # FIGNORE need a proper suffix, eg, .git not work. https://stackoverflow.com/a/2226088/3625404
    # or use compgen() _cd() _vim() instead? https://stackoverflow.com/a/13345510/3625404
# "fs, see "" fn
function up() {
    # echo search up directories
local dir=$(python - << ----EOF # quote delimiter of heredoc suppress expansion.  https://stackoverflow.com/a/4938198/3625404  https://unix.stackexchange.com/a/405254/202329
from __future__ import print_function;
PWD='$PWD'; pat='$1'; paths=PWD.split("/");
if pat.endswith('/'):
    pat = pat[:-1]
    for i in range(len(paths)-1,-1,-1):
        if paths[i].endswith(pat):
            print("/".join(paths[:1+i])), exit()
    exit()
for i in range(len(paths)-1,-1,-1):
    if paths[i].startswith(pat):
        print("/".join(paths[:1+i])), exit()
for i in range(len(paths)-1,-1,-1):
    if pat in paths[i]:
        print("/".join(paths[:1+i])), exit()
----EOF
);
    if [ '' != "$dir" ]; then cd "$dir"; else echo dir "$1" not found. >&2; fi
    # echo "$dir";
# http://brettterpstra.com/2014/05/14/up-fuzzy-navigation-up-a-directory-tree/
# https://stackoverflow.com/questions/9376904/find-file-by-name-up-the-directory-tree-using-bash
}


# "ls, see " ll " cd " dirs " info " edit " python
    # " ag " lang

# "env, see also " variables
# "variables, see also " env
function e { tmp=${1^^}; echo ${!tmp}; }  # indirect expansion, ${!var} , http://stackoverflow.com/a/14204692/3625404
alias uv='unset -v'
function uuv { unset -v ${@^^}; }
# eg, `e ldlibs`, `e cflags`, `e path`.
# "echo, see also " env
# "print, see also " echo

# "func

# function j {
# if [[ "$@" == java ]]; then
#     echo command is java.
#     "$@" -help 2>&1 |v-;
#     swapfile
# else
#     "$@" --help 2>&1 |v-;
# fi
# }

# "TODO
# make 'ld' -- 'ls -d' accept args.  use 'find path -maxdepth 1 -type d'?
# a better alternative of 'find something | grep [optional |v-]'

function 1h() {
if (( $# == 0 )); then
    echo 'Usage: 1h COMMAND'
    return 1;
fi
    # bash builtin, 'function case time select [ { [[' are keyword, 'builtin test' is builtin.
    # compgen -kb
    local TYPE="$(type -t $@)"; # '' builtin keyword alias function file
    if [ "$TYPE" = builtin -o "$TYPE" = keyword ]; then help "$@"; return $?;
    elif [ "$TYPE" = alias ]; then alias "$@"; return $?;
    elif [ "$TYPE" = function ]; then type "$@"; return $?;
    fi
    local ERRNO="";   # a fix for unbound variable when 'set -euo pipefail'.
    outfile=~/.vim/.tmphelp
    # todo: some command display help and exit with exit code 1. eg, showkey, eject.
    if "$@" -help &> $outfile;  then       # for vim, 'vim -h' is prefered than 'vim --help'
        :   # null command
    elif "$@" --help &> $outfile;  then       # most case. eg, 'vim --help'
        # echo help file retrieved successfully. via suffix '--help';
        :
    elif "$@" -h &> $outfile;  then      # some rare case, eg, 'java -help'.
        # some command always return 1, even for valid -help option, eg, more, java, jdb.
        :
    else
        # echo else
        ERRNO=1;
    fi
    read -r firstline < $outfile; # https://stackoverflow.com/a/2440685/3625404
    case "$firstline" in *": command not found") help "$@" && return;; esac
    # -- not quote *. https://stackoverflow.com/a/10283129/3625404
    # and https://stackoverflow.com/a/18558871/3625404
    if [[ $- != *i* ]]; then
        { cat $outfile; return; }      # non-interactive shell, cat instead of vim.
    # elif [ "" != $ERRNO ]; then
    #     echo COMMAND FAILED. help file not found.;
    else
        # vi $outfile '+color peaksea' -c 'setlocal noswapfile' -c 'setlocal bt=nofile';
        vi $outfile -c 'setlocal noswapfile' -c 'setlocal bt=nofile';   # in case color peaksea not exist
    fi
    return $ERRNO;
}
 
function h() {
    # bug: 'h grep' hangs and waiting for input. -- 'grep -help' hangs in non-interactive bash.
# "TODO, add --help option, add -option to not open vi or specify pager, add debug switch to silent or not-silent stderr. possibly use getopts?
# "caution: this function should only used interactively because there is security hole.
# eg, any command is run verbatim, which could be very dangerous when used
# non-interactively.
if (( $# == 0 )); then
    echo "error: too few arguments. which command's help file do you want to see?" &&
        return 1;   # or as default, invoke help of builtin, or man bash?
else
    # 1. space in argument(s)
    # for git, 'git commit -h' for usage and option,  'git commit --help' for man git-commit
    if [[ "$@" =~ " " ]]; then "$@" --help;
        return $?;
    fi
    1h "$@";
fi
}

function hh() { help $1 | less ; }

function hj {  "$@" --help  | less ; }

# "time,"date
alias date='\date "+%Y-%m-%d_%H:%M"'
alias dates='\date "+%Y-%m-%d_%H:%M:%S"'    # date second

function crun { make $1 && ./$1; }  # make and run for simple c program

# "ffld, "download
ffld="~/Dowloads/ffld/"

# note that effect of so could be different from source and .
so () { source $1 | less; }

# tmux has-session -t development ||
# tmux new -s dev
# tmux attach -t dev
tmux-new() {
  if [[ -n $TMUX ]]; then
    tmux switch-client -t "$(TMUX= tmux -S "${TMUX%,*,*}" new-session -dP "$@")"
  else
    tmux new-session -s "$@"
  fi
}
# tmux-new dev

# TMUX= tmux new-session -d -s dev
# tmux attach -t dev

# If not running interactively, do not do anything
# [[ $- != *i* ]] && return
# [[ -z "$TMUX" ]] && exec tmux
# [[ -z "$TMUX" ]] && source /home/qeatzy/notes/tmux_startup

# tmux start-server
# if [[ -z "$TMUX" ]]
# then
#   exec tmux attach -d -t default
# fi

# "platform dependent, http://stackoverflow.com/questions/394230/detect-the-os-from-a-bash-script
# https://gist.github.com/davejamesmiller/1965683
# elif [[ "$OSTYPE" == darwin* ]]; then
# "cygwin
if [[ "$OSTYPE" == cygwin ]]; then
    alias firefox='/cygdrive/d/pkg/dt/firefox/firefox.exe'
    alias cmd='cygstart c:/windows/system32/cmd'
    alias cpy='/cygdrive/d/pkg/dt/Anaconda2/python'    # for plotting on windows, c for conda
    alias icpy='/cygdrive/d/pkg/dt/Anaconda2/Scripts/ipython'    # for plotting on windows, c for conda
# You can run a batch file from a Cygwin shell directly,... it might be simpler to run cmd /c 'foo.bat "quoted arguments"'.  https://superuser.com/a/189094/487198
function aa() {
    if (( $# < 0 )); then return; fi
    CYGWIN_INSTALLER='/cygdrive/e/swo/test/cygwin-setup-x64.exe' 
    CYGWIN_DIR_LOCAL_PACKAGE='E:/swo/cygwin64'
    CYGWIN_MIRROR='http://mirrors.kernel.org'
    CYGWIN_ROOT_INSTLL='D:/pkg/tmp/cygwin64'
    # cmd_download_to_local="$CYGWIN_INSTALLER -D -l '$CYGWIN_DIR_LOCAL_PACKAGE' -q --site '$CYGWIN_MIRROR'"
    # echo "[$cmd_download_to_local -P $1]" && eval "$cmd_download_to_local -P $1"
    # cmd_install_from_local="$CYGWIN_INSTALLER -L -l '$CYGWIN_DIR_LOCAL_PACKAGE' -q -R '$CYGWIN_ROOT_INSTLL'"
    # echo "[$cmd_install_from_local -P $1]" && eval "$cmd_install_from_local -P $1"
    cmd_download_and_install="$CYGWIN_INSTALLER -DL -l '$CYGWIN_DIR_LOCAL_PACKAGE' -q -R '$CYGWIN_ROOT_INSTLL'"

    local PACKAGE=' '
    while (($# > 0)); do 
        PACKAGE="-P $1 $PACKAGE"
        shift;
    done
    # echo "$PACKAGE"
    echo "[$cmd_download_and_install $PACKAGE]" && eval "$cmd_download_and_install $PACKAGE"
}
fi

#example of bashrc file
#https://github.com/hashrocket/dotmatrix/blob/master/.bashrc
# .bashrc, see also .bvimbrc, which is used within vim.

# .bashrc, see .zshrc .bvimbrc

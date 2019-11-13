tmp="${(%):-%x}"
mydir="${tmp%/*}"
indp_shellrc="${indp_shellrc:-.indp_shellrc}"
. "$mydir/$indp_shellrc"
R() { . "$mydir"/.preshellrc; }

hook_cdpath() { printf '\033]51;["call", "Tapi_lcd", ["%s"]]\007' "$(pwd)"; }
if [ "$VIM_TERMINAL" ]; then chpwd_functions+=("hook_cdpath"); fi

set -k  # fix error with # symbol, enabled interactive comment

# . ~/notes/.indp_shellrc
# ln -s ~/notes/.indp_shellrc ~/zzz.sh
# . ~/zzz.sh
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=10000

# The following lines were added by compinstall
zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' completions 1
zstyle ':completion:*' glob 1
zstyle ':completion:*' ignore-parents parent pwd directory
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]} r:|[._-]=* r:|=*'
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle ':completion:*' substitute 1
zstyle ':completion*:default' menu 'select=0'
zstyle :compinstall filename '/home/qeatzy/.zshrc'
autoload -Uz compinit && compinit

zstyle ':completion:*' menu select
zmodload zsh/complist
# ...
# use the vi navigation keys in menu completion
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'G' end-of-buffer-or-history
# man zshzle
# push-line-or-edit
# accept-line-and-down-history

## options
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt AUTO_LIST
setopt AUTO_MENU
setopt MENU_COMPLETE
# auto cd, change dir if only dir is given
# setopt AUTO_CD
# Set prompts
# PROMPT='%m%# '    # default prompt
# RPROMPT=' %~'     # prompt for right side of screen
# [ab] c d e [fg] h i j [k] l m n [opqrs] t [uv] w x y [z]  [non-exists]
# PROMPT='%n-%~ .%Z ' #
# two ways https://stackoverflow.com/questions/36192523/zsh-prompt-customization/36196179#36196179
autoload -Uz add-zsh-hook
 _trim_PWD() { pp="$PWD/" q=${pp#"$HOME/"} p=${q%?};((${#p}>19))&& psvar[1]="${p[1,9]}…${p[-9,-1]}" || psvar[1]="$p"; }
add-zsh-hook precmd _trim_PWD
# autoload -U colors && colors
if [ -z $_PROMPT_COLOR ]; then _PROMPT_COLOR=13; fi
PROMPT="%F{$_PROMPT_COLOR}%v %T %(1j.%j.)%(!.#.$) %(?..%?)%f" # **need 256 color** trimed PWD, time, job number, $, error code
rp() { PROMPT="%F{$1:-13}%v %T %(1j.%j.)%(!.#.$) %(?..%?)%f"; } # refresh prompt
# PROMPT='\e[0;31m$%v %T %(1j.%j.)%(!.#.$) %(?..%?)\e[0m'
tcolor() { # https://stackoverflow.com/a/16771593
if [ $# -eq 0 ]; then beg=0; end=255;
elif [ $# -eq 1 ]; then beg=0; end=$1;
else beg=$1; end=$2; fi
for COLOR in {$beg..$end} 
do
    for STYLE in "38;5"
    do 
        TAG="\033[${STYLE};${COLOR}m"
        STR="${STYLE};${COLOR}"
        # echo -ne "${TAG}${STR}${NONE}  "
        print -P "%F{$COLOR}color $COLOR%f"  # man zshmisc %F %f %K %k https://unix.stackexchange.com/a/107468
    done
done
}
# f() { PROMPT='%F{'$1'}%v %T %(1j.%j.)%(!.#.$) %(?..%?)%f'; } # trimed PWD, time, job number, $, error code
# setopt prompt_subst # man zshoptions # https://stackoverflow.com/questions/15212152/zsh-prompt-function-not-running
# PROMPT='%v %T %(1j.%j.)$ %(?..%?)' # trimed PWD, time, job number, $, error code
# eval my_color='$FG[228]'
# f() {
# autoload colors && colors
# for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
#     echo $COLOR='%{$fg_no_bold[${(L)COLOR}]%}'  #wrap colours between %{ %} to avoid weird gaps in autocomplete
#     echo BOLD_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
# done
# echo RESET='%{$reset_color%}'
# }
# g() {
# for COLOR in {0..255} 
# do
#     for STYLE in "38;5"
#     do 
#         TAG="\033[${STYLE};${COLOR}m"
#         STR="${STYLE};${COLOR}"
#         echo -ne "${TAG}${STR}${NONE}  "
#     done
#     echo
# done
# }

# "history
setopt extended_history # save timestamp
setopt HIST_IGNORE_DUPS     # ignore contiguous duplicate
setopt HIST_IGNORE_SPACE    # ignore if command or expanded alias has leading space
setopt HIST_NO_FUNCTIONS    # do not add func def, though those linger in internal history
setopt HIST_REDUCE_BLANKS

export KEYTIMEOUT=10    # 100 ms, unit is 10 ms
bindkey -v
bindkey -M viins 'kj' vi-cmd-mode
bindkey -M viins '^k' kill-line
bindkey -M viins '^u' backward-kill-line
bindkey -M viins '^b' backward-char
bindkey -M viins '^f' forward-char
bindkey -M viins '\eb' backward-word
bindkey -M viins '\ef' forward-word
bindkey -M viins '^a' beginning-of-line
bindkey -M viins '^e' end-of-line
bindkey -M viins '\e.' insert-last-word
bindkey -M viins '\ex' where-is         # similar to `:` in vim, <M-x> in emacs
bindkey -M viins '\C-p' history-search-backward
bindkey -M viins '\C-n' history-search-forward
bindkey -M viins '\eh' run-help         # invoke help
bindkey -s -M viins '\C-z' ' fg\\'
# bindkey -s '\es' ' echo hello world!\\\'
# bindkey -M viins '^r' history-incremental-pattern-search-backward
# bindkey -M isearch '^r' history-incremental-pattern-search-backward
bindkey -M viins '^R' history-incremental-search-backward
bindkey -M isearch '^R' history-incremental-search-backward     # https://superuser.com/a/197840/487198
bindkey -M isearch '^p' history-incremental-search-backward
bindkey -M isearch '^n' history-incremental-search-forward
bindkey -M isearch '^k' history-incremental-search-backward
bindkey -M isearch '^j' history-incremental-search-forward
bindkey -M isearch 'kj' vi-cmd-mode
bindkey -M isearch '^/' vi-repeat-search
autoload -z edit-command-line       # man zshcontrib
zle -N edit-command-line
bindkey -M vicmd v edit-command-line
# bindkey -e  # -e emacs, -v for vi
# bindkey "\C-p" history-search-backward
# bindkey "\e." insert-last-word
# bindkey "\C-n" menu-complete
# bindkey "\C-r" history-incremental-pattern-search-backward  # reverse-search-history


# color code https://unix.stackexchange.com/questions/269077/tput-setaf-color-table-how-to-determine-color-codes
# %F (%f) Start (stop) using a different foreground colour
# %K (%k) Start (stop) using a different bacKground colour.
#     https://unix.stackexchange.com/questions/25319/256-colour-prompt-in-zsh
# both %(...) and %j can be found in man zshmisc, in "expansion of prompt sequences" section (the ternary operation is in "conditional substrings in prompts" subsection).
    # https://stackoverflow.com/questions/10194094/zsh-prompt-checking-if-there-are-any-background-jobs
# %<< will basically tell zsh that anything after this should not be truncated (limiting the truncation to the path part)
    # https://stackoverflow.com/questions/37286971/shortening-my-prompt-in-zsh
# bash zsh  https://unix.stackexchange.com/questions/346924/ps1-pwd-why-this-works-and-why-is-this-different-from-ps1-pwd
# PROMPT='$(collapse_pwd)' #
# color Firstly, according to http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html, zsh supports using %F to start font color and %f to stop font color:
# PS1='$(git rev-parse --abbrev-ref HEAD 2> /dev/null) %~ %F{red}♥%f '
# PROMPT='%{$fg[magenta]%}%n%{$reset_color%} at %{$fg[yellow]%}%m%{$reset_color%}' #
# [ABC] D [E] F [GH] I [J] L M N [OPQRS] T U [V] W [XYZ]
# %? The return status of the last command executed just before the prompt.
# %~ shows the path with any variables replaced. otherwise same as %d
# %D `18-12-30` year-month-day
# %F control, make all char type hidden/invisible, F for foreground?
# %I `13` same as %i
# %L `3` what?
# %M same as %m
# %N `zsh`
# %T time, `6:44` `17:56` similar to %t
# %* Current time of day in 24-hour format, with seconds.
# %D{string} string is formatted using the strftime function.
# %U control, add underline
# %W `12/30/18` month/day/year
# %c current directory, basename
# %d current directory, full path
# %e `0` what??
# %h `131` number of history command
# %i `13` number of command accepted, including empty lines
# %j `2` number of background jobs
# %l `pty13`  pseudo-terminal, same as y
# %m `DESKTOP-B3TMDC4`  machine name
# %n username
# %t time, `6:44AM` `5:56PM`
# %w week, `Wed 19`, week & day
# %x `zsh`
# %y `pty13`  pseudo-terminal, same as l

alias wh=' which'

## variables
# cdpath,fpath,

# aliases
alias mv='nocorrect mv'       # no spelling correction on mv
alias cp='nocorrect cp'       # no spelling correction on cp
alias mkdir='nocorrect mkdir' # no spelling correction on mkdir
alias j=jobs
alias pu=pushd
alias po=popd
alias d='dirs -v'
# alias h=history
# List only directories and symbolic links that point to directories
alias lsd='ls -ld *(-/DN)'
# List only file beginning with "."
alias lsa='ls -ld .*'

## utility
# find sorted list of largest file under current directory
alias biggest='find -type f -printf '\''%s %p\n'\'' | sort -nr | head -n 40 | awk "{ print \$1/1000000 \" \" \$2 \" \" \$3 \" \" \$4 \" \" \$5 \" \" \$6 \" \" \$7 \" \" \$8 \" \" \$9 }"'

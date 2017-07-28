# promising colors
# 167 set toy-chest
# bugs in themes
# 86 maia color spec error. export FOREGROUND_COLOR="#BDX3C7"
#   issue added   https://github.com/Mayccoll/Gogh/issues/191

s() {
if [ $# -eq 0 ]; then
    if [ -z "$colst" ]; then
    # if [ -z "$colst" ]; then echo empty; else echo not empty; fi
    colst=($(python theme_client.py l |tail -n +2)) # remove 1st line
    else
        if [ -z $_i_colst ]; then _i_colst=0; fi
        if [ $_i_colst -ge ${#colst[@]} ]; then _i_colst=0; fi
        echo -n "$_i_colst " && python theme_client.py s ${colst[@]:_i_colst:1}
        # python theme_client.py s ${colst[$_i_colst]}  # bash zsh inconsistent, zsh 1-based, bash 0-based
        let _i_colst=_i_colst+1
    fi
elif [ $# -eq 1 ]; then
    case $1 in
        [0-9]*)
            let _i_colst="$1"
            echo _i_colst=$_i_colst "${colst[@]:$_i_colst:1}"
        ;;+[1-9]*)
            let _i_colst=$_i_colst+"${1:1}"
            echo _i_colst=$_i_colst "${colst[@]:$_i_colst:1}"
        ;;-[1-9]*)
            let _i_colst=$i-"${1:1}"
            echo _i_colst=$_i_colst "${colst[@]:$_i_colst:1}"
        ;;l)
            echo _i_colst=$_i_colst "${colst[@]:$_i_colst:1}"
    esac
fi
}
unset colst; s  # reload 
alias co='py3 ./theme_client.py'

t() {
    if [ -z "$colst" ]; then
    # if [ -z "$colst" ]; then echo empty; else echo not empty; fi
    colst=($(python theme_client.py l))
    else
        if [ -z $_i_colst ]; then let _i_colst=${#colst[@]}-1; fi
        if [ $_i_colst -lt 0 ]; then let _i_colst=${#colst[@]}-1; fi
        echo -n "$_i_colst " && python theme_client.py s ${colst[@]:_i_colst:1}
        let _i_colst=_i_colst-1
    fi
}

tmux bind -n j send-key s Enter
tmux bind -n k send-key t Enter
alias u='tmux unbind -n j\; unbind -n k'

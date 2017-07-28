# https://medium.com/@kazakov.a.s.90/hey-dude-pimp-my-cygwin-35a3ef4cb748
# Currently available prompt themes:
# agnoster cloud damoekri giddie kylewest minimal nicoulaj paradox peepcode powerlevel9k powerline pure skwp smiley sorin steeef adam1 adam2 bart bigfade clint elite elite2 fade fire off oliver pws redhat suse walters zefram
# .+,$s/'\([^']*\)'/'\\ePtmux;\\e\1\\e\\\\'/
echo -ne   '\ePtmux;\e\eP\e]10;#839496\a\e\\'  # Foreground   -> base0
echo -ne   '\ePtmux;\e\eP\e]11;#002B36\a\e\\'  # Background   -> base03
echo -ne   '\ePtmux;\e\eP\e]12;#DC322F\a\e\\'  # Cursor       -> red
echo -ne  '\ePtmux;\e\eP\e]4;0;#073642\a\e\\'  # black        -> Base02
echo -ne  '\ePtmux;\e\eP\e]4;8;#002B36\a\e\\'  # bold black   -> Base03
echo -ne  '\ePtmux;\e\eP\e]4;1;#DC322F\a\e\\'  # red          -> red
echo -ne  '\ePtmux;\e\eP\e]4;9;#CB4B16\a\e\\'  # bold red     -> orange
echo -ne  '\ePtmux;\e\eP\e]4;2;#859900\a\e\\'  # green        -> green
echo -ne '\ePtmux;\e\eP\e]4;10;#586E75\a\e\\'  # bold green   -> base01 *
echo -ne  '\ePtmux;\e\eP\e]4;3;#B58900\a\e\\'  # yellow       -> yellow
echo -ne '\ePtmux;\e\eP\e]4;11;#657B83\a\e\\'  # bold yellow  -> base00 *
echo -ne  '\ePtmux;\e\eP\e]4;4;#268BD2\a\e\\'  # blue         -> blue
echo -ne '\ePtmux;\e\eP\e]4;12;#839496\a\e\\'  # bold blue    -> base0 *
echo -ne  '\ePtmux;\e\eP\e]4;5;#D33682\a\e\\'  # magenta      -> magenta
echo -ne '\ePtmux;\e\eP\e]4;13;#6C71C4\a\e\\'  # bold magenta -> violet
echo -ne  '\ePtmux;\e\eP\e]4;6;#2AA198\a\e\\'  # cyan         -> cyan
echo -ne '\ePtmux;\e\eP\e]4;14;#93A1A1\a\e\\'  # bold cyan    -> base1 *
echo -ne  '\ePtmux;\e\eP\e]4;7;#EEE8D5\a\e\\'  # white        -> Base2
echo -ne '\ePtmux;\e\eP\e]4;15;#FDF6E3\a\e\\'  # bold white   -> Base3


# https://unix.stackexchange.com/questions/409068/tmux-and-control-sequence-character-issue
# The escape sequence is being interpreted by tmux and is not being passed through to the terminal program that tmux is running in. To have it pass through, you need to wrap the escape sequence to tell tmux to pass it through:
# printf '\ePtmux;\e%s\e\\' "${escape_sequence}"
# where escape_sequence is the sequence you want tmux to pass out to the terminal.
# There is not much documentation for this, but evidence can be found in the CHANGES file for the 1.5 release: https://github.com/tmux/tmux/blob/1.5/CHANGES#L33

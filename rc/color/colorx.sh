# ?? set theme with control sequence not work inside tmux. see below
# see also /usr/bin/mintheme at cygwin
# https://medium.com/@kazakov.a.s.90/hey-dude-pimp-my-cygwin-35a3ef4cb748
# Currently available prompt themes:
# agnoster cloud damoekri giddie kylewest minimal nicoulaj paradox peepcode powerlevel9k powerline pure skwp smiley sorin steeef adam1 adam2 bart bigfade clint elite elite2 fade fire off oliver pws redhat suse walters zefram
# .+,'}s/'\\eP\\e/'\\033/
# .+,'}s/'\\eP\\e\([^']*\)/'\\033Ptmux;\\033\\033\1\\033\\\\/
echo -ne   '\033Ptmux;\033\033]10;#839496\a\033\\'  # Foreground   -> base0
echo -ne   '\033Ptmux;\033\033]11;#002B36\a\033\\'  # Background   -> base03
echo -ne   '\033Ptmux;\033\033]12;#DC322F\a\033\\'  # Cursor       -> red
echo -ne  '\033Ptmux;\033\033]4;0;#073642\a\033\\'  # black        -> Base02
echo -ne  '\033Ptmux;\033\033]4;8;#002B36\a\033\\'  # bold black   -> Base03
echo -ne  '\033Ptmux;\033\033]4;1;#DC322F\a\033\\'  # red          -> red
echo -ne  '\033Ptmux;\033\033]4;9;#CB4B16\a\033\\'  # bold red     -> orange
echo -ne  '\033Ptmux;\033\033]4;2;#859900\a\033\\'  # green        -> green
echo -ne '\033Ptmux;\033\033]4;10;#586E75\a\033\\'  # bold green   -> base01 *
echo -ne  '\033Ptmux;\033\033]4;3;#B58900\a\033\\'  # yellow       -> yellow
echo -ne '\033Ptmux;\033\033]4;11;#657B83\a\033\\'  # bold yellow  -> base00 *
echo -ne  '\033Ptmux;\033\033]4;4;#268BD2\a\033\\'  # blue         -> blue
echo -ne '\033Ptmux;\033\033]4;12;#839496\a\033\\'  # bold blue    -> base0 *
echo -ne  '\033Ptmux;\033\033]4;5;#D33682\a\033\\'  # magenta      -> magenta
echo -ne '\033Ptmux;\033\033]4;13;#6C71C4\a\033\\'  # bold magenta -> violet
echo -ne  '\033Ptmux;\033\033]4;6;#2AA198\a\033\\'  # cyan         -> cyan
echo -ne '\033Ptmux;\033\033]4;14;#93A1A1\a\033\\'  # bold cyan    -> base1 *
echo -ne  '\033Ptmux;\033\033]4;7;#EEE8D5\a\033\\'  # white        -> Base2
echo -ne '\033Ptmux;\033\033]4;15;#FDF6E3\a\033\\'  # bold white   -> Base3

# The problem is that you are using sub-parameters in your control sequence, not parameters. Parameters are separated by semi-colon ;, as specified in ECMA-48:1991 § 5.4.2. Sub-parameters are separated by colon :, as specified in ITU-T T.416:1993 § 13.1.8.
# https://unix.stackexchange.com/questions/468139/color-codes-in-bash-ps1-not-working-in-tmux
# (not matter) The tmux FAQ points out that
#     Inside tmux TERM must be "screen", "tmux" or similar (such as "tmux-256color"). Don't bother reporting problems where it isn't!
# xterm-256color is different from tmux-256color.
# (seems the answer) https://unix.stackexchange.com/questions/409068/tmux-and-control-sequence-character-issue
# The escape sequence is being interpreted by tmux and is not being passed through to the terminal program that tmux is running in. To have it pass through, you need to wrap the escape sequence to tell tmux to pass it through:

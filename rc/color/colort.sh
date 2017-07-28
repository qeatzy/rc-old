# ?? set theme with control sequence not work inside tmux. see below
# see also /usr/bin/mintheme at cygwin
# https://medium.com/@kazakov.a.s.90/hey-dude-pimp-my-cygwin-35a3ef4cb748
# Currently available prompt themes:
# agnoster cloud damoekri giddie kylewest minimal nicoulaj paradox peepcode powerlevel9k powerline pure skwp smiley sorin steeef adam1 adam2 bart bigfade clint elite elite2 fade fire off oliver pws redhat suse walters zefram
# echo -ne   '\eP\e]10;#839496\a'  # Foreground   -> base0
# echo -ne   '\eP\e]11;#002B36\a'  # Background   -> base03
# echo -ne   '\eP\e]12;#DC322F\a'  # Cursor       -> red
echo -ne  '\eP\e]4;0;#073642\a'  # black        -> Base02
echo -ne  '\eP\e]4;8;#002B36\a'  # bold black   -> Base03
echo -ne  '\eP\e]4;1;#DC322F\a'  # red          -> red
echo -ne  '\eP\e]4;9;#CB4B16\a'  # bold red     -> orange
echo -ne  '\eP\e]4;2;#859900\a'  # green        -> green
echo -ne '\eP\e]4;10;#586E75\a'  # bold green   -> base01 *
echo -ne  '\eP\e]4;3;#B58900\a'  # yellow       -> yellow
echo -ne '\eP\e]4;11;#657B83\a'  # bold yellow  -> base00 *
echo -ne  '\eP\e]4;4;#000000\a'  # blue         -> blue
echo -ne '\eP\e]4;12;#000000\a'  # bold blue    -> base0 *
echo -ne  '\eP\e]4;5;#000000\a'  # magenta      -> magenta
echo -ne '\eP\e]4;13;#6C71C4\a'  # bold magenta -> violet
echo -ne '\eP\e]4;13;#000000\a'  # bold magenta -> violet
echo -ne  '\eP\e]4;6;#000000\a'  # cyan         -> cyan
echo -ne '\eP\e]4;14;#000000\a'  # bold cyan    -> base1 *
echo -ne  '\eP\e]4;7;#000000\a'  # white        -> Base2
echo -ne '\eP\e]4;15;#000000\a'  # bold white   -> Base3

# The problem is that you are using sub-parameters in your control sequence, not parameters. Parameters are separated by semi-colon ;, as specified in ECMA-48:1991 § 5.4.2. Sub-parameters are separated by colon :, as specified in ITU-T T.416:1993 § 13.1.8.
# https://unix.stackexchange.com/questions/468139/color-codes-in-bash-ps1-not-working-in-tmux
# (not matter) The tmux FAQ points out that
#     Inside tmux TERM must be "screen", "tmux" or similar (such as "tmux-256color"). Don't bother reporting problems where it isn't!
# xterm-256color is different from tmux-256color.
# (seems the answer) https://unix.stackexchange.com/questions/409068/tmux-and-control-sequence-character-issue
# The escape sequence is being interpreted by tmux and is not being passed through to the terminal program that tmux is running in. To have it pass through, you need to wrap the escape sequence to tell tmux to pass it through:

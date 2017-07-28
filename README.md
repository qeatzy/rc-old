A mirror of my common *dotfiles*, also as a backup.  
Constantly updated by a bash script containing,
    
    rsync --verbose -a --existing --update dir/source/ .
    git add .
    git commit --amend --no-edit
    git push -f
where the dir/source/ is synchronized among several devices.

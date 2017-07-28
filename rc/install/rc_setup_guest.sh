rc_root=~/qeatzy/rc;
# if ! [ -d ~/rc ]; then ( cd && git clone http://github.com/qeatzy/rc ); fi
mkdir -p ~/.vimundo ~/.vimswap ~/.vim/autoload ~/.vim/bundle 
if ! [ -f ~/.vim/autoload/pathogen.vim ]; then
    if ! wget -O ~/.vim/autoload/pathogen.vim  https://github.com/tpope/vim-pathogen/raw/master/autoload/pathogen.vim ; then
        mkdir ~/tmp && cd ~/tmp && git clone https://github.com/tpope/vim-pathogen && cp vim-pathogen/autoload/pathogen.vim ~/.vim/autoload && ~/tmp/vim-pathogen
    fi
fi
cd ~/.vim/bundle && git clone https://github.com/justinmk/vim-dirvish 2>/dev/null # replace netrw perfectly
  sed -i -e '/^\s*[^"].*map.* q /s/^/" /' ~/.vim/bundle/vim-dirvish/ftplugin/dirvish.vim 2>/dev/null
      # below fix if last accessed window closed
      # ag -F "exe (winnr('$') > 1 ? 'wincmd p' : 'vsplit')" ~/.vim/bundle/vim-dirvish/autoload/dirvish.vim 2>/dev/null
      # export nr=$(/usr/bin/grep -F -n "exe (winnr('$') > 1 ? 'wincmd p' : 'vsplit')" ~/.vim/bundle/vim-dirvish/autoload/dirvish.vim 2>/dev/null |cut -f1 -d:) ;echo $nr
      # ~/.vim/bundle/vim-dirvish/autoload/dirvish.vim 2>/dev/null
      # " exe (winnr('$') > 1 ? 'wincmd p' : 'vsplit')
      # exe (winnr('$') > 1 ? ((winnr('#') && winnr() != winnr('#')) ? 'wincmd p' : 'wincmd w') : 'vsplit')
cd ~/.vim/bundle && git clone https://github.com/tpope/vim-unimpaired 2>/dev/null
cd ~/.vim/bundle && git clone https://github.com/tpope/vim-repeat 2>/dev/null
cd ~/.vim/bundle && git clone https://github.com/tpope/vim-surround 2>/dev/null
cd ~/.vim/bundle && git clone https://github.com/tomtom/tcomment_vim.git 2>/dev/null
cd ~/.vim/bundle && git clone https://github.com/ctrlpvim/ctrlp.vim.git 2>/dev/null
cd ~/.vim/bundle && git clone https://github.com/mileszs/ack.vim.git 2>/dev/null

if [ -f "$rc_root/C-removeccomments.c" ] && ! [ -f ~/.vim/removeccomments ]; then 
    gcc -O3 "$rc_root/C-removeccomments.c" -o ~/.vim/removeccomments
    # time ~/.vim/removeccomments < Objects/unicodeobject.c > result.c
    # !bash ~/rc/rc/install/rc_setup.sh
fi

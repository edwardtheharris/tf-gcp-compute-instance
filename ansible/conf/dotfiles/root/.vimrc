set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
call plug#begin()
Plug 'Absolight/vim-bind'
Plug 'andrewstuart/vim-kubernetes'
Plug 'b4b4r07/vim-hcl'
Plug 'chr4/nginx.vim'
Plug 'docker/docker' , {'rtp': '/contrib/syntax/vim/'}
Plug 'egberts/vim-syntax-bind-named'
Plug 'fladson/vim-kitty'
Plug 'itspriddle/vim-shellcheck'
Plug 'junegunn/vim-easy-align'
Plug 'junegunn/vim-github-dashboard'
Plug 'ledger/vim-ledger'
Plug 'lepture/vim-jinja'
Plug 'Matt-Deacalion/vim-systemd-syntax'
Plug 'nathangrigg/vim-beancount'
" Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'npm ci'}
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug '~/Documents/src/github.com/bryant/neovim/runtime/syntax/samba.vim'
Plug 'pearofducks/ansible-vim'
Plug 'preservim/vim-markdown'
Plug 'rhysd/committia.vim'
Plug 'rottencandy/vimkubectl'
Plug 'stephpy/vim-yaml'
Plug 'vim-scripts/bash-support.vim'
Plug 'vim-scripts/LanguageTool'
Plug 'wakatime/vim-wakatime'
Plug 'yasuhiroki/github-actions-yaml.vim'
call plug#end()
filetype plugin on

" coc plugins, for reference
" fannheyward/coc-markdownlint
" gianarb/coc-grammarly


syntax on
set ts=2 sts=2 sw=2 et modeline number
set colorcolumn=80,120
set nofoldenable

let g:languagetool_jar='/usr/share/java/languagetool/languagetool-commandline.jar'

"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
"
"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"" let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 0
"
"" let g:syntastic_python_checkers = ['bandit', 'flake8', 'frosted', 'mypy', 'prospector', 'pycodestyle', 'pydocstyle', 'pyflakes', 'pylama', 'pylint', 'python']
"let g:syntastic_aggregate_errors = 1
"let g:syntastic_rst_checkers = ['sphinx']
"let g:syntastic_yaml_checkers = ['yamllint']

au BufNewFile,BufRead *.html,*.htm,*.shtml,*.stm set ft=jinja
au BufNewFile,BufRead *.yml set ft=yaml
au BufNewFile,BufRead *.rst set sts=3 sw=3 ts=3 ft=rst
au BufNewFile,BufRead *.service set sts=2 sw=2 ts=2 ft=systemd
au BufNewFile,BufRead Jenkinsfile setf groovy
au BufNewFile,BufRead accounts,journal,register,*.journal,*.ldg,*.ledger setf ledger | comp ledger
au BufRead,BufNewFile */playbooks/*.yml set filetype=yaml.ansible
au BufNewFile,BufRead openssl.cnf setf dosini
au BufNewFile,BufRead *.zone setf bindzone
au BufNewFile,BufRead named.conf setf named

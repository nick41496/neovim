call plug#begin(stdpath('config') . '/plug')
  Plug 'junegunn/fzf.vim'
  Plug 'rhysd/git-messenger.vim'
  Plug 'soywod/kronos.vim'
  Plug 'itchyny/lightline.vim'
  Plug 'neomake/neomake'
  Plug 'scrooloose/nerdcommenter'
  Plug 'nightsense/stellarized'
  Plug 'Townk/vim-autoclose'
  Plug 'kchmck/vim-coffee-script'
  Plug 'tpope/vim-dadbod'
  Plug 'pangloss/vim-javascript'
  Plug 'mxw/vim-jsx'
  Plug 'tpope/vim-rails'
  Plug 'slim-template/vim-slim'
  Plug 'tpope/vim-surround'
  Plug 'christoomey/vim-tmux-navigator'
call plug#end()

set runtimepath+=~/src/fzf
let &packpath = &runtimepath
let mapleader = ","

set termguicolors
set background=dark
colorscheme stellarized
hi link Whitespace ColorColumn

set clipboard=unnamed
set colorcolumn=80,100
set linebreak
set list
set noshowmode
set nowrap
set relativenumber
set scrolloff=7
set spell
set splitbelow
set splitright
set textwidth=100
set undofile

"Academia directories
map <leader>app :cd ~/academia/projects/academia-app/<CR>
map <leader>notes :cd ~/notes<CR>
map <leader>wiki :cd ~/academia/wiki<CR>

"Copy
nnoremap <leader>y :call system('nc localhost 8377', @0)<CR>

"Netrw
let g:netrw_banner = 0
let g:netrw_browse_split = 4
let g:netrw_liststyle = 3
let g:netrw_winsize = 10

"Resize Panes
nmap <C-w>h :vertical resize -10<CR>
nmap <C-w>j :resize -10<CR>
nmap <C-w>k :resize +10<CR>
nmap <C-w>l :vertical resize +10<CR>

"Swap Windows
function! MarkWindowSwap()
  let g:markedWinNum = winnr()
endfunction

function! DoWindowSwap()
  "Mark destination
  let curNum = winnr()
  let curBuf = bufnr( "%" )
  exe g:markedWinNum . "wincmd w"
  "Switch to source and shuffle dest->source
  let markedBuf = bufnr( "%" )
  "Hide and open so that we aren't prompted and keep history
  exe 'hide buf' curBuf
  "Switch to dest and shuffle source->dest
  exe curNum . "wincmd w"
  "Hide and open so that we aren't prompted and keep history
  exe 'hide buf' markedBuf
endfunction

nmap <silent> <leader>mw :call MarkWindowSwap()<CR>
nmap <silent> <leader>pw :call DoWindowSwap()<CR>

"Tags
set tags=./.tags;/,.tags;/

"Tabs
set expandtab
set smartindent
set shiftwidth=2
set tabstop=2

"Templates
augroup templates
  autocmd BufNewFile *.rb 0r ~/.config/nvim/templates/skeleton.rb
  autocmd BufNewFile *_nf.md 0r ~/.config/nvim/templates/nf_skeleton.md
augroup end

"Whitespace
nmap <leader>dw :%s/\s\+$//e<CR>:w<CR>

"Vimrc
map <leader>vimrc :tabe $MYVIMRC<CR>
augroup reload_vimrc
  autocmd!
  autocmd bufwritepost $MYVIMRC nested source $MYVIMRC
augroup END

"Yank filename
nmap yf :let @* = expand("%:p")<CR>

"Dadbod
function! Time(cmd) range
  let starttime = reltime()
  execute a:firstline . "," . a:lastline . a:cmd
  let endtime = str2float(reltimestr(reltime(starttime)))
  redraw!
  echohl MoreMsg
  echo printf("%.02g sec", endtime)
  echohl None
endfun

augroup db_setup
  autocmd bufread attention.sql let b:db = $ATTENTION_DB
  autocmd bufread email.sql let b:db = $EMAIL_DB
  autocmd bufread main.sql let b:db = $MAIN_DB
  autocmd bufread mentions.sql let b:db = $MENTIONS_DB
  autocmd bufread redshift.sql let b:db = $REDSHIFT
  autocmd bufread qa_redshift.sql let b:db = $QA_REDSHIFT
  autocmd bufread dev.sql let b:db = $DEV_DB
  autocmd bufread dev_attention.sql let b:db = $DEV_ATTENTION_DB
  autocmd bufread dev_mentions.sql let b:db = $DEV_MENTIONS_DB
augroup END

nmap Q :call Time(".DB")<CR>
vmap Q :call Time("DB")<CR>

"Fzf
autocmd VimEnter * map <C-p> :Files<CR>
map <C-M-p> :Buffers<CR>

"Lightline
let g:lightline = {
      \ 'colorscheme': 'stellarized_dark',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ] ],
      \   'right': [ [ 'lineinfo' ], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'filename': 'LightlineFilename',
      \   'fileformat': 'LightlineFileformat',
      \   'filetype': 'LightlineFiletype',
      \   'fileencoding': 'LightlineFileencoding',
      \   'mode': 'LightlineMode',
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }

function! LightlineModified()
  return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightlineReadonly()
  return &ft !~? 'help' && &readonly ? 'RO' : ''
endfunction

function! LightlineFilename()
  let fname = expand('%:t')
  return fname == '__Tagbar__' ? g:lightline.fname :
        \ &ft == 'vimfiler' ? vimfiler#get_status_string() :
        \ &ft == 'unite' ? unite#get_status_string() :
        \ &ft == 'vimshell' ? vimshell#get_status_string() :
        \ ('' != LightlineReadonly() ? LightlineReadonly() . ' ' : '') .
        \ ('' != fname ? fname : '[No Name]') .
        \ ('' != LightlineModified() ? ' ' . LightlineModified() : '')
endfunction

function! LightlineFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightlineFiletype()
  return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

function! LightlineFileencoding()
  return winwidth(0) > 70 ? (&fenc !=# '' ? &fenc : &enc) : ''
endfunction

function! LightlineMode()
  let fname = expand('%:t')
  return fname == '__Tagbar__' ? 'Tagbar' :
        \ fname == '__Gundo__' ? 'Gundo' :
        \ fname == '__Gundo_Preview__' ? 'Gundo Preview' :
        \ &ft == 'unite' ? 'Unite' :
        \ &ft == 'vimfiler' ? 'VimFiler' :
        \ &ft == 'vimshell' ? 'VimShell' :
        \ winwidth(0) > 60 ? lightline#mode() : ''
endfunction

let g:tagbar_status_func = 'TagbarStatusFunc'

function! TagbarStatusFunc(current, sort, fname, ...) abort
  let g:lightline.fname = a:fname
  return lightline#statusline(0)
endfunction

let g:unite_force_overwrite_statusline = 0
let g:vimfiler_force_overwrite_statusline = 0
let g:vimshell_force_overwrite_statusline = 0

"Neomake
let g:neomake_ruby_enabled_makers = ['bundle']
let g:neomake_bundle_maker = {
      \ 'args': [
      \   'exec', 'rubocop',
      \   '--require', 'rubocop-rspec',
      \   '--format', 'emacs',
      \   '--force-exclusion',
      \   '--display-cop-names'
      \ ],
      \ 'errorformat': '%f:%l:%c: %t: %m,%E%f:%l: %m',
      \ 'postprocess': function('neomake#makers#ft#ruby#RubocopEntryProcess'),
      \ 'output_stream': 'stdout',
      \ }
let g:neomake_javascript_enabled_makers = ['yarn']
let g:neomake_yarn_maker = {
      \ 'args': [
      \   'lint',
      \   '--format', 'compact'
      \ ],
      \ 'errorformat': '%E%f: line %l\, col %c\, Error - %m,' .
      \   '%W%f: line %l\, col %c\, Warning - %m, %-G, %-G%*\d problems%#',
      \ 'output_stream': 'stdout',
      \ }
call neomake#configure#automake('w')

nmap <leader>lo :lopen<CR>
nmap <leader>lc :lclose<CR>

"C
augroup C
  autocmd!
  autocmd BufRead,BufNewFile *.h,*.c set filetype=c.doxygen
augroup END

"Markdown
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
set concealcursor=""
set conceallevel=2

"Ruby
autocmd BufNewFile,BufRead *.rb set filetype=ruby
autocmd BufNewFile,BufRead *.rake set filetype=ruby
runtime macros/matchit.vim

"Yaml
autocmd BufNewFile,BufRead *.yml set filetype=yaml

" Enable filetype detection, plugin, and indentation
filetype plugin indent on


" ==========
" Vim Pluggins
" ==========

call plug#begin('~/.vim/plugged')
" Status line
Plug 'itchyny/lightline.vim'
" Copy to clipboard
Plug 'ojroques/vim-oscyank'
" LSP
Plug 'prabirshrestha/vim-lsp'
" async autocomplete
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
call plug#end()

" ==========
" UI
" ==========

set laststatus=2

" Numbering
set number      	" Enable absolute line number
set relativenumber  " Enable relative line number

" Indentation
set tabstop=4       " Set the number of spaces a tab character represents
set shiftwidth=4    " Set the number of spaces to use for indentation
set autoindent
set smartindent
set smarttab

" Bell
set noerrorbells  " Disable error bells
set novisualbell  " Disable visual bell (flashing screen)
set belloff=all   " Turn off all bells (including for errors and warnings)

" Cursor
if &term =~ "xterm\\|rxvt\\|tmux"
    let &t_SI = "\e[6 q"  " Vertical bar in insert mode
    let &t_EI = "\e[2 q"  " Full block in normal mode
endif

" Diff group color scheme
hi DiffAdd    ctermfg=NONE ctermbg=22
hi DiffDelete ctermfg=NONE ctermbg=52
hi DiffChange ctermfg=NONE ctermbg=17
hi DiffText   ctermfg=NONE ctermbg=24 cterm=bold


" ==========
" Toggle file explorer
" ==========
nnoremap <leader>b <Esc>:Lex<cr>:vertical resize 30<cr>


" ==========
" Window focus navigation
" ==========

" Move focus to left
nnoremap <c-h> <Esc><c-w>h

" Move focus to down 
nnoremap <c-j> <Esc><c-w>j

" Move focus to up 
nnoremap <c-k> <Esc><c-w>k

" Move focus to right
nnoremap <c-l> <Esc><c-w>l


" ==========
" QuickFix
" ==========

" General setup for different languages

let g:c_compiler = "gcc"
let g:cpp_compiler = "g++"

function! SetCompilerPrg()
    if &filetype ==# 'c'
        execute "setlocal makeprg=" . g:c_compiler . "\\ %\\ -o\\ %:r"
    elseif &filetype ==# 'cpp'
        execute "setlocal makeprg=" . g:cpp_compiler . "\\ %\\ -o\\ %:r"
    elseif &filetype ==# 'cu'
        execute "setlocal makeprg=nvcc\\ %\\ -o\\ %:r"
    elseif &filetype ==# 'python'
        execute "setlocal makeprg=python\\ %"
		" TODO: python error format

    endif
endfunction

" Commands to switch compilers
command! UseGCC   let g:c_compiler="gcc"   | let g:cpp_compiler="g++"   | call SetCompilerPrg()
command! UseClang let g:c_compiler="clang" | let g:cpp_compiler="clang++" | call SetCompilerPrg()
command! UseHIP   let g:c_compiler="hipcc" | let g:cpp_compiler="hipcc" | call SetCompilerPrg()

autocmd FileType c,cpp,cu,python call SetCompilerPrg()

" Navigate between QuickFix items
nnoremap <right> :cnext<cr>
nnoremap <left> :cprev<cr>


" ==========
" Movement keys 
" ==========

" Navigate with jkl; instead of hjkl
noremap ; l
noremap l k
noremap k j
noremap j h


" ==========
" Ctags
" ==========

" Look for a 'tags' file in the cwd, then parent dirs
set tags=./tags;,tags

" Optional niceties
set wildignore+=*.pyc,__pycache__          " keep searches clean

" 
nnoremap <leader>t <Esc>:execute 'ts ' . expand('<cword>')<CR>


" ==========
" Copy to host clipboard
" ==========

let g:oscyank_max_length = 0  " maximum length of a selection, 0 for unlimited length
let g:oscyank_silent     = 0  " enable message on successful copy
let g:oscyank_trim       = 0  " trim surrounding whitespaces before copy

nmap <leader>] <Plug>OSCYankOperator " [NORMAL] copy given text to clipboard
vmap <leader>] <Plug>OSCYankVisual	 " [VISUAL] copy the current selection


" ==========
" Pasting to vim inside a tmux session
" breaks indentation so here's a workaround
" ==========

" Make sure Vim knows bracketed-paste sequences (helps under tmux/screen)
if &term =~# 'screen' || &term =~# 'tmux'
  let &t_BE = "\e[?2004h"
  let &t_BD = "\e[?2004l"
  let &t_PS = "\e[200~"
  let &t_PE = "\e[201~"
endif

" When a paste starts in Normal mode: enable paste + enter Insert
nnoremap <silent> <Esc>[200~ :set paste<CR>i

" If paste starts while already in Insert: just enable paste
inoremap <silent> <Esc>[200~ <C-O>:set paste<CR>

" When paste ends (arrives during Insert): stop paste + go back to Normal
augroup PasteAutoOff
  autocmd!
  autocmd InsertLeave * if &paste | set nopaste | endif
augroup END


" ==========
" LSP config
" ==========

let g:lsp_document_highlight_enabled = 0

" Python
if executable('pylsp')
    " pip install python-lsp-server
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pylsp',
        \ 'cmd': {server_info->['pylsp']},
        \ 'allowlist': ['python'],
        \ })
endif

" C, C++, CUDA, HIP
if executable('clangd')
    augroup lsp_cpp_cuda_hip
        autocmd!
        autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'clangd',
            \ 'cmd': {server_info -> ['clangd', '--background-index']},
            \ 'allowlist': ['c', 'cpp', 'cuda', 'objcpp'],
            \ })
    augroup END
endif

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gs <plug>(lsp-document-symbol-search)
    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
    nnoremap <buffer> <expr><c-d> lsp#scroll(-4)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
    
    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END


" ==========
" Async autocomplete config
" ==========

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"

augroup asyncomplete_lsp
    autocmd!
    autocmd User asyncomplete_setup call asyncomplete#register_source(
        \ asyncomplete#sources#lsp#get_source_options({
        \ 'name': 'lsp',
        \ 'allowlist': ['python'],
        \ 'completor': function('asyncomplete#sources#lsp#completor'),
        \ }))
augroup END
let g:asyncomplete_auto_popup = 1

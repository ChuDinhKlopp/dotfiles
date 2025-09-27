" Enable filetype detection, plugin, and indentation
filetype plugin indent on

" ==========
" UI
" ==========

" Numbering
set number      	" Enable absolute line number
set relativenumber  " Enable relative line number

" Indentation
set tabstop=4       " Set the number of spaces a tab character represents
set shiftwidth=4    " Set the number of spaces to use for indentation
set autoindent
set smartindent
set smarttab

" Statusline 
set laststatus=2
set statusline=
"set statusline+=%2*
set statusline+=%{StatuslineMode()}
"set statusline+=%1*
set statusline+=\ 
set statusline+=<
set statusline+=<
set statusline+=\ 
set statusline+=%f
set statusline+=\ 
set statusline+=>
set statusline+=>
set statusline+=\ 
set statusline+=|
set statusline+=\ 
set statusline+=%n
set statusline+=%=
set statusline+=%m
set statusline+=%h
set statusline+=%r
set statusline+=\ 
"set statusline+=%3*
set statusline+=%{b:gitbranch}
"set statusline+=%1*
set statusline+=\ 
"set statusline+=%4*
set statusline+=%F
set statusline+=:
set statusline+=:
"set statusline+=%5*
set statusline+=%l
set statusline+=/
set statusline+=%L
"set statusline+=%1*
set statusline+=|
set statusline+=%y
set statusline+=|
set statusline+=%P
"hi User2 ctermbg=lightgreen ctermfg=black guibg=lightgreen guifg=black
"hi User1 ctermbg=black ctermfg=white guibg=black guifg=white
"hi User3 ctermbg=black ctermfg=lightblue guibg=black guifg=lightblue
"hi User4 ctermbg=black ctermfg=lightgreen guibg=black guifg=lightgreen
"hi User5 ctermbg=black ctermfg=magenta guibg=black guifg=magenta

function! StatuslineMode()
  let l:mode=mode()
  if l:mode==#"n"
    return "NORMAL"
  elseif l:mode==?"v"
    return "VISUAL"
  elseif l:mode==#"i"
    return "INSERT"
  elseif l:mode==#"R"
    return "REPLACE"
  elseif l:mode==?"s"
    return "SELECT"
  elseif l:mode==#"t"
    return "TERMINAL"
  elseif l:mode==#"c"
    return "COMMAND"
  elseif l:mode==#"!"
    return "SHELL"
  endif
endfunction

function! StatuslineGitBranch()
  let b:gitbranch=""
  if &modifiable
    try
      let l:dir=expand('%:p:h')
      let l:gitrevparse = system("git -C ".l:dir." rev-parse --abbrev-ref HEAD")
      if !v:shell_error
        let b:gitbranch="(".substitute(l:gitrevparse, '\n', '', 'g').") "
      endif
    catch
    endtry
  endif
endfunction

augroup GetGitBranch
  autocmd!
  autocmd VimEnter,WinEnter,BufEnter * call StatuslineGitBranch()
augroup END


" Bell
set noerrorbells  " Disable error bells
set novisualbell  " Disable visual bell (flashing screen)
set belloff=all   " Turn off all bells (including for errors and warnings)

" Cursor
if &term =~ "xterm\\|rxvt\\|tmux"
    let &t_SI = "\e[6 q"  " Vertical bar in insert mode
    let &t_EI = "\e[2 q"  " Full block in normal mode
endif


" ==========
" Toggle file explorer
" ==========
nnoremap <c-b> <Esc>:Lex<cr>:vertical resize 30<cr>


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
" Buffer navigation
" ==========

" Next buffer
noremap <tab> <Esc>:bnext<cr>

" Previous buffer
noremap <s-tab> <Esc>:bprev<cr>

" Switch to buffer with specific ID 
function! SwitchBuffer()
	let buffer_number = nr2char(getchar())
	execute 'b ' . buffer_number
endfunction
nnoremap <leader><tab> :call SwitchBuffer()<cr>

" Switch to most recent buffer
nnoremap <bs> <c-^>


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

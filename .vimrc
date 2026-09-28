" Load standard Vim defaults
source $VIMRUNTIME/vimrc_example.vim

" Basic Visual Settings
set mouse=a                " Enable clicking with the mouse
set title                  " Show the filename in the terminal window title
syntax on                  " Enable color syntax highlighting for code

" Set dark theme if using the graphical version of Vim (GVim)
if has("gui_running")
    colorscheme slate
    highlight Normal guibg=#161616
endif

" Search and Editing Settings
set hlsearch               " Highlight search results
set ignorecase             " Ignore capital letters when searching
set smartcase              " ...unless you type a capital letter
set autoindent             " Carry over indenting to the next line
set smartindent            " Automatically indent after opening brackets {

" Tab and Space Settings (4 spaces per tab)
set tabstop=4
set shiftwidth=4
set softtabstop=4
set textwidth=0
set expandtab              " Convert tabs to spaces automatically

" Auto-close brackets and quotes in Insert mode
inoremap { {}<Left>
inoremap {<CR> {<CR><CR>}<Esc>k
inoremap {{ {
inoremap {} {}
inoremap " ""<Left>
inoremap ' ''<Left>
inoremap ( ()<Left>
inoremap [ []<Left>

" Auto-commenting shortcut for C++ (Press Ctrl+C to comment a line)
autocmd FileType cpp nnoremap <C-C> :s/^\(\s*\)/\1\/\/<CR>:s/^\(\s*\)\/\/\/\//\1<CR>

" Advanced Commenting setup (Ctrl+_ and Ctrl+? in Visual Mode for various languages)
augroup visual_commenting
    autocmd!
    autocmd FileType c,cpp,java,rust  let b:comment_symbol = '//'
    autocmd FileType vim              let b:comment_symbol = '"'
    autocmd FileType sh,vim,python    let b:comment_symbol = '#'
    autocmd FileType tex              let b:comment_symbol = '%'
    autocmd BufEnter * silent! vnoremap <silent> <C-_> :<C-u>keepp '<,'>s@^@\=b:comment_symbol<CR>
    autocmd BufEnter * silent! exec 'vnoremap <silent> <C-?> :<C-u>keepp ''<,''>s@^' . b:comment_symbol . '@<CR>'
augroup END

" Line Numbers (Shows distance to lines while editing, exact line number otherwise)
set number
augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
    autocmd BufLeave,FocusLost,InsertEnter * set norelativenumber
augroup END

" C++ Compile and Run Shortcuts
" Press F9 to Save, create a cppexe folder if missing, and Compile into it
nnoremap <F9> :w <Bar> silent !setsid gnome-terminal -- zsh -c "cd '%:p:h' && mkdir -p cppexe && g++ -std=c++17 -Wall -Wextra -Wshadow -g '%:t' -o 'cppexe/%:t:r'; echo; echo 'Press Enter to close...'; read"<CR>:redraw!<CR>

" Press F6 to Run the compiled output from the cppexe folder
nnoremap <F6> :silent !setsid gnome-terminal -- zsh -c "cd '%:p:h' && ./cppexe/'%:t:r'; echo; echo 'Press Enter to close...'; read"<CR>:redraw!<CR>

" File Comparison Settings (Diff tool configurations)
set diffexpr=MyDiff()
function! MyDiff()
    let opt = '-a --binary '
    if &diffopt =~ 'icase' | let opt .= '-i ' | endif
    if &diffopt =~ 'iwhite' | let opt .= '-b ' | endif
    let arg1 = shellescape(v:fname_in)
    let arg2 = shellescape(v:fname_new)
    let arg3 = shellescape(v:fname_out)
    let cmd = $VIMRUNTIME . '/diff'
    silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
endfunction

" --- SETUPX09 POWERLINE STATUS BAR ---
set rtp+=$HOME/.local/lib/python3.8/site-packages/powerline/bindings/vim/
set laststatus=2
set t_Co=256
set showcmd

" --- Store temporary files in a centralized location ---
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undodir=~/.vim/undo//

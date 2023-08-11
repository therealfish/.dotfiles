" vim: set ft=vim
so $HOME/.dotfiles/nvim/.plugins  " Load Plug manifest

" ------------------------------------------------------------------------------
" --------------------------------- Functions ----------------------------------
" ------------------------------------------------------------------------------
" Reusable function to prompt the user for input
function! s:PromptForInput(...)
  " Args (optional)
  let l:prompt = get(a:000, 0, 'Input: ')
  let l:default_input = get(a:000, 1, '')

  call inputsave()
  let l:user_input = input(l:prompt)
  call inputrestore()

  if empty(l:user_input)
    let g:user_input = l:default_input
  else
    let g:user_input = l:user_input
  endif
endfunction

" Prompt for a section header and insert it as a comment
function! Header()
    call s:PromptForInput('Section headding: ')
    let l:heading = g:user_input

    call s:PromptForInput('Heading width? (50): ', 50)
    let l:header_width = g:user_input

    call s:PromptForInput('Heading fill character? (-): ', '-')
    let l:header_fill_char = g:user_input

    let l:heading_line = &commentstring[0] . ' ' . repeat(l:header_fill_char, (l:header_width - 2))
    let l:heading_text = &commentstring[0] . '  ' . l:heading

    :put = l:heading_line
    :put = l:heading_text
    :put = l:heading_line
endfunction

function! TFHeader()
    call s:PromptForInput('Section heading: ')
    let l:heading_title = '  ' . g:user_input
    let l:heading_start = '/' . repeat('*', 41)
    let l:heading_end = ' ' . repeat('*', 41) . '/'

    :put = l:heading_start
    :put = l:heading_title
    :put = l:heading_end
endfunction

" Strip trailing whitespace
function! s:StripTrailingWhitespaces()
    if &readonly == 0
            \&& &buftype ==? ''
            \&& &diff == 0
        let l:cur_pos = winsaveview()
        %s/\s\+$//e
        call winrestview(l:cur_pos)
        retab
   endif
endfunction

function! s:WriteIfModifiable()
    if buffer_name('%') !=? ''
                \&& &readonly == 0
                \&& &buftype !=? 'nofile'
                \&& &buftype !=? 'terminal'
                \&& &buftype !=? 'nowrite'
                \&& &diff == 0
                \&& buffer_name('%') !~? 'quickfix-'
        silent w
    endif
endfunction

" Show syntax highlighting being applied at the cursor position
function! SynGroup()
    let l:s = synID(line('.'), col('.'), 1)
    echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfun

" Open previous buffer, wipe current, quit if only one buffer
function! s:WipeBufOrQuit()
    let num_bufs = len(getbufinfo({'buflisted':1}))
    let prev_buf = bufnr('#')
    if num_bufs <= 1
        silent execute 'qall'
    elseif prev_buf == -1 || &buftype !=? ''
        silent execute 'quit'
        if &buftype ==? 'terminal'
            silent execute 'startinsert'
        endif
    else
        silent execute 'buf #'
        if bufnr('#') != -1
            silent execute 'bwipeout! #'
        endif
        if &buftype ==? 'terminal'
            silent execute 'startinsert'
        endif
    endif
endfunction

" Open NERDTree using ProjectRootExe if buffer isn't a terminal
function! s:NvimNerdTreeToggle()
    if &buftype ==? 'terminal'
        silent execute 'NERDTreeToggle'
    else
        silent execute 'ProjectRootExe NERDTreeToggle'
    endif
endfunction

" Make the enter key go into insert mode if on a terminal window
function! s:EnterInsertModeInTerminal()
    echo 'ran'
    if &buftype ==? 'terminal'
        if mode() ==? 'n'
            call startinsert()
        endif
    else
        silent execute 'nohlsearch'
        return '\<CR>'
    endif
endfunction

" Get the path to the current line from the project root
function! s:GetPathToCurrentLine()
    let root = ProjectRootGet()
    let full_path = expand('%:p') . ':' . line('.')
    let basename = split(root, '/')
    let basename = basename[-1]
    let path_from_root = join([basename, substitute(full_path, root, '', '')], '')

    return path_from_root
endfunction

" When opening a new split, create a new term if needed
function! s:OpenNewSplit(splitType)
    if a:splitType ==? '\'
        silent execute 'vsp'
    else
        silent execute 'sp'
    endif

    if &buftype ==? 'terminal'
        silent execute 'term'
    endif
endfunction

" Convert mac or dos line endings to unix
function! s:ConvertLineEndingsToUnix()
    :update
    :edit ++fileformat=dos
    :edit ++fileformat=mac
    :setlocal fileformat=unix
    :write
endfunction

" Toggle spell check
hi clear SpellCap
hi clear SpellRare
hi clear SpellLocal
function! ToggleSpell()
  if !exists('g:showingSpell')
    let g:showingSpell=1
    execute 'hi SpellBad cterm=underline gui=underline'
  endif

  if g:showingSpell==0
    execute 'hi SpellBad cterm=underline gui=underline'
    let g:showingSpell=1
    echom 'Spellcheck enabled'
  else
    execute 'hi clear SpellBad'
    let g:showingSpell=0
    echom 'Spellcheck disabled'
  endif
endfunction

" -----------------------------------------------------------------------------
" -------------------- Vim configuration and key bindings ---------------------
" -----------------------------------------------------------------------------
set fileencodings=ucs-bom,utf-8,latin1
setglobal nobomb
setglobal fileencoding=utf-8
scriptencoding utf-8

" Use a login shell to load .bash_profile
let &shell='/usr/local/bin/bash --login'

" Use space as leader key
let mapleader=' '
nnoremap <space> <leader>
nnoremap <S-space> <leader>

" Config
filetype plugin indent on                " Enable file type detection and do language-dependent indenting.
set autochdir                            " Auto change working directory to that of the current file
set autoread                             " Automatically read files when they have changed
set autowrite                            " Automatically :write before running commands
set backspace=2                          " Backspace deletes like most programs in insert mode
set backspace=indent,eol,start           " Make backspace behave in a sane manner.
set colorcolumn=80                       " Make it obvious where 80 characters is
set complete+=kspell                     " Auto complete with dictionary words when spell check is on
set tags=tags                            " Enable ctags
set diffopt+=vertical                    " Always use vertical diffs
set directory=~/tmp                      " set where swapfile(s) are stored
set fillchars+=vert:\ |
set foldcolumn=0
set foldnestmax=2                        " methods of classes are folded, but not internal statements
set foldenable                           " Code folding config
set foldlevelstart=2
set foldmethod=indent
set formatoptions=croqnlj                " See :help fo-table
set history=50                           " store command history across sessions
set hlsearch                             " highlight search matches
set incsearch                            " do incremental searching
set lazyredraw                           " Disable redraw when executing macros
set list listchars=tab:»·,trail:·,nbsp:· " Display tabs, non-breaking spaces, and trailing whitespace
set mouse=a
set noshowmode                           " hide the mode status line
set nospell spelllang=en_us                " Turn on spell checking by default
set noswapfile                           " disable swap file
set ruler                                " show the cursor position all the time
set scrolloff=2                          " Always show one line above/below the cursor
set secure                               " Prevent shell, write, :au unless file is owned by me
set sessionoptions+=tabpages,globals     " Allow Taboo to maintain tab names across sessions
set showbreak=↳\                         " Indicate wrapped lines
set linebreak
set showcmd                              " display incomplete commands
set splitbelow                           " Open new split panes to the right/bottom
set splitright
set termguicolors                        " Use true color
set timeoutlen=700                       " set a short leader timeout
set wildmode=list:longest,list:full      " Configure auto completion see :help wildmode
if &diff                                 " only for diff mode/vimdiff
set diffopt=filler,context:1000000     " filler is default and inserts empty lines for sync
endif

" Default tabbing preferences
set shiftround
set expandtab
set tabstop=4
set shiftwidth=4

" Relative line numbers
set number
set relativenumber
set numberwidth=5

" Change cursor shape in iTerm2 & tmux
if has('nvim')
    set guicursor=n-c-v-sm:block-Cursor/lCursor,
                \i-ci-ve:ver25-Cursor/lCursor,
                \r-cr-o:hor20-Cursor/lCursor,
                \a:blinkwait0-blinkoff500-blinkon500-Cursor/lCursor
    let g:python3_host_prog = '/Users/ryanfisher/.virtualenvs/nvim/bin/python3'
else
    let &t_SI = "\<ESC>]50;CursorShape=1\x7"
    let &t_SR = "\<ESC>]50;CursorShape=2\x7"
    let &t_EI = "\<ESC>]50;CursorShape=0\x7"
    let &t_SI = "\<ESC>Ptmux;\<ESC>\<ESC>]50;CursorShape=1\x7\<ESC>\\"
    let &t_SR = "\<ESC>Ptmux;\<ESC>\<ESC>]50;CursorShape=2\x7\<ESC>\\"
    let &t_EI = "\<ESC>Ptmux;\<ESC>\<ESC>]50;CursorShape=0\x7\<ESC>\\"
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has('gui_running')) && !exists('syntax_on')
    syntax on
    set synmaxcol=200
endif

" Keep undo history across sessions by storing it in a file
if has('persistent_undo')
    let undo_dir = expand('$HOME/.vim/undo_dir')
    if !isdirectory(undo_dir)
        call mkdir(undo_dir, '', 0700)
    endif
    set undodir=$HOME/.vim/undo_dir
    set undofile
endif

inoremap <C-@> <C-Space>|                                   " Get to next editing point after autocomplete
nnoremap <Leader>o o<Esc>                                   " Quickly insert an empty new line without entering insert mode
nnoremap <Leader>O O<Esc>
inoremap jj <ESC>|                                          " Easy escape from insert/visual mode
inoremap jk <ESC>|                                          " Easy escape from insert/visual mode
vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>|         " Replace selected text
nnoremap \ :ProjectRootCD<CR>:Ag -i<SPACE>|                 " bind \ (backward slash) to grep shortcut
nnoremap <silent> <expr> <CR> &buftype ==# 'quickfix' ? "\<CR>:lclose\|cclose\|noh\<CR>" : ":noh\<CR>\<CR>"
nnoremap K                                                  " Keep searching for man entries by accident
nnoremap Q <Plug>window:quickfix:toggle

" Easy split navigation
nnoremap <silent><leader>\ :call <SID>OpenNewSplit('\')<CR>|        " Open vertical split
nnoremap <silent><leader>\| :call <SID>OpenNewSplit('\|')<CR>|      " Open horizontal split
noremap <C-h> <C-w>h                                       " Move left a window
let g:BASH_Ctrl_j = 'off'
noremap <C-j> <C-w>j                                       " Move down a window
noremap <C-k> <C-w>k                                       " Move up a window
noremap <C-l> <C-w>l                                       " Move right a window
nnoremap <c-w><c-w> <ESC><C-w>=                            " Set windows to equal size
if has('nvim')
    tnoremap <C-h> <C-\><C-n><C-w>h                        " Move left a window
    tnoremap <C-j> <C-\><C-n><C-w>j                        " Move down a window
    tnoremap <C-k> <C-\><C-n><C-w>k                        " Move up a window
    tnoremap <C-l> <C-\><C-n><C-w>l                        " Move right a window
    tnoremap <s-space> <space>
endif

" Easy tab navigation
nnoremap <silent><leader><S-w> :tabclose<CR>                " Move right a window
nnoremap <silent><leader><S-h> :tabprevious<CR>             " Move left a window
nnoremap <silent><leader><S-l> :tabnext<CR>                 " Move right a window

" Use magic in search/substitute
nnoremap / /\v\c
vnoremap / /\v\c
cnoremap %% %s/\v
cnoremap %%% s/\v
" cnoremap \>s/ \>smagic/
" nnoremap :g/ :g/\v
" nnoremap :g// :g//

" Utility
nnoremap ` za
nnoremap <leader>qa :call <SID>StripTrailingWhitespaces()<CR>:wa<CR>:qa<CR>|                " Close buffer(s)
nnoremap <silent><leader>q :call <SID>WipeBufOrQuit()<CR>
nnoremap <silent><leader>qq :q<CR>|
nnoremap <silent><leader>Q :q<CR>|
nnoremap <silent><leader>~ :sp<CR>:ProjectRootExe term<CR>:setl nospell<CR>:startinsert<CR>
nnoremap <silent><leader>` :vsp<CR>:ProjectRootExe term<CR>:setl nospell<CR>:startinsert<CR>
nnoremap <silent><leader>s :call ToggleSpell()<CR>
nnoremap <silent><leader>w :call <SID>StripTrailingWhitespaces()<CR>:w<CR>|                 " wtf workaround bc broken from autowrite or...???? Write buffer
" nnoremap <silent><leader>1 :execute 'e ' . getcwd()<CR>|                                    " Open/close NERDTree
nnoremap <silent><leader>1 :ProjectRootExe LightTree<CR>|                                    " Open/close LightTree
nnoremap <silent><leader>2 :LightTreeFind<CR>|                                               " Open/close LightTree
" nnoremap <silent><leader>1 :call <SID>NvimNerdTreeToggle()<CR>|                             " Open/close NERDTree
" nnoremap <silent><leader>2 :ProjectRootExe NERDTreeFind<CR>|                                " Open NERDTree and hilight the current file
" nnoremap <silent><leader>1 <Plug>VinegarUp<CR>|                                             " Open/close NERDTree
nnoremap <silent><leader>3 :TagbarOpenAutoClose<CR>:set relativenumber<CR>|                 " Open NERDTree and hilight the current file
nnoremap <leader>n :enew<CR>|                                                               " Open new buffer in current split
nnoremap <leader>/ :noh<CR>|                                                                " Clear search pattern matches with return
nnoremap <silent><leader>m :Neomake
nnoremap <silent><C-p> :ProjectRootExe Files<CR>|                                           " Open FZF
nnoremap <leader>ha <Plug>GitGutterStageHunk
nnoremap <leader>hr <Plug>GitGutter
nnoremap <silent><leader>l :let @+=<SID>GetPathToCurrentLine()<CR>|                         " Copy curgent line path/number
nnoremap Y y$                                                                               " Make Y act like C and D
nnoremap <leader>d :Dash<CR>

" Find/replace
nnoremap <leader>f :lvim /<C-R>=expand("<cword>")<CR>/ %<CR>:lopen<CR>
nnoremap <silent><leader>F :ProjectRootExe grep! "\b<C-R><C-W>\b"<CR>:bo copen 5<CR>|       " Bind K to grep word under cursor
nnoremap <leader>r :%s/\<<C-r><C-w>\>/

" Cut
nmap <leader>x <Plug>MoveMotionPlug
xmap <leader>x <Plug>MoveMotionXPlug
nmap <leader>xx <Plug>MoveMotionLinePlug
nmap <leader>X <Plug>MoveMotionEndOfLinePlug

" Copy/paste to/from system clipboard
vnoremap <leader>y  "+y
vnoremap <LeftRelease> "+y<LeftRelease>
nnoremap <leader>y  "+y
nnoremap <leader>Y  "+yg_
nnoremap <leader>yy  "+yy
nnoremap <leader>p "+p

" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" -----------------------------------------------------------------------------
" --------------------------- Plugin Configuration ----------------------------
" -----------------------------------------------------------------------------
" NeoVim configuration
if has('nvim') && !exists('g:gui_oni')
    let $VISUAL = 'nvr -cc split --remote-wait'  " Prevent nested neovim instances when using :term
    nnoremap <leader>rc :so ~/.config/nvim/init.vim<CR>|
else
    nnoremap <leader>rc :so $MYVIMRC<CR>:echom $MYVIMRC " reloaded"<CR>|
endif

" Prevent nested neovim instances when using :term
if has('nvim')
  let $VISUAL = 'nvr -cc split --remote-wait'
endif

" Gutentags configuration (https://github.com/ludovicchabant/vim-gutentags)
" let g:gutentags_define_advanced_commands = 1
" let g:Gutentags_modules = ['ctags', 'gtags_cscope']
" let s:python_lib_dirs = get(systemlist('pyenv prefix'), 0, '')
" let g:gutentags_file_list_command = 'rg ' . projectroot#get() . ' ' . s:python_lib_dirs . ' --files'
" " let g:gutentags_ctags_extra_args = ['--python-kinds=-i']
" let g:gutentags_cache_dir = expand('~/.cache/tags')
" let g:gutentags_plus_switch = 1

" Configure fzf (https://github.com/junegunn/fzf and https://github.com/junegunn/fzf.vim)
let g:fzf_commits_log_options = "git log --branches --remotes --graph --color --decorate=short --format=format:'%C(bold blue)%h%C(reset) -%C(auto)%d%C(reset) %C(white)%s%C(reset) %C(black)[%an]%C(reset) %C(bold green)(%ar)%C(reset)"

" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'String'],
  \ 'fg+':     ['fg', 'Statement', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'String'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Type'],
  \ 'pointer': ['fg', 'Constant'],
  \ 'marker':  ['fg', 'Type'],
  \ 'spinner': ['fg', 'Comment'],
  \ 'header':  ['fg', 'Comment'] }

" Customize fzf window
let g:fzf_layout = {'down': '30%'}
let g:fzf_preview_window = ['right:50%']
let g:rg_derive_root='true'

" Configure dash.vim (https://github.com/rizzatti/dash.vim)
let g:dash_activate=0

" Configure vim-markdown (https://github.com/plasticboy/vim-markdown)
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_conceal = 0

let g:vim_markdown_auto_insert_bullets=0
let g:vim_markdown_new_list_item_indent=0
let g:vim_markdown_new_list_item_indent = 0
let g:tex_conceal = ''
let g:vim_markdown_math = 0
let g:vim_markdown_follow_anchor = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_fenced_languages = [
    \ 'viml=vim',
    \ 'bash=bash',
    \ 'java=java',
    \ 'ini=dosini',
    \ 'ansible=ansible',
    \ 'yaml=yaml',
    \ 'md=markdown'
    \ ]

" Configure dkarter/bullets.vim (https://github.com/dkarter/bullets.vim)
" Mappings: let g:bullets_outline_levels = ['num', 'abc', 'std-']
let g:bullets_enabled_file_types = [
    \ 'markdown',
    \ 'text',
    \ 'gitcommit',
    \ 'scratch'
    \]
let g:bullets_outline_levels = ['num', 'std-']
let g:bullets_comments = [
    \ ['^\\s*\\d\\+\\.\\s\\+', ''],
    \ ['^\\s*\\[\\-*\\+]\\s\\+', '']
    \]

" Trying to get auto-complete to work with bullets, not working yet
" let g:bullets_set_mappings = 0
" let g:bullets_custom_mappings = [
"   \ ['inoremap', '<CR>', '<expr> <CR> (pumvisible() ? "\<c-y>" : "<Plug>(bullets-newline)")'],
"   \ ['inoremap', '<C-cr>', '<cr>'],
"   \
"   \ ['nmap', 'o', '<Plug>(bullets-newline)'],
"   \
"   \ ['vmap', 'gN', '<Plug>(bullets-renumber)'],
"   \ ['nmap', 'gN', '<Plug>(bullets-renumber)'],
"   \
"   \ ['nmap', '<leader>x', '<Plug>(bullets-toggle-checkbox)'],
"   \
"   \ ['imap', '<C-t>', '<Plug>(bullets-demote)'],
"   \ ['nmap', '>>', '<Plug>(bullets-demote)'],
"   \ ['vmap', '>', '<Plug>(bullets-demote)'],
"   \ ['imap', '<C-d>', '<Plug>(bullets-promote)'],
"   \ ['nmap', '<<', '<Plug>(bullets-promote)'],
"   \ ['vmap', '<', '<Plug>(bullets-promote)'],
"   \ ]

" Configure vim-markdown-toc (https://github.com/mzlogin/vim-markdown-toc)
let g:vmt_dont_insert_fence = 1
let g:vmt_list_indent = 2

" Configure MarkdownPreview (https://github.com/iamcco/markdown-preview.nvim)
" let g:mkdp_browser = '/Application/Brave Browser.app'
let g:mkdp_echo_preview_url = 1
let g:mkdp_theme = 'light'
let g:mkdp_preview_options = {
    \ 'mkit': {},
    \ 'katex': {},
    \ 'uml': {},
    \ 'maid': {},
    \ 'disable_sync_scroll': 0,
    \ 'sync_scroll_type': 'middle',
    \ 'hide_yaml_meta': 1,
    \ 'sequence_diagrams': {},
    \ 'flowchart_diagrams': {},
    \ 'content_editable': v:false,
    \ 'disable_filename': 1,
    \ 'toc': {}
    \ }

" Configure vim-pydocstring (https://github.com/heavenshell/vim-pydocstring)
let g:pydocstring_formatter = 'google'
let g:pydocstring_doq_path = '/Users/ryanfisher/.local/bin/doq'
nmap <silent> <C-_> <Plug>(pydocstring)

" Configure vim-table-mode (https://github.com/dhruvasagar/vim-table-mode)

" Configure nerdtree-git-plugin (https://github.com/Xuyuanp/nerdtree-git-plugin)
let g:netrw_banner = 0
let NERDTreeHijackNetrw = 1                       " Open in current split with netrw
let NERDTreeShowHidden = 1                        " Show NERDTree
let NERDTreeQuitOnOpen = 1                        " Close NERDTree after file is opened
let NERDTreeWinSize = 0
let NERDTreeAutoDeleteBuffer = 1
let NERDTreeRemoveDirCmd = 'rm -rf '
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ 'Modified'  : '•',
    \ 'Staged'    : '+',
    \ 'Untracked' : '*',
    \ 'Renamed'   : '⇢',
    \ 'Unmerged'  : '═',
    \ 'Deleted'   : 'x',
    \ 'Dirty'     : '✗',
    \ 'Clean'     : '✓',
    \ 'Ignored'   : '⌀',
    \ 'Unknown'   : '?'
    \ }

" Configure machakann/vim-sandwich
runtime macros/sandwich/keymap/surround.vim     " Enable vim-surround keymappings

" Configure (https://github.com/junegunn/vim-easy-align)
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
let g:easy_align_delimiters = {
    \ '#': {
        \ 'pattern': '#\+',
        \ 'ignore_groups': ['String'],
        \ 'delimiter_align': 'l'
    \}
\ }

" Configure NERDCommenter scrooloose/nerdcommenter
let g:NERDSpaceDelims = 1                                             " Add spaces after comment delimiters by default
let g:NERDCompactSexyComs = 1                                         " Use compact syntax for prettified multi-line comments
let g:NERDDefaultAlign = 'left'                                       " Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDAltDelims_java = 1                                          " Set a language to use its alternate delimiters by default
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } } " Add your own custom formats or override the defaults
let g:NERDCommentEmptyLines = 1                                       " Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDTrimTrailingWhitespace = 1                                  " Enable trimming of trailing whitespace when uncommenting

" Configure vim-easyclip (https://github.com/svermeulen/vim-easyclip)
let g:EasyClipUseCutDefaults = 0
let g:EasyClipUseSubstituteDefaults = 1

" Configure editorconfig-vim (https://github.com/editorconfig/editorconfig-vim)
let g:EditorConfig_exclude_patterns = ['fugitive://.\*', 'scp://.\*']

" Configure neomake (https://github.com/neomake/neomake)
" Customize makers
let g:neomake_vim_maker = {
    \ 'exe': 'vint',
    \ 'args': [
        \ '--style-problem',
        \ '--no-color',
        \ '--enable-neovim',
        \ '-f', '{file_path}:{line_number}:{column_number}:{severity}:{description} ({policy_name})'
    \ ],
    \ 'errorformat': '%f:%l: %m',
    \ }

call neomake#configure#automake('nwr', 1000)
" call neomake#configure#automake('w')  " use when on battery
let g:neomake_ansible_enabled_makers = ['ansiblelint', 'yamllint']
let g:neomake_go_enabled_makers = ['go vet']
let g:neomake_java_enabled_makers = ['mvn']
let g:neomake_javascript_enabled_makers = ['eslint']
let g:neomake_markdown_enabled_makers = ['markdownlint']
let g:neomake_python_enabled_makers = ['flake8', 'python']
let g:neomake_ruby_enabled_makers = ['rubocop', 'rubylint']
let g:neomake_shell_enabled_makers = ['shellcheck']
let g:neomake_text_enabled_makers = ['writegood']
let g:neomake_vim_enabled_makers = ['vint']
let g:neomake_yaml_enabled_makers = ['yamllint']

" Seems to not be working...
" https://github.com/jhinch/nginx-linter
" let g:neomake_nginx_maker = {
"     \ 'exe': 'nginx-linter',
"     \ 'args': ['--include'],
"     \ 'errorformat': '%f:%l:%c: %m',
"     \ }

" Configure auto-pairs (https://github.com/jiangmiao/auto-pairs)
let g:AutoPairsMapCR=0

" Configure FastFold (https://github.com/Konfekt/FastFold)
let g:fastfold_savehook = 0

" Note colors are in the section after the color scheme is loaded
let g:neomake_error_sign = {'text': 'x', 'texthl': 'NeomakeErrorSign'}
let g:neomake_warning_sign = {'text': '!', 'texthl': 'NeomakeWarningSign'}

" Configure vim-auto-save plugin (https://github.com/vim-scripts/vim-auto-save)
let g:auto_save = 1
let g:auto_save_silent = 1        " Do not display the auto-save notification
let g:auto_save_no_updatetime = 1 " do not change the 'updatetime' option

" Configure vim-tmux-navigator (https://github.com/christoomey/vim-tmux-navigator)
let g:tmux_navigator_save_on_switch = 2

" Configure ansible-vim (https://github.com/pearofducks/ansible-vim)
let g:ansible_template_syntaxes = {
        \ '*.python.j2': 'python',
        \ '*.cfg.j2': 'cfg',
        \ '*.php.j2': 'php',
        \ '*.sh.j2': 'sh',
        \ '*.groovy.j2': 'groovy',
        \ '*.conf.j2': 'nginx',
        \ '*.route.j2': 'nginx',
        \ '*.upstream.j2': 'nginx'
    \}
let g:ansible_attribute_highlight = 'ad'
let g:ansible_name_highlight = 'd'
let g:ansible_extra_keywords_highlight = 1
let g:ansible_with_keywords_highlight = 'PreProc'
let g:ansible_normal_keywords_highlight = 'Type'
let g:ansible_yamlKeyName = 'yamlKey'

" Configure vim-stay (https://github.com/zhimsel/vim-stay)
set viewoptions=cursor,folds,slash,unix

" Configure vim-lastplace (https://github.com/farmergreg/vim-lastplace)
" let g:lastplace_ignore = "gitcommit,gitrebase,svn,hgcommit"     " Always put cursor at top when opening these files
" let g:lastplace_ignore_buftype = "terminal,quickfix,nofile,help"

" Configure Neovim Completion Manager (https://github.com/ncm2/ncm2)
" See ncm2 setup for details
set completeopt=noinsert,menuone,noselect
set shortmess+=c
inoremap <c-c> <ESC>
inoremap <expr> <CR> (pumvisible() ? "\<c-y>" : "\<CR>")
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Configure ncm2-utilisnips (https://github.com/ncm2/ncm2-ultisnips)
let g:UltiSnipsJumpForwardTrigger   = '<c-j>'
let g:UltiSnipsJumpBackwardTrigger  = '<c-k>'
let g:UltiSnipsRemoveSelectModeMappings = 0

" Enable chriskempson/vim-tomorrow-theme
colorscheme Tomorrow-Night-Eighties

" Configure nathanaelkane/vim-indent-guides
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0
hi IndentGuidesOdd  guibg=#313131   ctermbg=235
hi IndentGuidesEven guibg=#2d2d2d   ctermbg=237
" hi IndentGuidesOdd  guibg=#2d2d2d   ctermbg=232
" hi IndentGuidesEven guibg=#313131   ctermbg=237

" Configure lightline status bar
set laststatus=2
set noshowmode

if exists('g:gui_oni')
    set laststatus=0 noshowmode
endif

let g:lightline = {
    \ 'colorscheme': 'Tomorrow_Night_Eighties',
    \ 'active': {
    \   'left': [['mode', 'paste'],
    \            ['readonly', 'modified', 'filename']]
    \ },
    \ 'component_function': {
    \   'filename': 'LightLineFilename',
    \ },
    \ 'component': {
    \   'readonly': '%{&readonly?"⭤":""}',
    \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}',
    \ },
    \ 'component_visible_condition': {
    \   'readonly': '(&filetype!="help"&& &readonly)',
    \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
    \ },
    \ 'separator': { 'left': '⮀', 'right': '|' },
    \ 'subseparator': { 'left': '⮁', 'right': '|' }
\ }
    " \   'fugitive': '(&filetype!="help"&&exists("*fugitive#head") && ""!=fugitive#head())'
    " \   'fugitive': '%{&filetype=="help"?"":exists("*fugitive#head")?fugitive#head():"⭠"}'

" Lightline functions
function! LightLineFilename()
    if &buftype !=? 'terminal'
        let limit = 3
        let project_root = projectroot#guess()
        let path = substitute(expand('%:p'), project_root . '/', '', '')
        let trunc_path = path
        let path_len = len(path)
        let max_width = winwidth(0) - 65

        if path_len > max_width
            let max_width += 3
            let trunc_path = '...' . strpart(path, path_len - max_width)
        else
            let trunc_path = path
        endif

        return trunc_path
    endif
endfunction

function! SynStack()
  if !exists('*synstack')
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
" Configure ag (https://github.com/ggreer/the_silver_searcher)
if executable('rg')
  " Use ag over grep
  set grepprg="rg --vimgrep --smart-case --hidden --follow"
endif


" ------------------------------------------------------------------------------
" --------------------------------- Commands -----------------------------------
" ------------------------------------------------------------------------------
" Create a section header
command -nargs=* Header silent! call Header(<args>)
command -nargs=* TFHeader silent! call TFHeader(<args>)

" Define a decrypt/encrypt command to decrypt the current file
command! -nargs=+ -bar DecryptThis silent! !ansible-vault decrypt --vault-password-file ~/.ansible/vault-passwords/<args> %
command! -nargs=+ -bar EncryptThis silent! !ansible-vault encrypt --vault-password-file ~/.ansible/vault-passwords/<args> %

" Terraform
command! -nargs=0 -bar Tff silent! !terraform fmt %:p

" Git aliases
command! -nargs=0 Grbm silent! Git rebase -i origin/master

" Use The Silver Searcher if it is installed
command! -nargs=+ -complete=file -bar Ag silent! grep! <args>|:bo copen 10|redraw!

" Set line endings to unix
command! ConvertEndings silent! call <SID>ConvertLineEndingsToUnix()

" Commands (aliases)
" command! Grc Gsdiff :1 | Gvdiff                 " Open vimdiff/fugitive in 4 splits with base shown
" command! -nargs=? Gd Gdiff <args>               " Alias for Gdiff
" command! Gs Gstatus                             " Alias for Gstatus
" command! Gc Gcommit                             " Alias for Gcommit
" command! -nargs=* -bar G !clear;git <args>      " Alias for Git
" command! WipeReg for i in range(34,122) | silent! call setreg(nr2char(i), []) | endfor

" -----------------------------------------------------------------------------
" ----------------------------- Terminal Colors -------------------------------
" -----------------------------------------------------------------------------
" Set neovim colors for truecolor terminal
" https://neovim.io/doc/user/nvim_terminal_emulator.html#nvim-terminal-emulator-configuration

" Tomorrow_Night_Eighties
" ANSI
let g:terminal_color_0 = '#aaaaaa'
let g:terminal_color_1 = '#f78d8c'
let g:terminal_color_2 = '#a8d4a9'
let g:terminal_color_3 = '#ffd479'
let g:terminal_color_4 = '#78aad6'
let g:terminal_color_5 = '#d7acd6'
let g:terminal_color_6 = '#76d4d6'
let g:terminal_color_7 = '#ffffff'
let g:terminal_color_8 = '#aaaaaa'
let g:terminal_color_9 = '#f78d8c'
let g:terminal_color_10 = '#a8d4a9'
let g:terminal_color_11 = '#ffd479'
let g:terminal_color_12 = '#78aad6'
let g:terminal_color_13 = '#d7acd6'
let g:terminal_color_14 = '#76d4d6'
let g:terminal_color_15 = '#ffffff'

" Truecolor
let g:terminal_color_16 = '#aaaaaa'
let g:terminal_color_17 = '#00005f'
let g:terminal_color_18 = '#000087'
let g:terminal_color_19 = '#0000af'
let g:terminal_color_20 = '#0000d7'
let g:terminal_color_21 = '#0000ff'
let g:terminal_color_22 = '#005f00'
let g:terminal_color_23 = '#005f5f'
let g:terminal_color_24 = '#005f87'
let g:terminal_color_25 = '#005faf'
let g:terminal_color_26 = '#005fd7'
let g:terminal_color_27 = '#005fff'
let g:terminal_color_28 = '#008700'
let g:terminal_color_29 = '#00875f'
let g:terminal_color_30 = '#008787'
let g:terminal_color_31 = '#0087af'
let g:terminal_color_32 = '#0087d7'
let g:terminal_color_33 = '#0087ff'
let g:terminal_color_34 = '#00af00'
let g:terminal_color_35 = '#00af5f'
let g:terminal_color_36 = '#00af87'
let g:terminal_color_37 = '#00afaf'
let g:terminal_color_38 = '#00afd7'
let g:terminal_color_39 = '#00afff'
let g:terminal_color_40 = '#00d700'
let g:terminal_color_41 = '#00d75f'
let g:terminal_color_42 = '#00d787'
let g:terminal_color_43 = '#00d7af'
let g:terminal_color_44 = '#00d7d7'
let g:terminal_color_45 = '#00d7ff'
let g:terminal_color_46 = '#00ff00'
let g:terminal_color_47 = '#00ff5f'
let g:terminal_color_48 = '#00ff87'
let g:terminal_color_49 = '#00ffaf'
let g:terminal_color_50 = '#00ffd7'
let g:terminal_color_51 = '#00ffff'
let g:terminal_color_52 = '#5f0000'
let g:terminal_color_53 = '#5f005f'
let g:terminal_color_54 = '#5f0087'
let g:terminal_color_55 = '#5f00af'
let g:terminal_color_56 = '#5f00d7'
let g:terminal_color_57 = '#5f00ff'
let g:terminal_color_58 = '#5f5f00'
let g:terminal_color_59 = '#5f5f5f'
let g:terminal_color_60 = '#5f5f87'
let g:terminal_color_61 = '#5f5faf'
let g:terminal_color_62 = '#5f5fd7'
let g:terminal_color_63 = '#5f5fff'
let g:terminal_color_64 = '#5f8700'
let g:terminal_color_65 = '#5f875f'
let g:terminal_color_66 = '#5f8787'
let g:terminal_color_67 = '#5f87af'
let g:terminal_color_68 = '#5f87d7'
let g:terminal_color_69 = '#5f87ff'
let g:terminal_color_70 = '#5faf00'
let g:terminal_color_71 = '#5faf5f'
let g:terminal_color_72 = '#5faf87'
let g:terminal_color_73 = '#5fafaf'
let g:terminal_color_74 = '#5fafd7'
let g:terminal_color_75 = '#5fafff'
let g:terminal_color_76 = '#5fd700'
let g:terminal_color_77 = '#5fd75f'
let g:terminal_color_78 = '#5fd787'
let g:terminal_color_79 = '#5fd7af'
let g:terminal_color_80 = '#5fd7d7'
let g:terminal_color_81 = '#5fd7ff'
let g:terminal_color_82 = '#5fff00'
let g:terminal_color_83 = '#5fff5f'
let g:terminal_color_84 = '#5fff87'
let g:terminal_color_85 = '#5fffaf'
let g:terminal_color_86 = '#5fffd7'
let g:terminal_color_87 = '#5fffff'
let g:terminal_color_88 = '#870000'
let g:terminal_color_89 = '#87005f'
let g:terminal_color_90 = '#870087'
let g:terminal_color_91 = '#8700af'
let g:terminal_color_92 = '#8700d7'
let g:terminal_color_93 = '#8700ff'
let g:terminal_color_94 = '#875f00'
let g:terminal_color_95 = '#875f5f'
let g:terminal_color_96 = '#875f87'
let g:terminal_color_97 = '#875faf'
let g:terminal_color_98 = '#875fd7'
let g:terminal_color_99 = '#875fff'
let g:terminal_color_100 = '#878700'
let g:terminal_color_101 = '#87875f'
let g:terminal_color_102 = '#878787'
let g:terminal_color_103 = '#8787af'
let g:terminal_color_104 = '#8787d7'
let g:terminal_color_105 = '#8787ff'
let g:terminal_color_106 = '#87af00'
let g:terminal_color_107 = '#87af5f'
let g:terminal_color_108 = '#87af87'
let g:terminal_color_109 = '#87afaf'
let g:terminal_color_110 = '#87afd7'
let g:terminal_color_111 = '#87afff'
let g:terminal_color_112 = '#87d700'
let g:terminal_color_113 = '#87d75f'
let g:terminal_color_114 = '#87d787'
let g:terminal_color_115 = '#87d7af'
let g:terminal_color_116 = '#87d7d7'
let g:terminal_color_117 = '#87d7ff'
let g:terminal_color_118 = '#87ff00'
let g:terminal_color_119 = '#87ff5f'
let g:terminal_color_120 = '#87ff87'
let g:terminal_color_121 = '#87ffaf'
let g:terminal_color_122 = '#87ffd7'
let g:terminal_color_123 = '#87ffff'
let g:terminal_color_124 = '#af0000'
let g:terminal_color_125 = '#af005f'
let g:terminal_color_126 = '#af0087'
let g:terminal_color_127 = '#af00af'
let g:terminal_color_128 = '#af00d7'
let g:terminal_color_129 = '#af00ff'
let g:terminal_color_130 = '#af5f00'
let g:terminal_color_131 = '#af5f5f'
let g:terminal_color_132 = '#af5f87'
let g:terminal_color_133 = '#af5faf'
let g:terminal_color_134 = '#af5fd7'
let g:terminal_color_135 = '#af5fff'
let g:terminal_color_136 = '#af8700'
let g:terminal_color_137 = '#af875f'
let g:terminal_color_138 = '#af8787'
let g:terminal_color_139 = '#af87af'
let g:terminal_color_140 = '#af87d7'
let g:terminal_color_141 = '#af87ff'
let g:terminal_color_142 = '#afaf00'
let g:terminal_color_143 = '#afaf5f'
let g:terminal_color_144 = '#afaf87'
let g:terminal_color_145 = '#afafaf'
let g:terminal_color_146 = '#afafd7'
let g:terminal_color_147 = '#afafff'
let g:terminal_color_148 = '#afd700'
let g:terminal_color_149 = '#afd75f'
let g:terminal_color_150 = '#afd787'
let g:terminal_color_151 = '#afd7af'
let g:terminal_color_152 = '#afd7d7'
let g:terminal_color_153 = '#afd7ff'
let g:terminal_color_154 = '#afff00'
let g:terminal_color_155 = '#afff5f'
let g:terminal_color_156 = '#afff87'
let g:terminal_color_157 = '#afffaf'
let g:terminal_color_158 = '#afffd7'
let g:terminal_color_159 = '#afffff'
let g:terminal_color_160 = '#d70000'
let g:terminal_color_161 = '#d7005f'
let g:terminal_color_162 = '#d70087'
let g:terminal_color_163 = '#d700af'
let g:terminal_color_164 = '#d700d7'
let g:terminal_color_165 = '#d700ff'
let g:terminal_color_166 = '#d75f00'
let g:terminal_color_167 = '#d75f5f'
let g:terminal_color_168 = '#d75f87'
let g:terminal_color_169 = '#d75faf'
let g:terminal_color_170 = '#d75fd7'
let g:terminal_color_171 = '#d75fff'
let g:terminal_color_172 = '#d78700'
let g:terminal_color_173 = '#d7875f'
let g:terminal_color_174 = '#d78787'
let g:terminal_color_175 = '#d787af'
let g:terminal_color_176 = '#d787d7'
let g:terminal_color_177 = '#d787ff'
let g:terminal_color_178 = '#d7af00'
let g:terminal_color_179 = '#d7af5f'
let g:terminal_color_180 = '#d7af87'
let g:terminal_color_181 = '#d7afaf'
let g:terminal_color_182 = '#d7afd7'
let g:terminal_color_183 = '#d7afff'
let g:terminal_color_184 = '#d7d700'
let g:terminal_color_185 = '#d7d75f'
let g:terminal_color_186 = '#d7d787'
let g:terminal_color_187 = '#d7d7af'
let g:terminal_color_188 = '#d7d7d7'
let g:terminal_color_189 = '#d7d7ff'
let g:terminal_color_190 = '#d7ff00'
let g:terminal_color_191 = '#d7ff5f'
let g:terminal_color_192 = '#d7ff87'
let g:terminal_color_193 = '#d7ffaf'
let g:terminal_color_194 = '#d7ffd7'
let g:terminal_color_195 = '#d7ffff'
let g:terminal_color_196 = '#ff0000'
let g:terminal_color_197 = '#ff005f'
let g:terminal_color_198 = '#ff0087'
let g:terminal_color_199 = '#ff00af'
let g:terminal_color_200 = '#ff00d7'
let g:terminal_color_201 = '#ff00ff'
let g:terminal_color_202 = '#ff5f00'
let g:terminal_color_203 = '#ff5f5f'
let g:terminal_color_204 = '#ff5f87'
let g:terminal_color_205 = '#ff5faf'
let g:terminal_color_206 = '#ff5fd7'
let g:terminal_color_207 = '#ff5fff'
let g:terminal_color_208 = '#ff8700'
let g:terminal_color_209 = '#ff875f'
let g:terminal_color_210 = '#ff8787'
let g:terminal_color_211 = '#ff87af'
let g:terminal_color_212 = '#ff87d7'
let g:terminal_color_213 = '#ff87ff'
let g:terminal_color_214 = '#ffaf00'
let g:terminal_color_215 = '#ffaf5f'
let g:terminal_color_216 = '#ffaf87'
let g:terminal_color_217 = '#ffafaf'
let g:terminal_color_218 = '#ffafd7'
let g:terminal_color_219 = '#ffafff'
let g:terminal_color_220 = '#ffd700'
let g:terminal_color_221 = '#ffd75f'
let g:terminal_color_222 = '#ffd787'
let g:terminal_color_223 = '#ffd7af'
let g:terminal_color_224 = '#ffd7d7'
let g:terminal_color_225 = '#ffd7ff'
let g:terminal_color_226 = '#ffff00'
let g:terminal_color_227 = '#ffff5f'
let g:terminal_color_228 = '#ffff87'
let g:terminal_color_229 = '#ffffaf'
let g:terminal_color_230 = '#ffffd7'
let g:terminal_color_231 = '#ffffff'
let g:terminal_color_232 = '#080808'
let g:terminal_color_233 = '#121212'
let g:terminal_color_234 = '#1c1c1c'
let g:terminal_color_235 = '#262626'
let g:terminal_color_236 = '#303030'
let g:terminal_color_237 = '#3a3a3a'
let g:terminal_color_238 = '#444444'
let g:terminal_color_239 = '#4e4e4e'
let g:terminal_color_240 = '#585858'
let g:terminal_color_241 = '#626262'
let g:terminal_color_242 = '#6c6c6c'
let g:terminal_color_243 = '#767676'
let g:terminal_color_244 = '#808080'
let g:terminal_color_245 = '#8a8a8a'
let g:terminal_color_246 = '#949494'
let g:terminal_color_247 = '#9e9e9e'
let g:terminal_color_248 = '#a8a8a8'
let g:terminal_color_249 = '#b2b2b2'
let g:terminal_color_250 = '#bcbcbc'
let g:terminal_color_251 = '#c6c6c6'
let g:terminal_color_252 = '#d0d0d0'
let g:terminal_color_253 = '#dadada'
let g:terminal_color_254 = '#e4e4e4'
let g:terminal_color_255 = '#eeeeee'

" -----------------------------------------------------------------------------
" ------------------------- Highlight Configuration ---------------------------
" -----------------------------------------------------------------------------
hi Cursor ctermbg=6 guibg=#76d4d6
hi NeomakeErrorSign ctermfg=196 guifg=#d70000
hi NeomakeWarningSign ctermfg=226 guifg=#ffff00
hi FoldColumn guifg=#313131 ctermfg=235

" Custom colors that override any theme loaded to this point
hi Search ctermfg=2 ctermbg=29 guifg=#a8d4a9 guibg=#134f2f
" hi Cursor ctermbg=6 guibg=#2aa198
" hi ColorColumn ctermbg=8 guibg=#003741
" hi Normal ctermbg=NONE guibg=NONE
" hi Comment cterm=italic gui=italic
" hi MatchParen ctermbg=NONE guibg=NONE
" hi GitGutterAdd ctermbg=8 guibg=#003741
" hi GitGutterChange ctermbg=8 guibg=#003741
" hi GitGutterDelete ctermbg=8 guibg=#003741
" hi GitGutterChangeDelete ctermbg=8 guibg=#003741
hi DiffDelete ctermfg=8 ctermbg=0 gui=bold guifg=#2d2d2d guibg=#484A4A
hi DiffAdd ctermbg=108  guibg=#366344
hi DiffChange ctermbg=31 guibg=#385570
hi DiffText ctermbg=208 guibg=#6E3935

" -----------------------------------------------------------------------------
" ------------------------------ Auto Commands --------------------------------
" -----------------------------------------------------------------------------
augroup vimrcEx
    au!

    " Don't change terminal size unless it is redrawn
    "au TermOpen * au <buffer> BufEnter,WinEnter redraw!

    " enable ncm2 for all buffers
    au BufEnter * call ncm2#enable_for_buffer()
    au TextChangedI * call ncm2#auto_trigger()
    au User Ncm2Plugin call ncm2#register_source({
        \ 'on_complete': ['ncm2#on_complete#delay',
        \                  300,
        \                 'ncm2#on_complete#omni',
        \                 'csscomplete#CompleteCSS'],
        \ })

    " Configure vim-javacomplete2 (https://github.com/artur-shaik/vim-javacomplete2)
    " autocmd FileType java,groovy setlocal omnifunc=javacomplete#Complete

    " Set syntax highlighting and configuration for specific file types
    au BufRead,BufNewFile Appraisals setl ft=ruby
    au BufRead,BufNewFile *sudoers-* setl ft=sudoers
    au BufRead,BufNewFile .vimrc setl ft=vim
    au BufRead,BufNewFile */orchestration/*.yml setl ft=yaml.ansible
    au BufRead,BufNewFile Jenkinsfile setl ft=groovy
    au BufRead,BufNewFile .envrc setl ft=sh
    au BufRead,BufNewFile dockerfile.* setl ft=Dockerfile
    au BufRead,BufNewFile */gcloud_vars/.* set ft=sh
    au BufRead,BufNewFile .markdownlintrc setl ft=json
    au BufRead,BufNewFile .tfstate setl ft=hcl

    " Enable textwrap for Markdown
    au FileType markdown setl
        \ textwidth=80
        \ formatoptions+=t
        \ formatoptions-=q

    " Wrap at 72 characters git commit messages
    au FileType gitcommit setl filetype=markdown
        \ textwidth=72
        \ colorcolumn=50,72
        \ commentstring=#%s
        \ formatoptions+=t

    " Set Makefile filetype and don't expand tabs
    au BufRead,BufNewfile Makefile* setl ft=make noexpandtab tabstop=4
    au FileType make setl noexpandtab tabstop=4

    " :set nowrap for some files
    au BufRead, BufNewFile user_list.yml, */environments/000_cross_env_users.yml
        \ setl nowrap

    " Allow style sheets to auto-complete hyphenated words
    au FileType css,scss,sass setl iskeyword+=-

    " Remove tabs and trailing whitespace on open and insert
    au BufRead,BufLeave,TextChanged *
        \ call <SID>StripTrailingWhitespaces()

    " Autosave
    au TextChanged * call <SID>WriteIfModifiable()

    " Autoread
    au CursorHold,CursorHoldI,FocusGained,BufEnter * checktime

    " Auto lint on write or change
    au BufWritePost,TextChanged * Neomake

    " Configure terminal settings
    au TermOpen * setl nospell
        \ nonumber
        \ norelativenumber

    " Force spell/nospell
    au FileType markdown,mkd,gitcommit,textile,text setl spell
    au FileType markdown,mkd,gitcommit,textile,text call lexical#init()
    au FileType text call lexical#init({ 'spell': 0 })

    " Bind q to close quickfix
    au FileType quickfix nnoremap q :cclose

    " Hide the status line for FZF buffer
    au! FileType fzf
        au  FileType fzf setl laststatus=0 noshowmode noruler
        \| au BufLeave <buffer> setl laststatus=2 showmode ruler

" augroup END

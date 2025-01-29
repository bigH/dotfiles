-- no longer present huge banner when swap file differs
vim.opt.shortmess:append 'c'
vim.opt.path:append '**'

local options = {
    -- basics
    fileencodings = 'utf-8',
    encoding = 'utf-8',

    -- part of typical sane defaults even though they're redundant
    hidden = true,
    compatible = false,

    -- automatically reload files on change
    autoread = true,

    -- search and replace
    hlsearch = true,
    smartcase = true,
    ignorecase = true,
    incsearch = true,
    infercase = true,
    inccommand = 'split',

    -- indentation
    autoindent = true,
    smartindent = true,
    expandtab = true,
    smarttab = false,
    shiftround = true,
    shiftwidth = 2,
    tabstop = 2,

    -- when wrapping
    breakindent = true,
    breakindentopt = 'shift:2,sbr',
    showbreak = '>>',
    linebreak = true,

    -- always show partial commands
    showcmd = true,

    -- without this, could break plugins
    autochdir = false,

    -- useful to have 2 lines here
    cmdheight = 2,

    -- no spellcheck
    spelllang = 'en',
    spell = false,

    -- wildmenu
    wildmenu = true,
    wildmode = 'list:longest,full',

    -- visual bell
    visualbell = true,

    -- backup
    backup = true,
    writebackup = true,
    backupdir = vim.env.HOME .. '/.nvim-backups//',

    -- undo
    undofile = true,
    undolevels = 5000,
    undoreload = 5000,
    undodir = vim.env.HOME .. '/.nvim-undo//',

    -- swaps
    swapfile = true,
    directory = vim.env.HOME .. '/.nvim-tmp//',

    -- no folding by default
    foldenable = false,

    -- join without extra spaces
    joinspaces = false,

    -- mouse
    mouse = 'a',
    mousehide = true,

    -- don't conceal anything
    conceallevel = 0,

    -- prefered splitting semantics
    splitbelow = true,
    splitright = true,

    -- show special characters and don't wrap
    list = true,
    listchars = 'tab:» ,extends:›,precedes:‹,nbsp:·,trail:·',
    wrap = false,

    -- backspace should eat forever
    backspace = 'indent,eol,start',

    -- show various things in status
    ruler = true,
    showmode = true,

    -- c-u / c-d
    scroll = 10,

    -- pop up configuration
    pumheight = 10,

    -- use term gui colors
    termguicolors = true,

    -- gutter configuration
    number = true,
    relativenumber = true,
    numberwidth = 4,
    signcolumn = 'yes',

    -- show more context at edges of screen
    scrolloff = 3,
    sidescrolloff = 15,

    -- history of 1000
    history = 1000,

    -- NB: I don't like this
    -- anonymous register == system clipboard
    -- clipboard = 'unnamedplus',

    -- TODO?
    completeopt = {'menuone', 'noselect'},

    -- make vim think fast - plugin ramifications are unknown
    timeoutlen = 700,
    updatetime = 300
}

for k, v in pairs(options) do vim.opt[k] = v end


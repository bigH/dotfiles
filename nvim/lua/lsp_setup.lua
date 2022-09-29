local map = require('keymapper')

local n = map.n

local M = {}

function M.setup()
  -- bring in nvim-cmp capabilities
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

  require("lua-dev").setup({})

  local lspconfig = require('lspconfig')

  -- Mappings.
  -- See `:help vim.diagnostic.*` for documentation on any of the below functions
  n('<LEADER>ge', vim.diagnostic.open_float)
  n('[d', vim.diagnostic.goto_prev)
  n(']d', vim.diagnostic.goto_next)
  n('<LEADER>gl', vim.diagnostic.setloclist)

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(_, bufnr)
    -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- buffer-local mappings
    local function bn(a, b)
      n(a, b, { buffer=bufnr })
    end

    bn('<LEADER>gD', vim.lsp.buf.declaration)
    bn('<LEADER>gd', vim.lsp.buf.definition)
    bn('K', vim.lsp.buf.hover)
    bn('<LEADER>gi', vim.lsp.buf.implementation)
    bn('<LEADER>gs', vim.lsp.buf.signature_help)
    bn('<LEADER>gt', vim.lsp.buf.type_definition)
    bn('<LEADER>gr', vim.lsp.buf.rename)
    bn('<LEADER>gg', vim.lsp.buf.code_action)
    bn('<LEADER>gu', vim.lsp.buf.references)
    bn('<LEADER>gf', vim.lsp.buf.formatting)
  end

  local default_server_config = {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 150,
    },
  }

  local function configure_lsp_with_defaults(name, config)
    local total_config = vim.tbl_deep_extend(
      'force',
      default_server_config,
      config or {}
    )
    lspconfig[name].setup(total_config)
  end

  configure_lsp_with_defaults('pyright')
  configure_lsp_with_defaults('tsserver')
  configure_lsp_with_defaults('gopls')
  configure_lsp_with_defaults('rust_analyzer')
  configure_lsp_with_defaults('sumneko_lua', {
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
      },
    },
  })

  local cmp = require('cmp')
  local lspkind = require('lspkind')

  local lspkind_formatter = lspkind.cmp_format({
    with_text = false,
    mode = 'symbol_text',
    maxwidth = 50,
    ellipsis_char = '...',
  })

  local cmp_edit_mapping = function(on_visible)
    return cmp.mapping(
      function(fallback)
        if cmp.visible() then
          on_visible()
        else
          fallback()
        end
      end,
      { 'i', 's', 'c' }
    )
  end

  local cmp_down_mapping = cmp_edit_mapping(cmp.select_next_item)
  local cmp_up_mapping = cmp_edit_mapping(cmp.select_prev_item)

  cmp.setup({
    snippet = {
      expand = function(args)
        -- TODO use some snippet shit
        local line_num, col = unpack(vim.api.nvim_win_get_cursor(0))
        local line_text = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, true)[1]
        local indent = string.match(line_text, '^%s*')
        local replace = vim.split(args.body, '\n', true)
        local surround = string.match(line_text, '%S.*') or ''
        local surround_end = surround:sub(col)

        replace[1] = surround:sub(0, col - 1)..replace[1]
        replace[#replace] = replace[#replace]..(#surround_end > 1 and ' ' or '')..surround_end
        if indent ~= '' then
          for idx, line in ipairs(replace) do
            replace[idx] = indent..line
          end
        end

        vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, true, replace)
      end,
    },
    window = {
      completion = {
        winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
        col_offset = -3,
        side_padding = 0,
      },
    },
    formatting = {
      fields = { "kind", "abbr", "menu" },
      format = function(entry, vim_item)
        local kind = lspkind_formatter(entry, vim_item)
        local strings = vim.split(kind.kind, "%s", { trimempty = true })

        kind.kind = " " .. strings[1] .. " "
        kind.menu = "    (" .. strings[2] .. ")"

        return kind
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-u>'] = cmp.mapping.scroll_docs(4),
      ['<C-SPACE>'] = cmp.mapping.complete({}),
      ['<CR>'] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      }),
      ['<C-n>'] = cmp_down_mapping,
      ['<Tab>'] = cmp_down_mapping,
      ['<C-p>'] = cmp_up_mapping,
      ['<S-Tab>'] = cmp_up_mapping,
    }),
    sources = cmp.config.sources({
      { name = 'emoji' },
      { name = 'nvim_lsp' },
    }, {
      { name = 'treesitter' },
      { name = 'buffer' },
      { name = 'path' },
    })
  })

  cmp.setup.cmdline(':', {
    sources = {
      { name = 'path' },
      { name = 'cmdline' },
      { name = 'cmdline_history' },
    },
  })

  for _, cmd_type in ipairs({'/', '?'}) do
    cmp.setup.cmdline(cmd_type, {
      sources = {
        { name = 'buffer' },
        { name = 'cmdline_history' },
      },
    })
  end

  cmp.setup.cmdline('@', {
    sources = {
      { name = 'cmdline_history' },
    },
  })
end

return M

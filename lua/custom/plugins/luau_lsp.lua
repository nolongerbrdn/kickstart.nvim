local function rojo_project()
  return vim.fs.root(0, function(name)
    return name:match '.+%.project%.json$'
  end)
end

-- [[ Luau filetype detection ]]
-- Automatically recognise .lua as luau files in a Roblox project
if rojo_project() then
  vim.filetype.add {
    extension = {
      lua = function(path)
        return path:match '%.nvim%.lua$' and 'lua' or 'luau'
      end,
    },
  }
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

return {
  'lopi-py/luau-lsp.nvim',
  config = function()
    -- We call `require("luau-lsp").setup` instead of `require("lspconfig").luau_lsp.setup` because luau-lsp.nvim will
    -- add extra features to luau-lsp, so we don't need to call lspconfig's setup
    --
    -- See https://github.com/lopi-py/luau-lsp.nvim
    require('luau-lsp').setup {
      platform = {
        type = rojo_project() and 'roblox' or 'standard',
      },
      plugin = {
        enabled = true,
      },
      server = {
        capabilities = capabilities,
        settings = {
          ['luau-lsp'] = {
            ignoreGlobs = { '**/_Index/**', 'node_modules/**' },
            completion = {
              imports = {
                enabled = true,
                ignoreGlobs = { '**/_Index/**', 'node_modules/**' },
              },
            },
            require = {
              -- luau-lsp does not yet support .luaurc aliases, but we can use a helper function included in
              -- luau-lsp.nvim
              directoryAliases = require('luau-lsp').aliases(),
            },
          },
        },
      },
    }
  end,
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
}

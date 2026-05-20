return {
  -- disable flash
  { "folke/flash.nvim", enabled = false, optional = true },

  -- easily jump to any location and enhanced f/t motions for Leap
  {
    url = "https://codeberg.org/andyg/leap.nvim.git",
    enabled = true,
    keys = function()
      ---@type LazyKeysSpec[]
      local ret = {}
      for _, key in ipairs({ "f", "F", "t", "T" }) do
        ret[#ret + 1] = { key, mode = { "n", "x", "o" } }
      end
      return ret
    end,
    opts = { labeled_modes = "nx" },
  },
  {
    url = "https://codeberg.org/andyg/leap.nvim.git",
    enabled = true,
    keys = {
      { "s", mode = { "n", "x", "o" }, desc = "Leap Forward to" },
      { "S", mode = { "n", "x", "o" }, desc = "Leap Backward to" },
      { "gs", mode = { "n", "x", "o" }, desc = "Leap from Windows" },
    },
    config = function(_, opts)
      local leap = require("leap")
      for k, v in pairs(opts) do
        leap.opts[k] = v
      end
      leap.add_default_mappings(true)
      vim.keymap.del({ "x", "o" }, "x")
      vim.keymap.del({ "x", "o" }, "X")

      -- leap.nvim broke for me at some point. This make two char search work again. From https://github.com/LazyVim/LazyVim/issues/2379#issuecomment-1898491969
      vim.keymap.set("n", "s", function()
        require("leap").leap({ target_windows = { vim.api.nvim_get_current_win() } })
      end)

      -- ft broke at some point for me. This makes it work again. From https://codeberg.org/andyg/leap.nvim#search-and-motions.
      do
        local function ft(key_specific_args)
          require("leap").leap(vim.tbl_deep_extend("keep", key_specific_args, {
            inputlen = 1,
            inclusive = true,
            opts = {
              -- Force autojump.
              labels = "",
              -- Match the modes where you don't need labels (`:h mode()`).
              safe_labels = vim.fn.mode(1):match("o") and "" or nil,
            },
          }))
        end

        -- A helper function making it easier to set "clever-f" behavior
        -- (using f/F or t/T instead of ;/, - see the plugin clever-f.vim).
        local clever = require("leap.user").with_traversal_keys
        local clever_f, clever_t = clever("f", "F"), clever("t", "T")

        vim.keymap.set({ "n", "x", "o" }, "f", function()
          ft({ opts = clever_f })
        end)
        vim.keymap.set({ "n", "x", "o" }, "F", function()
          ft({ backward = true, opts = clever_f })
        end)
        vim.keymap.set({ "n", "x", "o" }, "t", function()
          ft({ offset = -1, opts = clever_t })
        end)
        vim.keymap.set({ "n", "x", "o" }, "T", function()
          ft({ backward = true, offset = 1, opts = clever_t })
        end)
      end
    end,
  },

  -- rename surround mappings from gs to gz to prevent conflict with leap
  {
    "nvim-mini/mini.surround",
    optional = true,
    opts = {
      mappings = {
        add = "gza", -- Add surrounding in Normal and Visual modes
        delete = "gzd", -- Delete surrounding
        find = "gzf", -- Find surrounding (to the right)
        find_left = "gzF", -- Find surrounding (to the left)
        highlight = "gzh", -- Highlight surrounding
        replace = "gzr", -- Replace surrounding
        update_n_lines = "gzn", -- Update `n_lines`
      },
    },
    keys = {
      { "gz", "", desc = "+surround" },
    },
  },

  -- makes some plugins dot-repeatable like leap
  { "tpope/vim-repeat", event = "VeryLazy" },
}

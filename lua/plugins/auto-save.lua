local function is_ju_py_file(buf)
  if not buf then return end

  local bufname = vim.api.nvim_buf_get_name(buf)

  if bufname:match "%.ju%.py$" then
    return true
  else
    return false
  end
end

---@type LazySpec
return {
  "chaozwn/auto-save.nvim",
  event = { "User AstroFile", "InsertEnter" },
  opts = {
    debounce_delay = 3000,
    print_enabled = false,
    trigger_events = { "TextChanged" },
    condition = function(buf)
      local fn = vim.fn
      local utils = require "auto-save.utils.data"

      if fn.getbufvar(buf, "&modifiable") == 1 and utils.not_in(fn.getbufvar(buf, "&filetype"), {}) then
        -- check weather not in normal mode
        if fn.mode() ~= "n" then
          return false
        else
          if is_ju_py_file(buf) then
            return false
          else
            return true
          end
        end
      end
      return false -- can't save
    end,
    callbacks = {
      before_saving = function()
        -- save global autoformat status
        vim.g.OLD_AUTOFORMAT = vim.g.autoformat_enabled

        vim.g.autoformat_enabled = false
        vim.g.OLD_AUTOFORMAT_BUFFERS = {}
        -- disable all manually enabled buffers
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
          if vim.b[bufnr].autoformat_enabled then
            table.insert(vim.g.OLD_BUFFER_AUTOFORMATS, bufnr)
            vim.b[bufnr].autoformat_enabled = false
          end
        end
      end,
      after_saving = function()
        -- restore global autoformat status
        vim.g.autoformat_enabled = vim.g.OLD_AUTOFORMAT
        -- reenable all manually enabled buffers
        for _, bufnr in ipairs(vim.g.OLD_AUTOFORMAT_BUFFERS or {}) do
          vim.b[bufnr].autoformat_enabled = true
        end
      end,
    },
  },
}

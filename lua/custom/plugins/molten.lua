return {
  {
    'benlubas/molten-nvim',
    version = '^1.0.0', -- use version <2.0.0 to avoid breaking changes
    dependencies = { '3rd/image.nvim' },
    build = ':UpdateRemotePlugins',
    init = function()
      -- these are examples, not defaults. Please see the readme
      vim.g.molten_image_provider = 'image.nvim'
      vim.g.molten_output_win_max_height = 20
      --
      -- I find auto open annoying, keep in mind setting this option will require setting
      -- a keybind for `:noautocmd MoltenEnterOutput` to open the output again
      vim.g.molten_auto_open_output = false

      -- optional, I like wrapping. works for virt text and the output window
      vim.g.molten_wrap_output = true

      -- Output as virtual text. Allows outputs to always be shown, works with images, but can
      -- be buggy with longer images
      vim.g.molten_virt_text_output = true

      -- this will make it so the output shows up below the \`\`\` cell delimiter
      vim.g.molten_virt_lines_off_by_1 = true

      -- don't change the mappings (unless it's related to your bug)
      vim.keymap.set('n', '<localleader>e', ':MoltenEvaluateOperator<CR>')
      vim.keymap.set('n', '<localleader>os', ':noautocmd MoltenEnterOutput<CR>')

      vim.keymap.set('n', '<localleader>mi', ':MoltenInit<CR>')
      vim.keymap.set('n', '<localleader>rr', ':MoltenReevaluateCell<CR>')
      vim.keymap.set('v', '<localleader>r', ':<C-u>MoltenEvaluateVisual<CR>gv')
      vim.keymap.set('n', '<localleader>oh', ':MoltenHideOutput<CR>')
      vim.keymap.set('n', '<localleader>md', ':MoltenDelete<CR>')

      -- if you work with html outputs:
      vim.keymap.set('n', '<localleader>mx', ':MoltenOpenInBrowser<CR>', { desc = 'open output in browser', silent = true })

      vim.keymap.set('n', '<localleader>c', function()
        local start_line = vim.fn.search('^# %%', 'bnW')
        local end_line = vim.fn.search('^# %%', 'nW')
        if end_line == 0 then
          -- go to end of file
          end_line = vim.fn.line '$' + 1
        end

        if start_line > 0 and end_line > start_line + 1 then
          vim.api.nvim_win_set_cursor(0, { start_line + 1, 0 })
          vim.cmd 'normal! V'
          vim.api.nvim_win_set_cursor(0, { end_line - 1, 0 })
        else
          print 'No cell found'
        end
      end, { desc = 'Select current # %% cell' })

      -- Provide a command to create a blank new Python notebook
      -- note: the metadata is needed for Jupytext to understand how to parse the notebook.
      -- if you use another language than Python, you should change it in the template.
      local default_notebook = [[
{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "79b81db6-6d15-46f5-8896-dd81e5c6f748",
   "metadata": {},
   "outputs": [],
   "source": []
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3 (ipykernel)",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
]]

      local function new_notebook(filename)
        local path = filename .. '.ipynb'
        local file = io.open(path, 'w')
        if file then
          file:write(default_notebook)
          file:close()
          vim.cmd('edit ' .. path)
        else
          print 'Error: Could not open new notebook file for writing.'
        end
      end

      vim.api.nvim_create_user_command('NewNotebook', function(opts)
        new_notebook(opts.args)
      end, {
        nargs = 1,
        complete = 'file',
      })
    end,
  },
  -- {
  --   'GCBallesteros/jupytext.nvim',
  --   lazy = false,
  --   config = function()
  --     require('jupytext').setup {
  --       style = 'markdown',
  --       output_extension = 'md',
  --       force_ft = 'markdown',
  --     }
  --   end,
  -- },
  {
    'goerz/jupytext.nvim',
    version = '0.2.0',
    opts = {},
  },
}

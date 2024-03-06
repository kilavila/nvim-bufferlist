local api = vim.api
local buf, win

local pinned_files = {}
local pinned_files_index = 1

local function open_window()
  buf = api.nvim_create_buf(false, true)
  local border_buf = api.nvim_create_buf(false, true)

  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  api.nvim_buf_set_option(buf, 'filetype', 'bufferlist')

  local width = api.nvim_get_option("columns")
  local height = api.nvim_get_option("lines")

  local win_height = math.ceil(height * 0.5 - 4)
  local win_width = math.ceil(width * 0.4)
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  local border_opts = {
    style = 'minimal',
    relative = 'editor',
    width = win_width + 2,
    height = win_height + 2,
    row = row - 1,
    col = col - 1
  }

  local opts = {
    style = 'minimal',
    relative = 'editor',
    width = win_width,
    height = win_height,
    row = row,
    col = col
  }

  local border_title = ' Quick Navigation '
  local border_lines = { '╭' .. border_title .. string.rep('─', win_width - string.len(border_title)) .. '╮' }
  local middle_line = '│' .. string.rep(' ', win_width) .. '│'
  for _ = 1, win_height do
    table.insert(border_lines, middle_line)
  end
  table.insert(border_lines, '╰' .. string.rep('─', win_width) .. '╯')
  api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

  local border_win = api.nvim_open_win(border_buf, true, border_opts)
  win = api.nvim_open_win(buf, true, opts)
  api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "' .. border_buf)

  api.nvim_win_set_option(win, 'cursorline', true)
end

local function add_current_file()
  local current_file = api.nvim_buf_get_name(0)
  table.insert(pinned_files, current_file)
end

local function update_view()
  api.nvim_buf_set_option(buf, 'modifiable', true)

  api.nvim_buf_set_lines(buf, 0, -1, false, pinned_files)
  api.nvim_buf_set_option(buf, 'modifiable', true)
end

local function update_pinned_files()
  pinned_files = {}
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)

  if #lines ~= 0 then
    for _, line in ipairs(lines) do
      if line ~= '' then
        table.insert(pinned_files, line)
      end
    end
  end
end

local function close_window()
  update_pinned_files()
  api.nvim_win_close(win, true)
end

local function go_to_file()
  local selected_line = api.nvim_get_current_line()

  close_window()
  api.nvim_command('edit ' .. selected_line)
end

local function move_cursor()
  local new_pos = math.max(4, api.nvim_win_get_cursor(win)[1] - 1)
  api.nvim_win_set_cursor(win, { new_pos, 0 })
end

local function set_mappings()
  local mappings = {
    ['<esc>'] = 'close_window()',
    ['<cr>'] = 'go_to_file()',
  }

  for k, v in pairs(mappings) do
    api.nvim_buf_set_keymap(buf, 'n', k, ':lua require"nvim-quicknav".' .. v .. '<cr>', {
      nowait = true, noremap = true, silent = true
    })
  end

  --[[ local other_chars = {
    'a', 'b', 'c', 'e', 'f', 'g', 'i', 'n', 'o', 'p', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
  }

  for _, v in ipairs(other_chars) do
    api.nvim_buf_set_keymap(buf, 'n', v, '', { nowait = true, noremap = true, silent = true })
    api.nvim_buf_set_keymap(buf, 'n', v:upper(), '', { nowait = true, noremap = true, silent = true })
    api.nvim_buf_set_keymap(buf, 'n', '<c-' .. v .. '>', '', { nowait = true, noremap = true, silent = true })
  end ]]
end

local function get_pinned_index(direction)
  if direction == 'next' then
    if pinned_files_index < #pinned_files then
      pinned_files_index = pinned_files_index + 1
    else
      pinned_files_index = 1
    end
  else
    if pinned_files_index > #pinned_files then
      pinned_files_index = #pinned_files
    elseif pinned_files_index > 1 then
      pinned_files_index = pinned_files_index - 1
    else
      pinned_files_index = #pinned_files
    end
  end

  return pinned_files_index
end

local function go_to_next_file()
  local index = get_pinned_index('next')
  vim.cmd('edit ' .. pinned_files[index])
end

local function go_to_prev_file()
  local index = get_pinned_index('prev')
  vim.cmd('edit ' .. pinned_files[index])
end

local function quicknav()
  open_window()
  update_view()
  set_mappings()
  api.nvim_win_set_cursor(win, { 1, 0 })
end

return {
  quicknav = quicknav,
  add_current_file = add_current_file,
  update_view = update_view,
  go_to_file = go_to_file,
  move_cursor = move_cursor,
  close_window = close_window,
  go_to_next_file = go_to_next_file,
  go_to_prev_file = go_to_prev_file
}

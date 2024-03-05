local api = vim.api
local buf, win

local function center(str)
  local width = api.nvim_win_get_width(0)
  local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
  return string.rep(' ', shift) .. str
end

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

  local border_title = ' Buffer List '
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

local function update_view()
  api.nvim_buf_set_option(buf, 'modifiable', true)

  local ls = vim.fn.execute(':ls')
  local result = {}

  for buffer in string.gmatch(ls, '([^\r\n]*)') do
    if string.match(buffer, '%d+') then
      if string.match(buffer, '%d+.-(a).-".-"') == 'a' and string.match(buffer, '"(.-)"') ~= '[No Name]' then
        buffer = string.match(buffer, '"(.-)"')
        table.insert(result, "> " .. buffer)
      else
        buffer = string.match(buffer, '"(.-)"')
        table.insert(result, buffer)
      end
    end
  end

  api.nvim_buf_set_lines(buf, 0, -1, false, result)
  api.nvim_buf_set_option(buf, 'modifiable', false)
end

local function close_window()
  api.nvim_win_close(win, true)
end

local function close_buffer()
  local selected_line = api.nvim_get_current_line()

  if string.match(selected_line, '^> ') then
    selected_line = string.match(selected_line, '^> (.-)$')
  end

  local ls = vim.fn.execute(':ls')

  for buffer in string.gmatch(ls, '([^\r\n]*)') do
    if string.match(buffer, '%d+') and string.match(buffer, '"(.-)"') == selected_line then
      if string.match(buffer, '%d+.-(a).-".-"') == 'a' then
        close_window()
        api.nvim_command('bd')
      else
        api.nvim_command('bd ' .. string.match(buffer, '%d+'))
        update_view()
      end
    end
  end
end

local function go_to_buffer()
  local selected_line = api.nvim_get_current_line()

  local ls = vim.fn.execute(':ls')

  for buffer in string.gmatch(ls, '([^\r\n]*)') do
    if string.match(buffer, '%d+') and string.match(buffer, '"(.-)"') == selected_line then
      close_window()
      api.nvim_command('b ' .. string.match(buffer, '%d+'))
    end
  end
end

local function move_cursor()
  local new_pos = math.max(4, api.nvim_win_get_cursor(win)[1] - 1)
  api.nvim_win_set_cursor(win, { new_pos, 0 })
end

local function set_mappings()
  local mappings = {
    ['<esc>'] = 'close_window()',
    ['<cr>'] = 'go_to_buffer()',
    l = 'go_to_buffer()',
    h = 'close_buffer()',
    d = 'close_buffer()',
    q = 'close_window()',
  }

  for k, v in pairs(mappings) do
    api.nvim_buf_set_keymap(buf, 'n', k, ':lua require"nvim-bufferlist".' .. v .. '<cr>', {
      nowait = true, noremap = true, silent = true
    })
  end

  local other_chars = {
    'a', 'b', 'c', 'e', 'f', 'g', 'i', 'n', 'o', 'p', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
  }

  for _, v in ipairs(other_chars) do
    api.nvim_buf_set_keymap(buf, 'n', v, '', { nowait = true, noremap = true, silent = true })
    api.nvim_buf_set_keymap(buf, 'n', v:upper(), '', { nowait = true, noremap = true, silent = true })
    api.nvim_buf_set_keymap(buf, 'n', '<c-' .. v .. '>', '', { nowait = true, noremap = true, silent = true })
  end
end

local function bufferlist()
  open_window()
  update_view()
  set_mappings()
  api.nvim_win_set_cursor(win, { 1, 0 })
end

return {
  bufferlist = bufferlist,
  update_view = update_view,
  go_to_buffer = go_to_buffer,
  close_buffer = close_buffer,
  move_cursor = move_cursor,
  close_window = close_window
}

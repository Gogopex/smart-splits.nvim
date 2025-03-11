local Direction = require('smart-splits.types').Direction

local dir_keys_ghostty = {
  [Direction.left] = 'left',
  [Direction.right] = 'right',
  [Direction.up] = 'up',
  [Direction.down] = 'down',
}

local function ghostty_exec(args)
  local command = vim.deepcopy(args)
  table.insert(command, 1, 'ghostty')
  return vim.fn.system(command)
end

local log = require('smart-splits.log')

---@type SmartSplitsMultiplexer
local M = {}

M.type = 'ghostty'

function M.current_pane_id()
  return vim.env.GHOSTTY_PANE_ID
end

function M.current_pane_at_edge(direction)
  -- Ghostty doesn't provide a direct way to check this, so we'll always return false
  return false
end

function M.is_in_session()
  local result = vim.env.GHOSTTY_PANE_ID ~= nil
  log.debug("Ghostty is_in_session: %s", result)
  return result
end

function M.current_pane_is_zoomed()
  -- Ghostty doesn't have a zoom feature, so we'll always return false
  return false
end

function M.next_pane(direction)
  log.debug("Ghostty next_pane called with direction: %s", direction)
  local result = ghostty_exec({ 'pane-focus', dir_keys_ghostty[direction] }) == ''
  log.debug("Ghostty next_pane result: %s", result)
  return result
end

function M.resize_pane(direction, amount)
  log.debug("Ghostty resize_pane called with direction: %s and amount: %s", direction, amount)
  local result = ghostty_exec({ 'pane-resize', dir_keys_ghostty[direction], tostring(amount) }) == ''
  log.debug("Ghostty resize_pane result: %s", result)
  return result
end

function M.split_pane(direction, size)
  log.debug("Ghostty split_pane called with direction: %s and size: %s", direction, size)
  local args = { 'pane-split', dir_keys_ghostty[direction] }
  if size then
    table.insert(args, tostring(size))
  end
  local result = ghostty_exec(args) == ''
  log.debug("Ghostty split_pane result: %s", result)
  return result
end

function M.on_init()
  vim.env.GHOSTTY_INTEGRATION = 'true'
end

function M.on_exit()
  vim.env.GHOSTTY_INTEGRATION = nil
end

return M

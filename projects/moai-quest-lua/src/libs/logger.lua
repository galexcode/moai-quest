--------------------------------------------------------------------------------
-- ログ出力するためのモジュールです.
--------------------------------------------------------------------------------

-- import
local flower = require "flower"
local class = flower.class

-- module
local M = {}

-- Constraints
M.LEVEL_NONE = 0
M.LEVEL_INFO = 1
M.LEVEL_WARN = 2
M.LEVEL_ERROR = 3
M.LEVEL_DEBUG = 4

--------------------------------------------------------------------------------
-- A table to select whether to output the log.
--------------------------------------------------------------------------------
M.selector = {}
M.selector[M.LEVEL_INFO] = true
M.selector[M.LEVEL_DEBUG] = true

--------------------------------------------------------------------------------
-- This is the log target.
-- Is the target output to the console.
--------------------------------------------------------------------------------
M.CONSOLE_TARGET = function(...)
   print(...)
end

--------------------------------------------------------------------------------
-- This is the log target.
--------------------------------------------------------------------------------
M.logTarget = M.CONSOLE_TARGET

---
-- ログを出力します.
-- @param message メッセージ
-- @param ... メッセージ引数
function M.log(message, ...)
    if M.selector[M.LEVEL_INFO] then
        local str = message:format(...)
        M.logTarget("[INFO]", str)
    end
end

---
-- デバッグログを出力します.
-- @param message メッセージ
-- @param ... メッセージ引数
function M.debug(message, ...)
    if M.selector[M.LEVEL_DEBUG] then
        local str = message:format(...)
        local info = debug.getinfo(2)
        M.logTarget("[DEBUG]", "[" .. info.short_src .. ":L" .. info.currentline .. "]", str)
    end
end

return M
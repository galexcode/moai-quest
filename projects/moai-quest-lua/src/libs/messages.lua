--------------------------------------------------------------------------------
-- アプリケーションのメッセージを定義するモジュールです.
--------------------------------------------------------------------------------

-- import
local dofile = flower.Resources.dofile

-- module
local M = {}

-- variables
local messageData = dofile("data/message_data.lua")

---
-- メッセージIDと引数を元に、メッセージを生成します.
-- @param messageId メッセージID
function M:bind(messageId, ...)
    local message = assert(messageData[messageId], "Not Found Message!" .. tostring(messageId))
    return string.format(message, ...)
end

---
-- メッセージを再ロードします.
function M:loadMessageData()
    messageData = dofile("data/message_data.lua")
end

return M
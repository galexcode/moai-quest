----------------------------------------------------------------------------------------------------
-- ゲームのシステムを定義するモジュールです.
----------------------------------------------------------------------------------------------------

-- import
local flower = require "flower"
local class = flower.class
local repositry = require "libs/repositry"

-- module
local M = {}

-- classes
local ItemSystem
local BattleSystem

----------------------------------------------------------------------------------------------------
-- @type ItemSystem
-- アイテムに関するシステムです.
----------------------------------------------------------------------------------------------------
ItemSystem = class()
M.ItemSystem = ItemSystem

function ItemSystem:init()
end

--------------------------------------------------------------------------------
-- アイテムを使用する処理を行います.
-- @param itemId アイテムID
-- @param actorId アクターID
--------------------------------------------------------------------------------
function ItemSystem:useItem(itemId, actorId)
    local bagItem = repositry.getBagItemById(itemId)
    local item = repositry.getItemById(itemId)
    local actor = repositry.getActorById(actorId)
    
    -- TODO:アイテムの効果
    
    repositry.removeBagItem(itemId)
    
    print("useItem", "item_id=" .. bagItem.item_id, "item_count=" .. bagItem.item_count)
end

--------------------------------------------------------------------------------
-- アイテムを使用する処理を行います.
-- @param itemId アイテムID
-- @param actorId アクターID
--------------------------------------------------------------------------------
function ItemSystem:getItem(itemId)

end


return M

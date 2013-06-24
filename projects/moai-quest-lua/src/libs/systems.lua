----------------------------------------------------------------------------------------------------
-- ゲームのシステムを定義するモジュールです.
----------------------------------------------------------------------------------------------------

-- import
local flower = require "flower"
local class = flower.class
local entities = require "libs/entities"
local repositry = entities.repositry

-- module
local M = {}

-- classes
local ItemSystem
local SkillSystem
local BattleSystem
local LevelUpSystem

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
end

--------------------------------------------------------------------------------
-- アイテムを使用する処理を行います.
-- @param itemId アイテムID
-- @param actorId アクターID
--------------------------------------------------------------------------------
function ItemSystem:getItem(itemId)

end

----------------------------------------------------------------------------------------------------
-- @type SkillSystem
-- スキルを使用するためのシステムです.
----------------------------------------------------------------------------------------------------
SkillSystem = class()
M.SkillSystem = SkillSystem

function SkillSystem:init()

end

function SkillSystem:useSkill(actorId, skillId)
    local actor = repositry.getActorById(actorId)
    local skill = repositry.getSkillById(skillId)
    
end


return M

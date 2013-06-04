----------------------------------------------------------------------------------------------------
-- ゲームデータにアクセスするリポジトリモジュールです.
----------------------------------------------------------------------------------------------------

-- import
local flower = require "flower"
local table = flower.table

-- module
local M = {}

----------------------------------------------------------------------------------------------------
-- Variables
----------------------------------------------------------------------------------------------------

-- data maps
local itemMap = {}
local skillMap = {}

--------------------------------------------------------------------------------
-- ゲームデータを初期化します.
--------------------------------------------------------------------------------
function M.initData()
    M.actor_data = dofile("data/actor_data.lua")
    M.bag_data = dofile("data/bag_data.lua")
    M.item_data = dofile("data/item_data.lua")
    M.menu_data = dofile("data/menu_data.lua")
    M.msg_data = dofile("data/msg_data.lua")
    M.member_data = dofile("data/member_data.lua")
    M.player_data = dofile("data/player_data.lua")
    M.skill_data = dofile("data/skill_data.lua")
end

--------------------------------------------------------------------------------
-- ゲームデータをロードします.
--------------------------------------------------------------------------------
function M.loadData()
end

--------------------------------------------------------------------------------
-- ゲームデータをセーブします.
--------------------------------------------------------------------------------
function M.saveData()

end

--------------------------------------------------------------------------------
-- メインメニューのリストを返します.
--------------------------------------------------------------------------------
function M.getMainMenus()
    return M.menu_data.main_list
end

--------------------------------------------------------------------------------
-- アイテムを表示するメニューリストを返します.
--------------------------------------------------------------------------------
function M.getItemMenus()
    local menus = {}
    for i, data in ipairs(M.bag_data) do
        local item = M.getItemById(data.item_id)
        local menu = {label = item.name, item = item, msg = item.msg}
        table.insert(menus, menu)
    end
    return menus
end

--------------------------------------------------------------------------------
-- 指定したアクターが保持するスキルのメニューリストを返します.
--------------------------------------------------------------------------------
function M.getSkillMenus(actorId)
    local menus = {}
    local actor = M.getActorById(actorId)
    for i, skillNo in ipairs(actor.skills) do
        local skill = M.getSkillById(skillNo)
        local menu = {label = skill.name, data = skill, msg = "ダミー"}
        table.insert(menus, menu)
    end
    return menus
end

--------------------------------------------------------------------------------
--メンバーのリストを返します.
--------------------------------------------------------------------------------
function M.getMembers()
    local actors = {}
    for i, data in ipairs(M.member_data) do
        local actor = M.getActorById(data.actor_id)
        table.insert(actors, actor)
    end
    return actors
end

--------------------------------------------------------------------------------
-- アクターを返します.
-- @param id actor_id
--------------------------------------------------------------------------------
function M.getActorById(id)
    assert(id)
    for i, data in ipairs(M.actor_data) do
        if data.id == id then
            return data
        end
    end
end

--------------------------------------------------------------------------------
-- アクターが装備しているアイテムの一覧を返します.
-- @param id actor_id
--------------------------------------------------------------------------------
function M.getActorEquipItems(id)
    assert(id)
    local actor = M.getActorById(id)
    local items = {}
    for i, itemId in ipairs(actor.equipItems) do
        local item = M.getItemById(itemId)
        table.insert(items, item)
    end
    return items
end

--------------------------------------------------------------------------------
-- アイテムを返します.
-- @param id item_id
--------------------------------------------------------------------------------
function M.getItemById(id)
    assert(id)
    for i, item in ipairs(M.item_data) do
        if item.id == id then
            return item
        end
    end
end

--------------------------------------------------------------------------------
-- バッグの中に存在するアイテムを返します.
-- バッグの中に存在しない場合は、アイテムを返しません.
-- @param id item_id
--------------------------------------------------------------------------------
function M.getBagItemById(id)
    assert(id)
    for i, bagItem in ipairs(M.bag_data) do
        if bagItem.item_id == id then
            return bagItem
        end
    end
end

--------------------------------------------------------------------------------
-- バッグのアイテム数を追加します.
-- バッグにアイテムが存在しない場合は新規に追加します.
-- @param id item_id
-- @param count (option)item_count
--------------------------------------------------------------------------------
function M.addBagItem(id, count)
    assert(id)
    count = count or 1
    
    local bagItem = M.getBagItemById(id)
    if not bagItem then
        bagItem = {item_id = id, item_count = 0}
        table.insert(M.bag_data, bagItem)
        -- TODO:アイテムのソート
    end
    bagItem.item_count = bagItem.item_count + count
end

--------------------------------------------------------------------------------
-- バッグのアイテム数を減らします.
-- バッグにアイテムが存在しない場合は更新しません.
-- @param id item_id
-- @param count (option)item_count
--------------------------------------------------------------------------------
function M.removeBagItem(id, count)
    assert(id)
    count = count or 1
    
    local bagItem = M.getBagItemById(id)
    if bagItem then
        bagItem.item_count = bagItem.item_count - count
        
        if bagItem.item_count <= 0 then
            table.removeElement(M.bag_data, bagItem)
        end
    end
end


--------------------------------------------------------------------------------
-- スキルを返します.
--------------------------------------------------------------------------------
function M.getSkillById(id)
    assert(id)
    for i, skill in ipairs(M.skill_data) do
        if skill.id == id then
            return skill
        end
    end
end

M.initData()

return M

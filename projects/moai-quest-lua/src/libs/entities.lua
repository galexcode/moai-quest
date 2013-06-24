----------------------------------------------------------------------------------------------------
-- ゲームのエンティティを定義するモジュールです.
----------------------------------------------------------------------------------------------------

-- module
local M = {}

-- import
local flower = require "flower"
local class = flower.class
local table = flower.table

-- classes
local Entity
local EntityPool
local EntityRepositry
local Skill
local Item
local Menu
local Message
local Actor
local Player
local Enemy
local Team
local Bag
local BagItem

-- variables
local entityPool
local entityRepositry

---
-- モジュールの初期化処理を行います.
function M.initialize()
    entityRepositry = EntityRepositry()
    entityPool = EntityPool()
    
    entityPool:initEntities()
    
    M.repositry = entityRepositry
end

--------------------------------------------------------------------------------
-- @type Entity
-- エンティティの共通的な振る舞いを定義するクラスです.
--------------------------------------------------------------------------------
Entity = class()

function Entity:init()
end

---
-- データからエンティティにプロパティを読み込みます.
-- デフォルト実装は、単なるコピーです.
function Entity:loadData(data)
    table.copy(data, self)
end

---
-- エンティティからデータにプロパティを保存します.
-- デフォルト実装は単なるコピーです.
function Entity:saveData()
    local data = table.copy(self)
    data.__index = nil
    data.__class = nil
    return data
end

--------------------------------------------------------------------------------
-- @type EntityPool
-- エンティティをメモリ上にプールする為のクラスです.
--------------------------------------------------------------------------------
EntityPool = class()

---
-- コンストラクタ
function EntityPool:init()
end

---
-- エンティティを初期化します.
function EntityPool:initEntities()
    self.skills = self:createEntities(Skill, dofile("data/skill_data.lua"))
    self.items = self:createEntities(Item, dofile("data/item_data.lua"))
    self.menus = self:createEntities(Menu, dofile("data/menu_data.lua"))
    self.actors = self:createEntities(Actor, dofile("data/actor_data.lua"))
    self.enemies = self:createEntities(Enemy, dofile("data/enemy_data.lua"))
    self.bagItems = self:createEntities(BagItem, dofile("data/bag_data.lua"))
    self.teams = self:createEntities(Team, dofile("data/team_data.lua"))
end

---
-- セーブしていたエンティティを読み込みます.
function EntityPool:loadEntities(saveId)
    self.actors = self:createEntities(Actor, dofile("save" .. saveId .. "/actor_data.lua"))
    self.bagItems = self:createEntities(Actor, dofile("save" .. saveId .. "/bag_data.lua"))
    self.teams = self:createEntities(Actor, dofile("save" .. saveId .. "/team_data.lua"))
end

---
-- メモリ上のエンティティを保存します.
function EntityPool:saveEntities(saveId)
    -- TODO:実装
end

---
-- 指定したエンティティクラスを作成してデータをロードして返します.
-- @param clazz エンティティのクラス
-- @param entityDataList エンティティデータリスト
function EntityPool:createEntities(clazz, entityDataList)
    local entities = {}
    for i, data in ipairs(entityDataList) do
        local entity = clazz()
        entity:loadData(data)
        table.insertElement(entities, entity)
    end
    return entities
end

--------------------------------------------------------------------------------
-- @type EntityRepositry
-- エンティティにアクセスするリポジトリクラスです.
--------------------------------------------------------------------------------
EntityRepositry = class()

---
-- コンストラクタです.
function EntityRepositry:init()
end

---
-- 指定したエンティティリストについて、IDが一致するエンティティを返します.
-- @return IDが一致するエンティティ
function EntityRepositry:getEntityById(entities, id)
    for i, entity in ipairs(entities) do
        if entity.id == id then
            return entity
        end
    end
end

---
-- 全てのアクターリストを返します.
-- @return アクターリスト
function EntityRepositry:getActors()
    return entityPool.actors
end

---
-- 指定したIDに一致するアクターを返します.
-- @return アクター
function EntityRepositry:getActorById(id)
    return self:getEntityById(entityPool.actors, id)
end

---
-- 全てのアイテムリストを返します.
-- @return アイテムリスト
function EntityRepositry:getItems()
    return entityPool.items
end

---
-- 指定したIDに一致するアイテムを返します.
-- @return アイテム
function EntityRepositry:getItemById(id)
    return self:getEntityById(entityPool.items, id)
end

---
-- 全てのスキルリストを返します.
-- @return スキルリスト
function EntityRepositry:getSkills()
    return entityPool.skills
end

---
-- 指定したIDに一致するスキルを返します.
-- @return スキル
function EntityRepositry:getSkillById(id)
    return self:getEntityById(entityPool.skills, id)
end


---
-- バッグアイテムリストを返します.
-- @return バッグアイテムリスト
function EntityRepositry:getBagItems()
    return entityPool.bagItems
end

---
-- メニューリストを返します.
-- @return メニューリスト
function EntityRepositry:getMenus()
    return entityPool.menus
end

---
-- 指定したIDと同一のエネミーを作成して返します.
-- @param id エネミーID
-- @return エネミー
function EntityRepositry:createEnemy(id)
    local enemy = self:getEntityById(entityPool.enemies, id)
    return enemy:clone()
end

--------------------------------------------------------------------------------
-- @type Item
-- アイテムを定義するエンティティです.
--------------------------------------------------------------------------------
Item = class(Entity)
M.Item = Item

function Item:init()
    self.id = 0
    self.name = nil
    self.type = nil
    self.description = nil
    self.equipType = 0
    self.atk = 0
    self.def = 0
end

--------------------------------------------------------------------------------
-- @type Skill
-- スキルを定義するエンティティです.
--------------------------------------------------------------------------------
Skill = class(Entity)
M.Skill = Skill

function Skill:init()
    self.id = 0
    self.name = nil
    self.descripsion = nil
    self.effectId = 0
    self.useMp = 0
    self.atkPoint = 0
end

--------------------------------------------------------------------------------
-- @type Menu
-- メインメニューから起動するメニューを表すエンティティクラスです.
--------------------------------------------------------------------------------
Menu = class(Entity)
M.Menu = Menu

function Menu:init()
    self.id = 0
    self.title = nil
    self.description = nil
    self.sceneName = nil
    self.sceneAnimation = "change"
end

--------------------------------------------------------------------------------
-- @type Bag
--------------------------------------------------------------------------------
Bag = class(Entity)
M.Bag = Bag

function Bag:init()
    self.bagItems = {}
end

--------------------------------------------------------------------------------
-- @type BagItem
-- バッグの中にあるアイテムを表現するエンティティです.
--------------------------------------------------------------------------------
BagItem = class(Entity)
M.BagItem = BagItem

---
-- コンストラクタ
function BagItem:init()
    self.item = nil
    self.itemName = nil
    self.itemCount = nil
    self.itemEquipCount = 0
end

---
-- データを読み込みます.
function BagItem:loadData(data)
    self.item = assert(entityRepositry:getItemById(data.itemId), "Not found item!")
    self.itemName = self.item.name
    self.itemCount = data.itemCount
    self.itemEquipCount = data.itemEquipCount
end

--------------------------------------------------------------------------------
-- @type Team
-- プレイヤーやエネミーの集合体を表すチームエンティティです.
--------------------------------------------------------------------------------
Team = class(Entity)
M.Team = Team

function Team:init()

end

--------------------------------------------------------------------------------
-- @type Actor
-- 
--------------------------------------------------------------------------------
Actor = class(Entity)
M.Actor = Actor

---
-- コンストラクタ
function Actor:init()
    Actor.__super.init(self)
    self.id = 0
    self.level = 0
    self.exp = 0
    self.name = nil
    self.hp = 0
    self.mhp = 0
    self.mp = 0
    self.mmp = 0
    self.str = 0
    self.vit = 0
    self.int = 0
    self.men = 0
    self.spd = 0
    self.equipItems = {}
    self.equipSkills = {}
    self.statusStates = {}
end

---
-- データを読み込みます.
function Actor:loadData(data)
    self.id = data.id
    self.level = data.level
    self.exp = data.exp
    self.name = data.name
    self.hp = data.hp
    self.mhp = data.mhp
    self.mp = data.mp
    self.mmp = data.mmp
    self.str = data.str
    self.vit = data.vit
    self.int = data.int
    self.men = data.men
    self.spd = data.spd
    
    for i, itemId in ipairs(data.equipItems) do
        local item = assert(entityRepositry:getItemById(itemId), "Not Found Item!", itemId)
        self.equipItems[i] = item
    end
    for i, skillId in ipairs(data.equipSkills) do
        local skill = assert(entityRepositry:getSkillById(skillId), "Not Found Skill", skillId)
        self.equipSkills[i] = skill
    end
end

---
-- 武器を装備します.
function Actor:equipWeaponItem(item)
    self.equipItems[1] = item
end

---
-- 防具を装備します.
function Actor:equipArmorItem(item)
    self.equipItems[2] = item
end

---
-- 装備しているスキルリストを返します.
function Actor:getSkills()
    return self.equipSkills
end

---
-- スキルを追加します.
function Actor:addSkill(skill)
    table.insertElement(self.equipSkills, skill) 
end

---
-- スキルを削除します.
function Actor:removeSkill(skill)
    table.removeElement(self.equipSkills, skill) 
end

---
-- 攻撃力を返します.
-- @return 攻撃力
function Actor:getAtkPoint()
    local total = self.str
    for i, item in ipairs(self.equipItems) do
        total = total + item.atk
    end
    return total
end

---
-- 防御力を返します.
-- @return 防御力
function Actor:getDefPoint()
    local total = self.vit
    for i, item in ipairs(self.equipItems) do
        total = total + item.def
    end
    return total
end

--------------------------------------------------------------------------------
-- @type Player
-- ユーザが操作するプレイヤーを表すエンティティです.
-- アクターを継承します.
--------------------------------------------------------------------------------
Player = class(Actor)
M.Player = Player

function Player:init()
    Player.__super.init(self)
end

--------------------------------------------------------------------------------
-- @type Enemy
-- マップ上に配置するエネミーを表すエンティティです.
-- アクターを継承します.
--------------------------------------------------------------------------------
Enemy = class(Actor)
M.Enemy = Enemy

---
-- コンストラクタです.
function Enemy:init()
    Enemy.__super.init(self)
end

---
-- オブジェクトをコピーします.
-- @return Enemyオブジェクト
function Enemy:clone()
    local enemy = self.__class()
    table.copy(self, enemy)
    return enemy
end


M.initialize()

return M
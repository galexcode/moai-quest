----------------------------------------------------------------------------------------------------
-- RPGのワールドマップを表示するクラスです.
--
----------------------------------------------------------------------------------------------------

-- module
local M = {}

-- import
local flower = require "flower"
local tiled = require "tiled"
local entities = require "libs/entities"
local effects = require "libs/effects"
local repositry = entities.repositry
local class = flower.class
local ClassFactory = flower.ClassFactory
local Event = flower.Event
local Layer = flower.Layer
local Camera = flower.Camera
local Runtime = flower.Runtime
local TileMap = tiled.TileMap
local TileObject = tiled.TileObject

-- classes
local MapEvent
local RPGMap
local RPGObject
local MapSystem
local MovementSystem
local CameraSystem
local TurnSystem
local BattleSystem

--------------------------------------------------------------------------------
-- @type MapEvent
-- マップで発生するイベントを定義するクラスです.
--------------------------------------------------------------------------------
MapEvent = class(Event)
M.MapEvent = MapEvent

--- オブジェクトをタッチしてフォーカスがあたった時のイベント
MapEvent.FOCUS_IN_OBJECT = "focusInObject"

--- オブジェクトからフォーカスが外れた時のイベント
MapEvent.FOCUS_OUT_OBJECT = "focusOutObject"

--------------------------------------------------------------------------------
-- @type RPGMap
-- ゲームの為のタイルマップクラスです.
--------------------------------------------------------------------------------
RPGMap = class(TileMap)
M.RPGMap = RPGMap

---
-- コンストラクタ
function RPGMap:init()
    TileMap.init(self)
    self.objectFactory = ClassFactory(RPGObject)

    self:initLayer()
    self:initSystems()
    self:initEventListeners()
end

---
-- 描画レイヤーを初期化します.
function RPGMap:initLayer()
    self.camera = Camera()

    local layer = Layer()
    layer:setCamera(self.camera)
    layer:setTouchEnabled(true)
    self:setLayer(layer)
end

---
-- マップシステムを初期化します.
function RPGMap:initSystems()
    self.systems = {
        MovementSystem(self),
        CameraSystem(self),
    }
end

---
-- イベントリスナーを初期化します.
function RPGMap:initEventListeners()
    self:addEventListener("touchDown", self.onTouchDown, self)
    self:addEventListener("loadedData", self.onLoadedData, self)
    self:addEventListener("savedData", self.onSavedData, self)
end

---
-- シーンを設定します.
-- @param scene シーン
function RPGMap:setScene(scene)
    self.scene = scene
    self.layer:setScene(scene)
end

---
-- 指定されたマップ座標が衝突するか判定します.
-- @param mapX マップX座標
-- @param mapY マップY座標
-- @return 衝突する場合はtrue
function RPGMap:isCollisionForMap(mapX, mapY)
    if mapX < 0 or self.mapWidth <= mapX then
        return true
    end
    if mapY < 0 or self.mapHeight <= mapY then
        return true
    end

    local gid = self.collisionLayer:getGid(mapX, mapY)
    return gid > 0
end

---
-- 指定されたマップ座標に存在するオブジェクトが衝突するか判定します.
-- @param target 衝突元オブジェクト
-- @param mapX マップX座標
-- @param mapY マップY座標
-- @return 衝突する場合はtrue
function RPGMap:isCollisionForObjects(target, mapX, mapY)
    for i, object in ipairs(self.objectLayer:getObjects()) do
        if object ~= target then
            local objX, objY = object:getMapPos()
            if objX == mapX and objY == mapY then
                return true
            end
        end
    end
end

---
-- 指定したマップ座標に存在するオブジェクトを返します.
-- @param mapX マップX座標
-- @param mapY マップY座標
-- @return オブジェクト
function RPGMap:getObjectByMapPos(mapX, mapY)
    for i, object in ipairs(self.objectLayer:getObjects()) do
        local objX, objY = object:getMapPos()
        if objX == mapX and objY == mapY then
            return object
        end
    end
end

---
-- ビューポート内のサイズを返します.
-- @return viewWidth
-- @return viewHeight
function RPGMap:getViewSize()
    return flower.viewWidth, flower.viewHeight
end

---
-- データをロード後、ゲームに必要な情報を抽出します.
-- @param e イベント
function RPGMap:onLoadedData(e)
    self.objectLayer = assert(self:findMapLayerByName("Object"))
    self.playerObject = assert(self.objectLayer:findObjectByName("Player"))
    self.collisionLayer = assert(self:findMapLayerByName("Collision"))
    self.eventLayer = assert(self:findMapLayerByName("Event"))

    if self.collisionLayer then
        self.collisionLayer:setVisible(false)
    end
    if self.eventLayer then
        self.eventLayer:setVisible(false)
    end
    
    for i, system in ipairs(self.systems) do
        system:onLoadedData(e)
    end
end

---
-- データを保存後、ゲームに必要な情報をデータに設定します.
-- @param e イベント
function RPGMap:onSavedData(e)

end

---
-- ステップ毎の更新時に呼ばれるイベントハンドラです.
-- @param e イベント
function RPGMap:onUpdate(e)
    for i, system in ipairs(self.systems) do
        system:onUpdate()
    end
end

---
-- マップをタッチした時のイベントハンドラです.
function RPGMap:onTouchDown(e)
    self:dispatchEvent(MapEvent.FOCUS_OUT_OBJECT)
end

----------------------------------------------------------------------------------------------------
-- @type RPGObject
-- マップの配置するオブジェクトクラスです.
-- プレイヤー、エネミー、アクターの場合、特別な初期化処理を行います.
----------------------------------------------------------------------------------------------------
RPGObject = class(TileObject)
M.RPGObject = RPGObject

-- Constranits
RPGObject.ACTOR_ANIM_DATAS = {
    {name = "walkDown", frames = {2, 1, 2, 3, 2}, sec = 0.25},
    {name = "walkLeft", frames = {5, 4, 5, 6, 5}, sec = 0.25},
    {name = "walkRight", frames = {8, 7, 8, 9, 8}, sec = 0.25},
    {name = "walkUp", frames = {11, 10, 11, 12, 11}, sec = 0.25},
}

-- Events
RPGObject.EVENT_MOVE_START = "moveStart"
RPGObject.EVENT_MOVE_END = "moveEnd"

-- Direction
RPGObject.DIR_UP = "up"
RPGObject.DIR_LEFT = "left"
RPGObject.DIR_RIGHT = "right"
RPGObject.DIR_DOWN = "down"

-- Move speed
RPGObject.MOVE_SPEED = 4

-- 方向に対するアニメーションを定義するテーブル定数
RPGObject.DIR_TO_ANIM = {
    up = "walkUp",
    left = "walkLeft",
    right = "walkRight",
    down = "walkDown",
}

-- 方向に対する移動速度を定義するテーブル定数
RPGObject.DIR_TO_VELOCITY = {
    up = {x = 0, y = -1},
    left = {x = -1, y = 0},
    right = {x = 1, y = 0},
    down = {x = 0, y = 1},
}

---
-- コンストラクタ
function RPGObject:init(tileMap)
    TileObject.init(self, tileMap)
    self.isRPGObject = true
    self.mapX = 0
    self.mapY = 0
    self.linerVelocity = {}
    self.linerVelocity.stepX = 0
    self.linerVelocity.stepX = 0
    self.linerVelocity.stepCount = 0

    self:addEventListener("touchDown", self.onTouchDown, self)
end

---
-- オブジェクトデータを読み込みます.
-- @param data オブジェクトデータ
function RPGObject:loadData(data)
    TileObject.loadData(self, data)

    self.mapX = math.floor(data.x / self.tileMap.tileWidth)
    self.mapY = math.floor(data.y / self.tileMap.tileHeight) - 1

    if self.type == "Actor" then
        self:initActor(data)
    end
    if self.type == "Player" then
        self:initActor(data)
        self:initPlayer(data)
    end
    if self.type == "Enemy" then
        self:initActor(data)
        self:initEnemy(data)
    end
end

---
-- アクター共通の初期化処理です.
-- @param data オブジェクトデータ
function RPGObject:initActor(data)
    if self.renderer then
        self.renderer:setAnimDatas(RPGObject.ACTOR_ANIM_DATAS)
        self:setDirection(self:getDirectionByIndex())
    end
end

---
-- プレイヤーの初期化処理です.
-- @param data オブジェクトデータ
function RPGObject:initPlayer(data)
    self.entity = repositry:getActorById(1)
    self:initEntityListener()
end

---
-- エネミーの初期化処理です.
-- @param data オブジェクトデータ
function RPGObject:initEnemy(data)
    local enemyId = self:getProperty("enemy_id")
    if enemyId then
        self.entity = repositry:createEnemy(tonumber(enemyId))
        self:initEntityListener()
    end
end

---
-- エンティティに関するイベントリスナーを初期化します.
function RPGObject:initEntityListener()
    self.entity:addEventListener("damege", self.onDamegeEntity, self)
    self.entity:addEventListener("dead", self.onDeadEntity, self)
    self.entity:addEventListener("recovery", self.onRecoveryEntity, self)
    self.entity:addEventListener("update", self.onUpdateEntity, self)
end

---
-- マップ座標を返します.
-- @return マップX座標
-- @return マップY座標
function RPGObject:getMapPos()
    return self.mapX, self.mapY
end

---
-- 次に移動するマップ座標を返します.
-- @return マップX座標
-- @return マップY座標
function RPGObject:getNextMapPos()
    local mapX, mapY = self:getMapPos()
    local velocity = RPGObject.DIR_TO_VELOCITY[self.direction] or {x = 0, y = 0}
    return mapX + velocity.x, mapY + velocity.y
end

---
-- 移動中かどうか返します.
-- @return 移動中の場合はtrue
function RPGObject:isMoving()
    return self.linerVelocity.stepCount > 0
end

---
-- 現在の方向に対するアニメーション名を返します.
-- @return アニメーション名
function RPGObject:getDirectionByIndex()
    if not self.renderer then
        return
    end

    local index = self.renderer:getIndex()
    if 1 <= index and index <= 3 then
        return RPGObject.DIR_DOWN
    end
    if 4 <= index and index <= 6 then
        return RPGObject.DIR_LEFT
    end
    if 7 <= index and index <= 9 then
        return RPGObject.DIR_RIGHT
    end
    if 10 <= index and index <= 12 then
        return RPGObject.DIR_UP
    end
    return RPGObject.DIR_DOWN
end

---
-- アニメーションを開始します.
-- @param アニメーション名
function RPGObject:playAnim(animName)
    if self.renderer and not self.renderer:isCurrentAnim(animName) then
        self.renderer:playAnim(animName)
    end
end

---
-- マップの移動を開始します.
-- 移動中の場合は無視されます.
-- @param dir 方向
function RPGObject:walkMap(dir)
    if self:isMoving() then
        return
    end
    if not RPGObject.DIR_TO_ANIM[dir] then
        return
    end
    
    self:setDirection(dir)
    
    if self:hitTestFromMap() then
        return
    end
    
    local velocity = RPGObject.DIR_TO_VELOCITY[dir]
    local tileWidth = self.tileMap.tileWidth
    local tileHeight = self.tileMap.tileHeight
    local moveSpeed = RPGObject.MOVE_SPEED
    
    self.mapX = self.mapX + velocity.x
    self.mapY = self.mapY + velocity.y
    self.linerVelocity.stepX = moveSpeed * velocity.x
    self.linerVelocity.stepY = moveSpeed * velocity.y
    self.linerVelocity.stepCount = tileWidth / moveSpeed  -- TODO:TileWidthしか使用していない
    return true
end

---
-- 方向を設定します.
-- @param 方向
function RPGObject:setDirection(dir)
    if not RPGObject.DIR_TO_ANIM[dir] then
        return
    end
    
    local animName = RPGObject.DIR_TO_ANIM[dir]
    self:playAnim(animName)
    self.direction = dir
end

---
-- 次の座標がマップ、他オブジェクトと衝突するか判定します.
-- @return 衝突する場合はtrue
function RPGObject:hitTestFromMap()
    if self.tileMap:isCollisionForMap(self:getNextMapPos()) then
        return true
    end
    if self.tileMap:isCollisionForObjects(self, self:getNextMapPos()) then
        return true
    end
end

---
-- 指定されたマップ座標が、このオブジェクトと衝突するか判定します.
-- @return 衝突する場合はtrue
function RPGObject:isCollision(mapX, mapY)
    local nowMapX, nowMapY = self:getMapPos()
    return nowMapX == mapX and nowMapY == mapY
end

---
-- ターゲットを攻撃します.
function RPGObject:doAttack(target)
    if not target or not target.entity then
        return
    end
    local entity = repositry:getEffectById(1)
    local skillEffect = effects.SkillEffect(entity)
    skillEffect:play(target.renderer)
    
    self.entity:doAttack(target.entity)
end

---
-- オブジェクトがタッチされた場合は呼ばれるイベントハンドラです.
-- @param e タッチイベント
function RPGObject:onTouchDown(e)
    self.tileMap:dispatchEvent(MapEvent.FOCUS_IN_OBJECT, self)
    e:stop()
end

---
-- エンティティがダメージを受けた時のイベントハンドラです.
-- @param e イベント
function RPGObject:onDamegeEntity(e)
    local damegeEffect = effects.DamegeEffect(e.data.damegeHP)
    damegeEffect:play(self.renderer)
end

---
-- エンティティが死亡した時のイベントハンドラです.
-- @param e イベント
function RPGObject:onDeadEntity(e)
    self.parent:removeObject(self)
end

---
-- エンティティが回復した時のイベントハンドラです.
-- @param e イベント
function RPGObject:onRecoveryEntity(e)
    
end

---
-- エンティティが更新された時のイベントハンドラです.
-- @param e イベント
function RPGObject:onUpdateEntity(e)
    
end

----------------------------------------------------------------------------------------------------
-- @type CameraSystem
-- プレイヤーの位置に応じたカメラの移動を行うシステムです.
----------------------------------------------------------------------------------------------------
CameraSystem = class()
CameraSystem.MARGIN_HEIGHT = 140

function CameraSystem:init(tileMap)
    self.tileMap = tileMap
end

function CameraSystem:onLoadedData(e)
    self:onUpdate()
end

function CameraSystem:onUpdate()
    local player = self.tileMap.playerObject
    
    local vw, vh = self.tileMap:getViewSize()
    local mw, mh = self.tileMap:getSize()
    local x, y = player:getPos()

    x, y = x - vw / 2, y - vh / 2
    x, y = self:getAdjustCameraLoc(x, y)

    self.tileMap.camera:setLoc(x, y, 0)
end

function CameraSystem:getAdjustCameraLoc(x, y)
    local vw, vh = self.tileMap:getViewSize()
    local mw, mh = self.tileMap:getSize()    

    mh = mh + CameraSystem.MARGIN_HEIGHT
    
    x = math.min(x, mw - vw)
    x = math.max(x, 0)
    x = math.floor(x)
    y = math.min(y, mh - vh)
    y = math.max(y, 0)
    y = math.floor(y)
    
    return x, y
end

----------------------------------------------------------------------------------------------------
-- @type MovementSystem
-- オブジェクトを移動させるためのシステムです.
----------------------------------------------------------------------------------------------------
MovementSystem = class()

function MovementSystem:init(tileMap)
    self.tileMap = tileMap
end

function MovementSystem:onLoadedData(e)

end

function MovementSystem:onUpdate()
    for i, object in ipairs(self.tileMap.objectLayer:getObjects()) do
        self:moveObject(object)
    end
end

function MovementSystem:moveObject(object)
    if not object.linerVelocity
    or not object.linerVelocity.stepCount
    or object.linerVelocity.stepCount == 0 then
        return
    end

    local velocity = object.linerVelocity
    object:addLoc(velocity.stepX, velocity.stepY)
    velocity.stepCount = velocity.stepCount - 1

    if velocity.stepCount <= 0 then
        velocity.stepX = 0
        velocity.stepY = 0
        velocity.stepCount = 0
        
        object:dispatchEvent(RPGObject.EVENT_MOVE_END)
    end
end

----------------------------------------------------------------------------------------------------
-- @type TurnSystem
----------------------------------------------------------------------------------------------------
TurnSystem = class()

function TurnSystem:init(tileMap)
    self.tileMap = tileMap
end

function TurnSystem:onLoadedData(e)

end

function TurnSystem:onUpdate()
end

return M
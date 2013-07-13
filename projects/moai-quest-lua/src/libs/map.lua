----------------------------------------------------------------------------------------------------
-- ワールドマップを表示するクラスです.
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
local WorldMap
local MapObject
local ActorController
local PlayerController
local EnemyController
local ScriptSystem
local MovementSystem
local CameraSystem
local BattleSystem

--------------------------------------------------------------------------------
-- @type MapEvent
-- マップで発生するイベントを定義するクラスです.
--------------------------------------------------------------------------------
MapEvent = class(Event)
M.MapEvent = MapEvent

--- オブジェクトがマップと衝突したときのイベントです.
MapEvent.COLLISION_MAP = "collisionMap"

--- オブジェクトがマップと衝突したときのイベントです.
MapEvent.COLLISION_OBJECT = "collisionObject"

--- バトル開始のイベントです.
MapEvent.BATTLE = "battle"

--------------------------------------------------------------------------------
-- @type WorldMap
-- ワールドマップを表示するタイルマップクラスです.
--------------------------------------------------------------------------------
WorldMap = class(TileMap)
M.WorldMap = WorldMap

---
-- コンストラクタ
function WorldMap:init()
    TileMap.init(self)
    self.objectFactory = ClassFactory(MapObject)

    self:initLayer()
    self:initSystems()
    self:initEventListeners()
end

---
-- 描画レイヤーを初期化します.
function WorldMap:initLayer()
    self.camera = Camera()

    local layer = Layer()
    layer:setSortMode(MOAILayer.SORT_PRIORITY_ASCENDING)
    layer:setCamera(self.camera)
    layer:setTouchEnabled(true)
    self:setLayer(layer)
end

---
-- マップシステムを初期化します.
function WorldMap:initSystems()
    self.systems = {
        ScriptSystem(self),
        MovementSystem(self),
        CameraSystem(self),
        --ActionSystem(self),
        BattleSystem(self),
    }
end

---
-- イベントリスナーを初期化します.
function WorldMap:initEventListeners()
    self:addEventListener("touchDown", self.onTouchDown, self)
    self:addEventListener("loadedData", self.onLoadedData, self)
    self:addEventListener("savedData", self.onSavedData, self)
end

---
-- シーンを設定します.
-- @param scene シーン
function WorldMap:setScene(scene)
    self.scene = scene
    self.layer:setScene(scene)
end

---
-- 指定されたオブジェクトがマップと衝突するか判定します.
-- @param target
-- @return 衝突する場合は衝突先GID
-- @return 衝突する場合は衝突先X座標
-- @return 衝突する場合は衝突先Y座標
function WorldMap:hitTestForMap(target)
    local xMin, yMin, xMax, yMax = target:getCollisionMapRect()
    if not xMin then
        return
    end

    for y = yMin, yMax do
        for x = xMin, xMax do
            local gid = self.collisionLayer:getGid(x, y)
            if gid and gid > 0 then
                return gid, x, y
            end
        end
    end
end

---
-- 指定されたオブジェクトが他のオブジェクトと衝突するか判定します.
-- @param target 衝突元オブジェクト
-- @return 衝突する場合は衝突先オブジェクト
function WorldMap:hitTestForObjects(target)
    for i, object in ipairs(self.objectLayer:getObjects()) do
        if object ~= target then
            if object:isCollision(target) then
                return object
            end
        end
    end
end

---
-- ビューポート内のサイズを返します.
-- @return viewWidth
-- @return viewHeight
function WorldMap:getViewSize()
    return flower.viewWidth, flower.viewHeight
end

---
-- データをロード後、ゲームに必要な情報を抽出します.
-- @param e イベント
function WorldMap:onLoadedData(e)
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
function WorldMap:onSavedData(e)

end

---
-- ステップ毎の更新時に呼ばれるイベントハンドラです.
-- @param e イベント
function WorldMap:onUpdate(e)
    for i, system in ipairs(self.systems) do
        system:onUpdate()
    end
end

---
-- マップをタッチした時のイベントハンドラです.
function WorldMap:onTouchDown(e)
    
end

----------------------------------------------------------------------------------------------------
-- @type MapObject
-- マップの配置するオブジェクトクラスです.
-- オブジェクトの操作は、コントローラが行います.
----------------------------------------------------------------------------------------------------
MapObject = class(TileObject)
M.MapObject = MapObject

--- 移動開始時のイベント
MapObject.EVENT_WALK_START = "walkStart"

--- 移動終了時のイベント
MapObject.EVENT_WALK_STOP = "walkStop"

--- 移動方向:下
MapObject.DIR_DOWN = "down"

--- 移動方向:左
MapObject.DIR_LEFT = "left"

--- 移動方向:右
MapObject.DIR_RIGHT = "right"

--- 移動方向:上
MapObject.DIR_UP = "up"

--- デフォルトの移動スピード
MapObject.WALK_SPEED = 4

--- 移動方向に対応するインデックス
MapObject.DIR_TO_INDEX = {
    down = 2,
    left = 5,
    right = 8,
    up = 11,
}

---
-- コンストラクタ
function MapObject:init(tileMap)
    TileObject.init(self, tileMap)
    self.direction = MapObject.DIR_DOWN
    self.speed = 0
    self.battleWaitCount = 0
    self.walking = false
    self.controller = nil
end

---
-- オブジェクトデータを読み込みます.
-- @param data オブジェクトデータ
function MapObject:loadData(data)
    TileObject.loadData(self, data)

    if self.type == "Actor" then
        self.controller = ActorController(self)
    end
    if self.type == "Player" then
        self.controller = PlayerController(self)
    end
    if self.type == "Enemy" then
        self.controller = EnemyController(self)
    end
end

---
-- 衝突する場合、衝突範囲を返します.
-- 衝突しない場合、nilを返します。
-- @return xMin
-- @return yMin
-- @return xMax
-- @return yMax
function MapObject:getCollisionRect()
    if not self.renderer then
        return
    end
    local padding = 8
    local width, height = self.renderer:getSize()
    local xMin, yMin = self:getLeft() + padding, self:getTop() - height + padding
    local xMax, yMax = xMin + width - padding,  yMin + height - padding
    
    return xMin, yMin, xMax, yMax
end

---
-- 衝突する場合、マップ座標系の衝突範囲を返します.
-- 衝突しない場合、nilを返します。
-- @return xMin
-- @return yMin
-- @return xMax
-- @return yMax
function MapObject:getCollisionMapRect()
    if not self.renderer then
        return
    end
    local tileWidth, tileHeight = self.tileMap.tileWidth, self.tileMap.tileHeight
    local xMin, yMin, xMax, yMax = self:getCollisionRect()
    xMin = math.floor(xMin / tileWidth)
    yMin = math.floor(yMin / tileHeight)
    xMax = math.floor(xMax / tileWidth)
    yMax = math.floor(yMax / tileHeight)
    return xMin, yMin, xMax, yMax
end

---
-- 移動中かどうか返します.
-- @return 移動中の場合はtrue
function MapObject:isWalking()
    return self.walking
end

---
-- 現在のインデックスに対する移動方向を返します.
-- @return 移動方向
function MapObject:getDirectionByIndex()
    if not self.renderer then
        return
    end

    local index = self.renderer:getIndex()

    if 1 <= index and index <= 3 then
        return MapObject.DIR_DOWN
    end
    if 4 <= index and index <= 6 then
        return MapObject.DIR_LEFT
    end
    if 7 <= index and index <= 9 then
        return MapObject.DIR_RIGHT
    end
    if 10 <= index and index <= 12 then
        return MapObject.DIR_UP
    end
    return MapObject.DIR_DOWN
end

---
-- 移動アニメーションを開始します.
-- @param animName アニメーション名
function MapObject:startWalkAnim(direction)
    direction = direction or self.direction
    if self.renderer then
        if not self.renderer:isBusy() or not self.renderer:isCurrentAnim(direction) then
            self.renderer:playAnim(direction)
        end
    end
end

---
-- 移動アニメーションを停止します.
function MapObject:stopWalkAnim()
    if self.renderer and self.renderer:isBusy() then
        self.renderer:stopAnim()
        self.renderer:setIndex(MapObject.DIR_TO_INDEX[self.direction])
    end
end

---
-- 移動を開始します.
-- 実際に移動するタイミングは、MovementSystemによって制御されます.
-- @param direction 移動方向
-- @param speed (Option)移動スピード
-- @param count (Option)移動回数.未指定の場合は無限
function MapObject:startWalk(direction, speed, count)
    self:setDirection(direction)
    self:setSpeed(speed or MapObject.WALK_SPEED)
    self:startWalkAnim()
    self.walkingCount = count
    if not self.walking then
        self.walking = true
        self:dispatchEvent(MapObject.EVENT_WALK_START)
    end
end

---
-- 移動を停止します.
function MapObject:stopWalk()
    self:setSpeed(0)
    self:stopWalkAnim()
    self.walkingCount = nil
    if self.walking then
        self.walking = false
        self:dispatchEvent(MapObject.EVENT_WALK_STOP)
    end
end

---
-- 移動方向を設定します.
-- @param dir 方向
function MapObject:setDirection(dir)
    self.direction = dir
end

---
-- 移動スピードを設定します.
-- @param speed 移動スピード
function MapObject:setSpeed(speed)
    self.speedX = 0
    self.speedX = self.direction == "left" and -speed or self.speedX
    self.speedX = self.direction == "right" and speed or self.speedX

    self.speedY = 0
    self.speedY = self.direction == "up" and -speed or self.speedY
    self.speedY = self.direction == "down" and speed or self.speedY
end

---
-- 移動回数を設定します.
-- @param stepCount 移動回数
function MapObject:setStepCount(stepCount)
    self.stepCount = stepCount
end

---
-- 指定された対象オブジェクトが、このオブジェクトと衝突するか判定します.
-- @return 衝突する場合はtrue
function MapObject:isCollision(target)
    if target == self then
        return
    end
    local xMin, yMin, xMax, yMax = target:getCollisionRect()
    
    return self:isCollisionByPosition(xMin, yMin)
        or self:isCollisionByPosition(xMin, yMax)
        or self:isCollisionByPosition(xMax, yMin)
        or self:isCollisionByPosition(xMax, yMax)
end

---
-- 指定された座標が、このオブジェクトと衝突するか判定します.
-- @return 衝突する場合はtrue
function MapObject:isCollisionByPosition(x, y)
    local xMin, yMin, xMax, yMax = self:getCollisionRect()
    return xMin <= x and x <= xMax and yMin <= y and y <= yMax
end

----------------------------------------------------------------------------------------------------
-- @type ActorController
-- アクターオブジェクトを操作するコントローラクラスです.
----------------------------------------------------------------------------------------------------
ActorController = class()

--- アクターのアニメーションを定義します.
ActorController.ANIM_DATA_LIST = {
    {name = "down", frames = {1, 2, 3, 2, 1}, sec = 0.1},
    {name = "left", frames = {4, 5, 6, 5, 4}, sec = 0.1},
    {name = "right", frames = {7, 8, 9, 8, 7}, sec = 0.1},
    {name = "up", frames = {10, 11, 12, 11, 10}, sec = 0.1},
}

---
-- コンストラクタ
function ActorController:init(mapObject)
    self.mapObject = mapObject
    self:initController()
    self:initEventListeners()
end

---
-- コントローラの初期処理を行います.
function ActorController:initController()
    local object = self.mapObject
    if object.renderer then
        object.renderer:setAnimDatas(ActorController.ANIM_DATA_LIST)
        object:setDirection(object:getDirectionByIndex())
    end
end

---
-- イベントリスナーを初期化します.
function ActorController:initEventListeners()
    local obj = self.mapObject
end

---
-- 更新時に呼ばれるイベントハンドラです.
function ActorController:onUpdate()
end

----------------------------------------------------------------------------------------------------
-- @type PlayerController
-- プレイヤーオブジェクトを操作するコントローラクラスです.
----------------------------------------------------------------------------------------------------
PlayerController = class(ActorController)

---
-- MapObjectに対する初期か処理を行います.
function PlayerController:initController()
    PlayerController.__super.initController(self)
    self.entity = repositry:getPlayer()
end

---
-- 更新時に呼ばれるイベントハンドラです.
function PlayerController:onUpdate()
    
end

----------------------------------------------------------------------------------------------------
-- @type EnemyController
-- エネミーオブジェクトを操作するコントローラクラスです.
----------------------------------------------------------------------------------------------------
EnemyController = class(ActorController)

---
-- MapObjectに対する初期か処理を行います.
function EnemyController:initController()
    EnemyController.__super.initController(self)
    
    local enemyId = tonumber(self.mapObject:getProperty("enemy_id"))
    self.enemyId = enemyId
end

---
-- 更新時に呼ばれるイベントハンドラです.
function EnemyController:onUpdate()
    
end

----------------------------------------------------------------------------------------------------
-- @type ScriptSystem
-- プレイヤーの位置に応じたカメラの移動を行うシステムです.
----------------------------------------------------------------------------------------------------
ScriptSystem = class()

---
-- コンストラクタ
-- @param tileMap タイルマップ
function ScriptSystem:init(tileMap)
    self.tileMap = tileMap
end

---
-- データをロードした時のイベントハンドラです.
-- @param e イベント
function ScriptSystem:onLoadedData(e)
    local objectLayer = self.tileMap.objectLayer
end

---
-- 更新イベントハンドラです.
function ScriptSystem:onUpdate()
    for i, object in ipairs(self.tileMap.objectLayer:getObjects()) do
        if object.controller then
            object.controller:onUpdate()
        end
    end
end

----------------------------------------------------------------------------------------------------
-- @type CameraSystem
-- プレイヤーの位置に応じたカメラの移動を行うシステムです.
----------------------------------------------------------------------------------------------------
CameraSystem = class()
CameraSystem.MARGIN_HEIGHT = 140

---
-- コンストラクタ
-- @param tileMap タイルマップ
function CameraSystem:init(tileMap)
    self.tileMap = tileMap
end

---
-- データをロードした時のイベントハンドラです.
-- @param e イベント
function CameraSystem:onLoadedData(e)
    self:onUpdate()
end

---
-- 更新イベントハンドラです.
function CameraSystem:onUpdate()
    local player = self.tileMap.playerObject

    local vw, vh = self.tileMap:getViewSize()
    local mw, mh = self.tileMap:getSize()
    local x, y = player:getPos()

    x, y = x - vw / 2, y - vh / 2
    x, y = self:getAdjustCameraLoc(x, y)

    self.tileMap.camera:setLoc(x, y, 0)
end

---
-- カメラが範囲外の場合は、範囲内となるように調整した座標を返します.
-- @param x X座標
-- @param y Y座標
-- @return 調整後のX座標
-- @return 調整後のY座標
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
-- オブジェクトの移動と衝突反映を行うためのシステムです.
----------------------------------------------------------------------------------------------------
MovementSystem = class()

---
-- コンストラクタ
function MovementSystem:init(tileMap)
    self.tileMap = tileMap
end

---
-- データロード時のイベントハンドラです.
function MovementSystem:onLoadedData(e)

end

---
-- 更新時のイベントハンドラです.
function MovementSystem:onUpdate()
    for i, object in ipairs(self.tileMap.objectLayer:getObjects()) do
        self:moveObject(object)
    end
end

---
-- オブジェクトを移動します.
function MovementSystem:moveObject(object)
    if not object:isWalking() then
        return
    end
    
    object:addLoc(object.speedX, object.speedY)
    
    if object.walkingCount then
        object.walkingCount = object.walkingCount - 1
        if object.walkingCount <= 0 then
            object:stopWalk()
        end
    end
    
    -- hit test for map
    local gid, mapX, mapY = self.tileMap:hitTestForMap(object)
    if gid then
        self:collideForMap(object, gid, mapX, mapY)
        return
    end
    
    -- hit test for objects
    local collideObject = self.tileMap:hitTestForObjects(object)
    if collideObject then
        self:collideForObject(object, collideObject)
    end
end

---
-- オブジェクトがマップと衝突時の処理です.
function MovementSystem:collideForMap(object, gid, mapX, mapY)
    object:addLoc(-object.speedX, -object.speedY)
    
    local data = {object = object, gid = gid, mapX = mapX, mapY = mapY}
    object:dispatchEvent(MapEvent.COLLISION_MAP, data)
    self.tileMap:dispatchEvent(MapEvent.COLLISION_MAP, data)

    object:stopWalk()
end

---
-- オブジェクト同士が衝突した時の処理です.
function MovementSystem:collideForObject(objectA, objectB)
    objectA:addLoc(-objectA.speedX, -objectA.speedY)
    
    local data = {objectA = objectA, objectB = objectB}
    objectA:dispatchEvent(MapEvent.COLLISION_OBJECT, data)
    objectB:dispatchEvent(MapEvent.COLLISION_OBJECT, data)
    self.tileMap:dispatchEvent(MapEvent.COLLISION_OBJECT, data)

    objectA:stopWalk()
end


----------------------------------------------------------------------------------------------------
-- @type BattleSystem
-- プレイヤーのエネミーの戦闘を行うシステムです.
-- 戦闘シーンに遷移します.
----------------------------------------------------------------------------------------------------
BattleSystem = class()

---
-- コンストラクタ
-- @param tileMap タイルマップ
function BattleSystem:init(tileMap)
    self.tileMap = tileMap
    self.battleResults = {}
    
    self.tileMap:addEventListener(MapEvent.COLLISION_OBJECT, self.onCollisoinObject, self)
end

---
-- データをロードした時のイベントハンドラです.
-- @param e イベント
function BattleSystem:onLoadedData(e)
end

---
-- 更新イベントハンドラです.
-- 戦闘結果を反映します.
function BattleSystem:onUpdate()
end

---
-- オブジェクト同士が衝突した時のイベントハンドラです.
-- プレイヤーとエネミーが衝突した場合は戦闘処理を行います.
-- @param e イベント
function BattleSystem:onCollisoinObject(e)
    local objectA, objectB = e.data.objectA, e.data.objectB
    if objectA.type == "Player" and objectB.type == "Enemy" then
        self:doBattle(objectB)
   elseif objectA.type == "Enemy" and objectB.type == "Player" then
        self:doBattle(objectA)
    end
end

function BattleSystem:doBattle(object)
    self.tileMap:dispatchEvent(MapEvent.BATTLE, {enemyId = assert(object.controller.enemyId)})
end


return M
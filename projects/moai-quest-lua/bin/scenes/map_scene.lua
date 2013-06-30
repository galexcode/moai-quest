----------------------------------------------------------------------------------------------------
-- ワールドマップのシーンモジュールです.
--
----------------------------------------------------------------------------------------------------

module(..., package.seeall)

-- import
local Image = flower.Image
local Runtime = flower.Runtime
local UIView = widget.UIView
local Button = widget.Button
local InputMgr = flower.InputMgr
local RPGMap = map.RPGMap
local RPGObject = map.RPGObject
local MapControlView = widgets.MapControlView
local MapStatusView = widgets.MapStatusView

-- variables
local worldMap
local playerObject
local mapControlView
local mapStatusView

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

---
-- シーン生成時のイベントハンドラです.
-- @param e イベント
function onCreate(e)
    worldMap = RPGMap()
    worldMap:setScene(scene)
    loadMap("world_map.lue")

    mapControlView = MapControlView()
    mapControlView:setScene(scene)
    
    mapStatusView = MapStatusView()
    mapStatusView:setScene(scene)
    
    worldMap:addEventListener("focusInObject", onFocusInObject)
    worldMap:addEventListener("focusOutObject", onFocusOutObject)
    mapControlView:addEventListener("action", onAction)
    mapControlView:addEventListener("menu", onMenu)
end

---
-- シーン開始時のイベントハンドラです.
-- @param e イベント
function onStart(e)
    mapControlView:setVisible(true)
end

---
-- シーン停止時のイベントハンドラです.
-- @param e イベント
function onStop(e)
    mapControlView:setVisible(false)
end

---
-- シーン更新時のイベントハンドラです.
-- @param e イベント
function onUpdate(e)
    worldMap:onUpdate(e)

    local direction = mapControlView:getDirection()
    playerObject:walkMap(direction)
end

---
-- 行動ボタン押下時のイベントハンドラです.
-- @param e イベント
function onAction(e)
    if playerObject:isMoving() then
        return
    end
    local mapX, mapY = playerObject:getNextMapPos()
    local obj = worldMap:getObjectByMapPos(mapX, mapY)
    if obj and obj.entity then
        playerObject:doAttack(obj)
    end
end

---
-- メニューボタン選択時のイベントハンドラです.
-- @param e イベント
function onMenu(e)
    flower.openScene(scenes.MENU, {animation = "overlay"})
end

---
-- マップオブジェクトにフォーカスインした時のイベントハンドラです.
-- @param e イベント
function onFocusInObject(e)
    mapStatusView:setEnemy(e.data.entity)
end

---
-- マップオブジェクトにフォーカスアウトした時のイベントハンドラです.
-- @param e イベント
function onFocusOutObject(e)
    mapStatusView:setEnemy(nil)
end

--------------------------------------------------------------------------------
-- Functions
--------------------------------------------------------------------------------

---
-- マップを再読み込みします.
-- @param mapName マップ名
function loadMap(mapName)
    worldMap:loadLueFile(mapName)
    playerObject = worldMap.objectLayer:findObjectByName("Player")
end

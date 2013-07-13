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
local WorldMap = map.WorldMap
local MapObject = map.MapObject
local MapControlView = views.MapControlView
local MapStatusView = views.MapStatusView

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
    worldMap = WorldMap()
    worldMap:setScene(scene)
    worldMap:addEventListener("battle", onBattle)
    loadMap("world_map.lue")

    mapControlView = MapControlView()
    mapControlView:setScene(scene)
    mapControlView:addEventListener("menu", onMenu)
    
    mapStatusView = MapStatusView()
    mapStatusView:setScene(scene)
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
    if direction then
        playerObject:startWalk(direction)
    else
        playerObject:stopWalk()
    end
end

---
-- メニューボタン選択時のイベントハンドラです.
-- @param e イベント
function onMenu(e)
    flower.openScene(scenes.MENU, {animation = "overlay"})
end

---
-- バトル開始のイベントハンドラです.
-- @param e イベント
function onBattle(e)
    flower.openScene(scenes.BATTLE, {animation = "popIn", enemyId = e.data.enemyId})
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

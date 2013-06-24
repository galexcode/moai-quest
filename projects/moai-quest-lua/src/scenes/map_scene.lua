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
local rpgMap
local mapControlView
local mapStatusView

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    rpgMap = RPGMap()
    rpgMap:setScene(scene)
    loadRPGMap("world_map.lue")

    mapControlView = MapControlView()
    mapControlView:setScene(scene)
    
    mapStatusView = MapStatusView()
    mapStatusView:setScene(scene)
    
    mapControlView:addEventListener("enter", onEnter)
    mapControlView:addEventListener("menu", onMenu)
end

function onStart()
    mapControlView:setVisible(true)
end

function onStop()
    mapControlView:setVisible(false)
end

function onUpdate(e)
    updateMap()
    updatePlayer()
end

function onEnter(e)
    
end

function onMenu(e)
    flower.openScene(scenes.MENU, {animation = "overlay"})
end

function onTouchObject(e)

end

--------------------------------------------------------------------------------
-- Functions
--------------------------------------------------------------------------------


function loadRPGMap(mapName)
    rpgMap:loadLueFile(mapName)
    playerObject = rpgMap.objectLayer:findObjectByName("Player")
end


function updateMap()
    rpgMap:onUpdate(e)
end

function updatePlayer()
    local direction = mapControlView:getDirection()
    playerObject:walkMap(direction)
end

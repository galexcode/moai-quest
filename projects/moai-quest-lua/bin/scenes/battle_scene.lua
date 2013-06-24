module(..., package.seeall)

-- import
local repositry = require "libs/repositry"

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------
local BATTLER_OFFSET_Y = 120
local BATTLER_MARGIN = 50

--------------------------------------------------------------------------------
-- Variables
--------------------------------------------------------------------------------
local battlers = {}

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    gameLayer = flower.Layer()
    gameLayer:setTouchEnabled(true)
    gameLayer:setScene(scene)

    backgroundImage = flower.Image("battlebg001.png")
    backgroundImage:setLayer(gameLayer)
    
    createBattlers()
end

function onStart()
    for i, battler in ipairs(battlers) do
        battler:waitAnim()
    end
end

function onStop()
end

function onUpdate(e)
end

function onEnter(e)
    
end

--------------------------------------------------------------------------------
-- Functions
--------------------------------------------------------------------------------

function createBattlers()
    local actors = repositry.getMembers()
    for i, actor in ipairs(actors) do
        local battler = display.BattlerImage("battler" .. actor.id .. ".png")
        battler:setPos(math.floor(flower.viewWidth * 3 / 4), (i - 1) * BATTLER_MARGIN + BATTLER_OFFSET_Y)
        battler:setLayer(gameLayer)
        battler:addEventListener("touchDown", function(e)
            local target = e.target
            target:damegeAnim()
        end)
        battlers[i] = battler
    end
end

----------------------------------------------------------------------------------------------------
-- Config
----------------------------------------------------------------------------------------------------

-- module
local M = {}

-- import
local flower = require "flower"
local Resources = flower.Resources

-- Screen setting
flower.DEFAULT_SCREEN_WIDTH = MOAIEnvironment.horizontalResolution or 320
flower.DEFAULT_SCREEN_HEIGHT = MOAIEnvironment.verticalResolution or 480
flower.DEFAULT_VIEWPORT_SCALE = math.floor((MOAIEnvironment.screenDpi or 120) / 240) + 1

-- MOAISim setting
MOAISim.setStep ( 1 / 60 )
MOAISim.clearLoopFlags ()
MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_ALLOW_BOOST )
MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_LONG_DELAY )
MOAISim.setBoostThreshold ( 0 )

-- Resource setting
Resources.addResourceDirectory("actor")
Resources.addResourceDirectory("face")
Resources.addResourceDirectory("skins")
Resources.addResourceDirectory("monster")
Resources.addResourceDirectory("picture")
Resources.addResourceDirectory("tile")

----------------------------------------------------------------------------------------------------
-- Consts
----------------------------------------------------------------------------------------------------

-- game title name
M.TITLE_NAME = "MOAI Quest"

return M
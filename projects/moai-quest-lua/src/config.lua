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
flower.DEFAULT_VIEWPORT_SCALE = math.max(flower.DEFAULT_SCREEN_WIDTH, flower.DEFAULT_SCREEN_HEIGHT) > 960 and 2 or 1

-- MOAISim setting
MOAISim.setStep ( 1 / 60 )
MOAISim.clearLoopFlags ()
MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_ALLOW_BOOST )
MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_LONG_DELAY )
MOAISim.setBoostThreshold ( 0 )

-- Resource setting
Resources.resourceDirectories = {
    "actor",
    "background",
    "effect",
    "face",
    "fonts",
    "icons",
    "skins",
    "picture",
    "tile",
}

--flower.Font.DEFAULT_CHARCODES = [[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-ぁあぃいぅうぇえぉおかがきぎくぐけげこごさざしじすずせぜそぞただちぢっつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもゃやゅゆょよらりるれろゎわゐゑをんゔゕゖ゛゜ゝゞゟ゠ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロヮワヰヱヲンヴヵヶヷヸヹヺ・ーヽヾヿ使用確認終了入替]]

-- Debug
--[[
local timer = MOAITimer.new()
timer:setMode(MOAITimer.LOOP)
timer:setSpan(5)
timer:setListener(MOAITimer.EVENT_TIMER_LOOP,
    function()
        print("FPS:", MOAISim.getPerformance())
        print("Draw:", MOAIRenderMgr.getPerformanceDrawCount())
    end)
timer:start()
]]

----------------------------------------------------------------------------------------------------
-- Consts
----------------------------------------------------------------------------------------------------

-- game title name
M.TITLE_NAME = "MOAI Quest"

return M
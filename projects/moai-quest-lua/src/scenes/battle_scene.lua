----------------------------------------------------------------------------------------------------
-- タイトルを表示するシーンモジュールです.
--
----------------------------------------------------------------------------------------------------

module(..., package.seeall)

-- import
local entities = require "libs/entities"
local repositry = entities.repositry
local BattleMainView = views.BattleMainView
local BattleStatusView = views.BattleStatusView
local BattleMenuView = views.BattleMenuView

-- variables
local mainView
local statusView
local menuView

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    local data = e.data
    
    mainView = BattleMainView {
        scene = scene,
        enemy = repositry:createEnemy(data.enemyId),
    }
    
    statusView = BattleStatusView {
        scene = scene,
    }

end

function onUpdate(e)


end

--------------------------------------------------------------------------------
-- Function
--------------------------------------------------------------------------------


module(..., package.seeall)

--------------------------------------------------------------------------------
-- import
--------------------------------------------------------------------------------
local MenuControlView = widgets.MenuControlView
local MenuSkillView = widgets.MenuSkillView

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    menuSkillView = MenuSkillView {
        scene = scene,
    }
    
    menuControlView = MenuControlView {
        scene = scene,
    }
    
    -- event listeners
    menuControlView:addEventListener("back", menuControlView_OnBack)
end

function menuMainView_OnEnter(e)
    print("")
end

function menuControlView_OnBack(e)
    flower.closeScene()
end

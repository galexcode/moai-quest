module(..., package.seeall)

--------------------------------------------------------------------------------
-- import
--------------------------------------------------------------------------------
local MenuControlView = views.MenuControlView
local MenuStatusView = views.MenuStatusView

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    menuStatusView = MenuStatusView {
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

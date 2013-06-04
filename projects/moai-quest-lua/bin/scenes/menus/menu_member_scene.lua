module(..., package.seeall)

--------------------------------------------------------------------------------
-- import
--------------------------------------------------------------------------------
local MenuControlView = widgets.MenuControlView
local MenuMemberView = widgets.MenuMemberView

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    menuMemberView = MenuMemberView {
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

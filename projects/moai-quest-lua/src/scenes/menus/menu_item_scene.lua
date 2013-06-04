module(..., package.seeall)

--------------------------------------------------------------------------------
-- import
--------------------------------------------------------------------------------
local MenuControlView = widgets.MenuControlView
local MenuItemView = widgets.MenuItemView
local ItemSystem = systems.ItemSystem

--------------------------------------------------------------------------------
-- Variables
--------------------------------------------------------------------------------
local menuItemView
local menuControlView
local itemSystem = ItemSystem()

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    menuItemView = MenuItemView {
        scene = scene,
    }
    
    menuControlView = MenuControlView {
        scene = scene,
    }
    
    -- event listeners
    menuItemView:addEventListener("enter", menuItemView_OnEnter)
    menuControlView:addEventListener("back", menuControlView_OnBack)
end

function menuItemView_OnEnter(e)
    local item = e.data.item

    if item then
        itemSystem:useItem(item.id, 1)
        menuItemView:refresh()
    end
end

function menuControlView_OnBack(e)
    flower.closeScene()
end

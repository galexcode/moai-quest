----------------------------------------------------------------------------------------------------
-- タイトルを表示するシーンモジュールです.
--
----------------------------------------------------------------------------------------------------

module(..., package.seeall)

-- import
local Image = flower.Image
local UIView = widget.UIView
local Button = widget.Button

-- variables
local view
local newButton
local titleImage
local loadButton

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    view = UIView {
        scene = scene,
    }
    
    -- title
    titleImage = Image("title.png")
    --titleImage:setPos(math.floor(flower.viewWidth / 2 - titleImage:getWidth() / 2), 30)
    view:addChild(titleImage)
    
    -- new button
    newButton = Button {
        text = "New",
        size = {200, 50},
        pos = {math.floor(flower.viewWidth / 2 - 100), math.floor(flower.viewHeight * 2 / 3)},
        parent = view,
        onClick = newButton_OnClick,
    }
    
    -- new button
    loadButton = Button {
        text = "Load",
        size = {200, 50},
        pos = {newButton:getLeft(), newButton:getBottom() + 20},
        parent = view,
        onClick = loadButton_OnClick,
    }
end

function newButton_OnClick(e)
    flower.gotoScene(scenes.LOADING, {
        animation = "fade",
        nextSceneName = scenes.MAP,
        nextSceneParams = {animation = "fade"},
    })
end

function loadButton_OnClick(e)
    
end

module(..., package.seeall)

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    
end

function onStart(e)
    local data = e.data
    local nextSceneName = data.nextSceneName
    local nextSceneParams = data.nextSceneParams
    
    flower.gotoScene(nextSceneName, nextSceneParams)
end
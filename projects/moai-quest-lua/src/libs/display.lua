----------------------------------------------------------------------------------------------------
-- プリミティブな表示オブジェクトを定義するモジュールです.
--
----------------------------------------------------------------------------------------------------

-- module
local M = {}

-- import
local flower = require "flower"
local class = flower.class
local table = flower.table
local Group = flower.Group
local SheetImage = flower.SheetImage
local MovieClip = flower.MovieClip

-- classes
local FaceImage
local ActorImage
local BattlerImage
local MonsterImage
local IconImage

--------------------------------------------------------------------------------
-- @type FaceImage
--------------------------------------------------------------------------------
FaceImage = class(SheetImage)
M.FaceImage = FaceImage

function FaceImage:init(faceNo)
    FaceImage.__super.init(self, self:getFaceTexturePath(faceNo), 4, 2)
    self:setIndex(1)
end

function FaceImage:setFace(faceNo)
    self._faceNo = faceNo
    self:setTexture(self:getFaceTexturePath(faceNo))
end

function FaceImage:getFaceTexturePath(faceNo)
    return "face" .. faceNo .. ".png"
end

--------------------------------------------------------------------------------
-- @type ActorImage
--------------------------------------------------------------------------------
ActorImage = class(MovieClip)

function ActorImage:init(texture)
    ActorImage.__super.init(self, texture, 3, 4)
    self:initAnims()
end

function ActorImage:initAnims()
    
end

--------------------------------------------------------------------------------
-- @type BattlerImage
--------------------------------------------------------------------------------
BattlerImage = class(MovieClip)
M.BattlerImage = BattlerImage

--- Animation Data
BattlerImage.ANIM_LIST = {
    {name = "damege", frames = {4, 5, 6, 6, 6, 6, 2}, sec = 0.1, mode = MOAITimer.NORMAL},
    {name = "dying", frames = {7, 8, 9, 9}, sec = 0.1},
    {name = "victoryPose", frames = {13, 14, 15, 15}, sec = 0.1, mode = MOAITimer.NORMAL},
    {name = "avoid", frames = {16, 17, 18, 18, 2}, sec = 0.1, mode = MOAITimer.NORMAL},
}

function BattlerImage:init(texture)
    BattlerImage.__super.init(self, texture, 3, 12)
    self:initAnims()
end

function BattlerImage:initAnims()
    self:setAnimDatas(BattlerImage.ANIM_LIST)
end

function BattlerImage:waitAnim()
    self:stopAnim()
    self:setIndex(2)
end

function BattlerImage:damegeAnim()
    self:playAnim("damege")
    self:moveHitback(0.6)
end

function BattlerImage:dyingAnim()
    self:playAnim("dying")
end

function BattlerImage:victoryPoseAnim()
    self:playAnim("victoryPose")
end

function BattlerImage:avoidAnim()
    self:playAnim("avoid")
    self:moveHitback(0.4)
end

function BattlerImage:moveHitback(sec)
    if self.hitbackAction then
        return
    end
    self.hitbackAction = self:moveLoc(8, 0, 0, sec, MOAIEaseType.EASE_IN)
    flower.callOnce(function()
        MOAICoroutine.blockOnAction(self.hitbackAction)
        self:addLoc(-8, 0, 0)
        self.hitbackAction = nil
    end)
end

--------------------------------------------------------------------------------
-- @type IconImage
--------------------------------------------------------------------------------
IconImage = class(SheetImage)
M.IconImage = IconImage

IconImage.TEXTURE = "icons.png"

function IconImage:init()
    ActorImage.__super.init(self, IconImage.TEXTURE)
end


return M
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
local BitmapLabel

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
-- @type IconImage
--------------------------------------------------------------------------------
IconImage = class(SheetImage)
M.IconImage = IconImage

IconImage.TEXTURE = "icons.png"

function IconImage:init()
    ActorImage.__super.init(self, IconImage.TEXTURE)
end


return M
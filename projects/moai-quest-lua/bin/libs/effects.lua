----------------------------------------------------------------------------------------------------
-- エフェクトを定義するモジュールです.
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
local Label = flower.Label

-- classes
local Effect
local DamegeEffect
local SkillEffect

--------------------------------------------------------------------------------
-- @type Effect
-- エフェクトの抽象クラスです.
-- 共通的な動作を定義します.
--------------------------------------------------------------------------------
Effect = class(Group)
M.Effect = Effect

--- エフェクト完了時のイベントです.
Effect.EVENT_COMPLETE = "complete"

function Effect:init()
    Effect.__super.init(self)
end

---
-- エフェクトを開始します.
-- @param エフェクト対象のターゲット
function Effect:play(target)
    self:setParent(target)
    self:setLayer(target.layer)

    flower.callOnce(
    function()
        self:_doEffect()
        self:setParent(nil)
        self:setLayer(nil)
        self:dispatchEvent(Effect.EVENT_COMPLETE)
    end)
end

---
-- 実際にエフェクトを行う関数です.
-- コールチン経由で起動されます.
-- デフォルトでは空実装なので、この関数を継承してください.
function Effect:_doEffect()
end

--------------------------------------------------------------------------------
-- @type DamegeEffect
-- ダメージが発生した時のエフェクトです.
-- ダメージポイントを表示します.
--------------------------------------------------------------------------------
DamegeEffect = class(Effect)
M.DamegeEffect = DamegeEffect

---
-- コンストラクタ
-- @param point ダメージポイント
function DamegeEffect:init(point)
    DamegeEffect.__super.init(self)
    self._damegePoint = point or 0
    self._label = Label("HP" .. tostring(self._damegePoint), nil, nil, nil, 12)
    self:setColor(1, 0, 0, 1)
    self:addChild(self._label)
end

---
-- ダメージポイントを設定します.
-- @param point ダメージポイント
function DamegeEffect:setDamegePoint(point)
    self._damegePoint = point
    self._label:setString(tostring(point))
    self._label:fitSize()
end

---
-- ダメージエフェクトを表示します.
function DamegeEffect:_doEffect()
    local w, h = self._label:getSize()
    self._label:setPos(-w, 0)
    self.parent:setColor(1, 0.5, 0.5, 1)
    self.parent:seekColor(1, 1, 1, 1, 0.5)
    MOAICoroutine.blockOnAction(self._label:moveLoc(0, -12, 0, 1, MOAIEaseType.LINEAR))
end

--------------------------------------------------------------------------------
-- @type SkillEffect
-- ダメージが発生した時のエフェクトです.
-- ダメージポイントを表示します.
--------------------------------------------------------------------------------
SkillEffect = class(Effect)
M.SkillEffect = SkillEffect

---
-- コンストラクタ
-- @param point ダメージポイント
function SkillEffect:init(effectEntity)
    SkillEffect.__super.init(self)
    self._effectImage = MovieClip(effectEntity.texture, effectEntity.tileSize[1], effectEntity.tileSize[2])
    self._effectImage:setAnimData("effect", effectEntity.effectData)
    self:addChild(self._effectImage)
end

---
-- ダメージエフェクトを表示します.
function SkillEffect:_doEffect()
    local parentW, parentH = self.parent:getSize()
    local effectW, effectH = self._effectImage:getSize()
    self._effectImage:setPos((parentW - effectW) / 2, (parentH - effectH) / 2)
    self._effectImage:playAnim("effect")
    while self._effectImage:isBusy() do
        coroutine.yield()
    end
end

return M
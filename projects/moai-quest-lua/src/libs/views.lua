----------------------------------------------------------------------------------------------------
-- ビュークラスを定義するモジュールです.
-- 
-- ビューとは、複数のウィジェットで構成される部品の集まりです.
-- 
-- 
----------------------------------------------------------------------------------------------------


-- module
local M = {}

-- import
local flower = require "flower"
local widget = require "widget"
local widgets = require "libs/widgets"
local entities = require "libs/entities"
local repositry = entities.repositry
local InputMgr = flower.InputMgr
local class = flower.class
local table = flower.table
local Image = flower.Image
local UIView = widget.UIView
local Joystick = widget.Joystick
local Button = widget.Button
local Panel = widget.Panel
local ListBox = widget.ListBox
local ListItem = widget.ListItem
local TextBox = widget.TextBox
local ActorStatusBox = widgets.ActorStatusBox
local ActorDetailBox = widgets.ActorDetailBox
local ItemListBox = widgets.ItemListBox
local SkillListBox = widgets.SkillListBox
local MemberListBox = widgets.MemberListBox

-- classes
local TitleMenuView
local MapControlView
local MapStatusView
local BattleMainView
local BattleStatusView
local BattleMenuView
local MenuControlView
local MenuMainView
local MenuItemView
local MenuSkillView
local MenuStatusView
local MenuMemberView
local MenuSettingView

-- consts
local STICK_TO_DIR = {
    top = "up",
    left = "left",
    right = "right",
    bottom = "down"
}

local KeyCode = {}
KeyCode.LEFT = string.byte("a")
KeyCode.RIGHT = string.byte("d")
KeyCode.UP = string.byte("w")
KeyCode.DOWN = string.byte("s")

-- ウィジェットの最大の横幅
local WIDGET_WIDTH = 320

--------------------------------------------------------------------------------
-- @type TitleMenuView
-- タイトルメニューを表示するためのビュークラスです.
--------------------------------------------------------------------------------
TitleMenuView = class(UIView)
M.TitleMenuView = TitleMenuView

---
-- オブジェクトを生成します.
function TitleMenuView:_createChildren()
    TitleMenuView.__super._createChildren(self)

    self.titleImage = Image("title.png")
    self.titleImage:setLoc(self:getWidth() / 2, self:getHeight() / 2)
    self:addChild(self.titleImage)
    
    self.newButton = Button {
        text = "New",
        size = {200, 50},
        pos = {math.floor(flower.viewWidth / 2 - 100), math.floor(flower.viewHeight / 2)},
        parent = self,
        onClick = function(e)
            self:dispatchEvent("newGame")
        end,
    }
    
    self.loadButton = Button {
        text = "Load",
        size = {200, 50},
        pos = {self.newButton:getLeft(), self.newButton:getBottom() + 10},
        parent = self,
        onClick = function(e)
            self:dispatchEvent("loadGame")
        end,
    }
end


--------------------------------------------------------------------------------
-- @type MapControlView
-- ゲームマップをコントロールするためのビュークラスです.
--------------------------------------------------------------------------------
MapControlView = class(UIView)
M.MapControlView = MapControlView

---
-- オブジェクトを生成します.
function MapControlView:_createChildren()
    MapControlView.__super._createChildren(self)

    self.joystick = Joystick {
        parent = self,
        stickMode = "digital",
        color = {0.6, 0.6, 0.6, 0.6},
    }

    self.menuButton = Button {
        size = {100, 50},
        color = {0.6, 0.6, 0.6, 0.6},
        text = "Menu",
        parent = self,
        onClick = function(e)
            self:dispatchEvent("menu")
        end,
    }

end

---
-- 表示を更新します.
function MapControlView:updateDisplay()
    MapControlView.__super.updateDisplay(self)

    local vw, vh = flower.getViewSize()
    local joystick = self.joystick
    local menuButton = self.menuButton

    joystick:setPos(10, vh - joystick:getHeight() - 10)
    menuButton:setPos(vw - menuButton:getWidth() - 10, vh - menuButton:getHeight() - 10)
end

---
-- プレイヤーを移動する方向を返します.
-- @return 移動方向
function MapControlView:getDirection()
    if InputMgr:keyIsDown(KeyCode.LEFT) then
        return "left"
    end
    if InputMgr:keyIsDown(KeyCode.UP) then
        return "up"
    end
    if InputMgr:keyIsDown(KeyCode.RIGHT) then
        return "right"
    end
    if InputMgr:keyIsDown(KeyCode.DOWN) then
        return "down"
    end
    return STICK_TO_DIR[self.joystick:getStickDirection()]
end

--------------------------------------------------------------------------------
-- @type MapStatusView
-- ゲームマップの上にステータスを表示する為のビュークラスです.
--------------------------------------------------------------------------------
MapStatusView = class(UIView)
M.MapStatusView = MapStatusView

---
-- オブジェクトを生成します.
function MapStatusView:_createChildren()
    MapStatusView.__super._createChildren(self)

end

---
-- 表示を更新します.
function MapStatusView:updateDisplay()
    MapControlView.__super.updateDisplay(self)

end

--------------------------------------------------------------------------------
-- @type MenuControlView
-- メニューシーンをコントロールするためのビュークラスです.
--------------------------------------------------------------------------------
MenuControlView = class(UIView)
M.MenuControlView = MenuControlView

---
-- オブジェクトを生成します.
function MenuControlView:_createChildren()
    MenuControlView.__super._createChildren(self)

    self.backButton = Button {
        size = {100, 50},
        pos = {flower.viewWidth - 100 - 10, flower.viewHeight - 50 - 10},
        color = {0.6, 0.6, 0.6, 0.6},
        text = "Back",
        parent = self,
        onClick = function(e)
            self:dispatchEvent("back")
        end,
    }

end

--------------------------------------------------------------------------------
-- @type BattleMainView
-- バトルを行う為のビューです.
-- エネミーを表示します.
--------------------------------------------------------------------------------
BattleMainView = class(UIView)
M.BattleMainView = BattleMainView

---
-- コンストラクタ
-- @param params パラメータ
function BattleMainView:init(params)
    self.enemy = assert(params.enemy)

    BattleMainView.__super.init(self, params)
end

---
-- オブジェクトを生成します.
function BattleMainView:_createChildren()
    BattleMainView.__super._createChildren(self)

    self.backgroundRect = flower.Rect(self:getWidth(), self:getHeight())
    self.backgroundRect:setColor(0, 0, 0, 0.5)
    self:addChild(self.backgroundRect)

    self.enemyImage = Image(self.enemy.texture)
    self.enemyImage:setLoc(self:getWidth() / 2, 150)
    self:addChild(self.enemyImage)
end

---
-- 表示オブジェクトを更新します.
function BattleMainView:updateDisplay()
    BattleMainView.__super.updateDisplay(self)
    
    
end

---
-- エネミーを設定します.
function BattleMainView:setEnemy(enemy)
    self.enemy = assert(enemy)
    self:updateDisplay()
end

--------------------------------------------------------------------------------
-- @type BattleStatusView
-- バトルで必要なステータスを表示するビューです.
--------------------------------------------------------------------------------
BattleStatusView = class(UIView)
M.BattleStatusView = BattleStatusView

---
-- 子オブジェクトを生成します.
function BattleStatusView:_createChildren()
    BattleStatusView.__super._createChildren(self)
    
    self.actorStatusBoxList = {}
    
    for i, actor in ipairs(repositry:getMembers()) do
        local statusBox = ActorStatusBox {
            parent = self,
            actor = actor,
        }
        statusBox:setPos((i - 1) * statusBox:getWidth(), self:getHeight() - statusBox:getHeight())
        table.insert(self.actorStatusBoxList, statusBox)
    end
end

---
-- アクターがダメージを受けた時のイベントハンドラです.
function BattleStatusView:onActorDamege(e)
    -- TODO:ダメージエフェクトの実装
end

--------------------------------------------------------------------------------
-- @type MenuMainView
-- メインメニューのビュークラスです.
--------------------------------------------------------------------------------
MenuMainView = class(UIView)
M.MenuMainView = MenuMainView

---
-- 子オブジェクトを生成します.
function MenuMainView:_createChildren()
    MenuMainView.__super._createChildren(self)

    self.menuList = ListBox {
        width = self:getWidth(),
        pos = {0, 0},
        rowCount = 2,
        columnCount = 3,
        parent = self,
        labelField = "title",
        listData = {repositry:getMenus()},
        onItemChanged = function(e)
            local data = e.data
            local text = data and data.description or ""
            self.menuMsgBox:setText(text)
        end,
        onItemEnter = function(e)
            self:dispatchEvent("enter", e.data)
        end,
    }

    self.menuMsgBox = widget.TextBox {
        size = {self:getWidth(), 40},
        pos = {0, self.menuList:getBottom()},
        parent = self,
    }

end

--------------------------------------------------------------------------------
-- @type MenuItemView
-- アイテムメニューのビュークラスです.
--------------------------------------------------------------------------------
MenuItemView = class(UIView)
M.MenuItemView = MenuItemView

---
-- 子オブジェクトを生成します.
function MenuItemView:_createChildren()
    MenuItemView.__super._createChildren(self)

    self.itemList = ItemListBox {
        pos = {0, 0},
        parent = self,
        onItemChanged = function(e)
            local data = e.data
            local text = data and data.item.description or ""
            self.itemMsgBox:setText(text)
        end,
        onItemEnter = function(e)
            self:dispatchEvent("enter", e.data)
        end,
    }

    self.itemMsgBox = widget.TextBox {
        size = {WIDGET_WIDTH, 80},
        pos = {0, self.itemList:getBottom()},
        parent = self,
    }
end

--------------------------------------------------------------------------------
-- @type MenuSkillView
-- スキルメニューのビュークラスです.
--------------------------------------------------------------------------------
MenuSkillView = class(UIView)
M.MenuSkillView = MenuSkillView

---
-- 子オブジェクトを生成します.
function MenuSkillView:_createChildren()
    MenuSkillView.__super._createChildren(self)
    
    self.memberList = MemberListBox {
        pos = {0, 0},
        parent = self,
        selectedIndex = 0,
        onItemChanged = function(e)
            local data = e.data
            self.skillList:setActor(data)
        end,
    }

    self.skillList = SkillListBox {
        pos = {0, self.memberList:getBottom() + 5},
        actor = repositry:getActorById(1),
        parent = self,
        onItemChanged = function(e)
            local data = e.data
            local text = data and data.descripsion or ""
            self.msgBox:setText(text)
        end,
        onItemEnter = function(e)
            self:dispatchEvent("enter", e.data)
        end,
    }

    self.msgBox = widget.TextBox {
        size = {WIDGET_WIDTH, 80},
        pos = {0, self.skillList:getBottom()},
        parent = self,
    }
end

--------------------------------------------------------------------------------
-- @type MenuStatusView
-- ステータスメニューのビュークラスです.
--------------------------------------------------------------------------------
MenuStatusView = class(UIView)
M.MenuStatusView = MenuStatusView

---
-- 内部変数の初期化処理です.
function MenuStatusView:_initInternal()
    MenuStatusView.__super._initInternal(self)
    self._statusBoxList = {}
end

---
-- 子オブジェクトの生成処理です.
function MenuStatusView:_createChildren()
    MenuStatusView.__super._createChildren(self)

    self.memberList = MemberListBox {
        pos = {0, 0},
        parent = self,
        selectedIndex = 0,
        onItemChanged = function(e)
            local data = e.data
            self.detailBox:setActor(data)
        end,
    }

    self.detailBox = ActorDetailBox {
        actor = {repositry:getActorById(1)},
        parent = self,
        pos = {0, self.memberList:getBottom() + 5}
    }
end

--------------------------------------------------------------------------------
-- @type MenuSettingView
-- 設定メニューのビュークラスです.
-- システムの設定を変更します.
--------------------------------------------------------------------------------
MenuSettingView = class(UIView)
M.MenuSettingView = MenuSettingView

function MenuSettingView:_initInternal()
    MenuSettingView.__super._initInternal(self)
end

function MenuSettingView:_createChildren()
    MenuStatusView.__super._createChildren(self)
end

return M
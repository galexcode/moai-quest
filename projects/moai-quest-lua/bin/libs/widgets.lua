----------------------------------------------------------------------------------------------------
-- ゲームで使用するウィジェットクラスを定義するモジュールです.
--
----------------------------------------------------------------------------------------------------


-- module
local M = {}

-- import
local flower = require "flower"
local widget = require "widget"
local repositry = require "libs/repositry"
local display = require "libs/display"
local class = flower.class
local table = flower.table
local InputMgr = flower.InputMgr
local SceneMgr = flower.SceneMgr
local Group = flower.Group
local Label = flower.Label
local UIView = widget.UIView
local Joystick = widget.Joystick
local Button = widget.Button
local Panel = widget.Panel
local ListBox = widget.ListBox
local TextBox = widget.TextBox
local FaceImage = display.FaceImage

-- classes
local MapControlView
local MenuControlView
local MenuMainView
local MenuItemView
local MenuSkillView
local MenuStatusView
local MenuMemberView
local MenuSettingView
local MenuActorStatusBox
local MenuActorDetailBox
local ItemListBox
local ItemListItem
local SkillListBox
local SkillListItem
local MemberListBox
local MemberListItem

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

--------------------------------------------------------------------------------
-- @type MapControlView
-- ゲームマップをコントロールするためのビュークラスです.
--------------------------------------------------------------------------------
MapControlView = class(UIView)
M.MapControlView = MapControlView

function MapControlView:_createChildren()
    MapControlView.__super._createChildren(self)

    self.joystick = Joystick {
        parent = self,
        stickMode = "digital",
        color = {0.6, 0.6, 0.6, 0.6},
    }
    
    self.enterButton = Button {
        size = {100, 50},
        color = {0.6, 0.6, 0.6, 0.6},
        text = "Enter",
        parent = self,
        onClick = function(e)
            self:dispatchEvent("enter")
        end,
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

function MapControlView:updateDisplay()
    MapControlView.__super.updateDisplay(self)
    
    local vw, vh = flower.getViewSize()
    local joystick = self.joystick
    local menuButton = self.menuButton
    local enterButton = self.enterButton
    
    joystick:setPos(10, vh - joystick:getHeight() - 10)
    menuButton:setPos(vw - menuButton:getWidth() - 10, vh - menuButton:getHeight() - enterButton:getHeight() - 20)
    enterButton:setPos(vw - enterButton:getWidth() - 10, menuButton:getBottom() + 10)
end

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
-- @type MenuControlView
-- メニューシーンをコントロールするためのビュークラスです.
--------------------------------------------------------------------------------
MenuControlView = class(UIView)
M.MenuControlView = MenuControlView

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
-- @type MenuMainView
-- メインメニューのビュークラスです.
--------------------------------------------------------------------------------
MenuMainView = class(UIView)
M.MenuMainView = MenuMainView

function MenuMainView:_createChildren()
    MenuMainView.__super._createChildren(self)

    self.menuTitle = widget.TextBox {
        size = {310, 40},
        pos = {5, 5},
        text = "GOLD:999",
        parent = self,
    }

    self.menuList = ListBox {
        width = 310,
        pos = {5, self.menuTitle:getBottom()},
        rowCount = 3,
        columnCount = 2,
        parent = self,
        labelField = "label",
        listData = {repositry.getMainMenus()},
        onItemChanged = function(e)
            local data = e.data
            local text = data and data.help_msg or ""
            self.menuMsgBox:setText(text)
        end,
        onItemEnter = function(e)
            self:dispatchEvent("enter", e.data)
        end,
    }
    
    self.menuMsgBox = widget.TextBox {
        size = {310, 40},
        pos = {5, self.menuList:getBottom()},
        parent = self,
    }
    
end

--------------------------------------------------------------------------------
-- @type MenuItemView
-- アイテムメニューのビュークラスです.
--------------------------------------------------------------------------------
MenuItemView = class(UIView)
M.MenuItemView = MenuItemView

function MenuItemView:_createChildren()
    MenuItemView.__super._createChildren(self)

    self.menuTitle = widget.TextBox {
        size = {310, 40},
        pos = {5, 5},
        text = "アイテムリスト",
        parent = self,
    }

    self.itemList = ListBox {
        width = 310,
        pos = {5, self.menuTitle:getBottom()},
        rowCount = 8,
        parent = self,
        labelField = "label",
        listData = {repositry.getItemMenus()},
        onItemChanged = function(e)
            local data = e.data
            local text = data and data.msg or ""
            self.itemMsgBox:setText(text)
        end,
        onItemEnter = function(e)
            self:dispatchEvent("enter", e.data)
        end,
    }
    
    self.itemMsgBox = widget.TextBox {
        size = {310, 80},
        pos = {5, self.itemList:getBottom()},
        parent = self,
    }
end

function MenuItemView:refresh()
    self.itemList:setListData(repositry.getItemMenus())
end

--------------------------------------------------------------------------------
-- @type MenuSkillView
-- スキルメニューのビュークラスです.
--------------------------------------------------------------------------------
MenuSkillView = class(UIView)
M.MenuSkillView = MenuSkillView

function MenuSkillView:_createChildren()
    MenuSkillView.__super._createChildren(self)

    self.actorStatusBox = MenuActorStatusBox {
        pos = {5, 5},
        parent = self,
    }

    self.listBox = ListBox {
        width = 310,
        pos = {5, self.actorStatusBox:getBottom()},
        rowCount = 6,
        parent = self,
        labelField = "label",
        listData = {repositry.getSkillMenus(1)}, -- TODO:ダミー
        onItemChanged = function(e)
            local data = e.data
            local text = data and data.msg or ""
            self.msgBox:setText(text)
        end,
        onItemEnter = function(e)
            self:dispatchEvent("enter", e.data)
        end,
    }
    
    self.msgBox = widget.TextBox {
        size = {310, 80},
        pos = {5, self.listBox:getBottom()},
        parent = self,
    }
end

--------------------------------------------------------------------------------
-- @type MenuStatusView
-- ステータスメニューのビュークラスです.
--------------------------------------------------------------------------------
MenuStatusView = class(UIView)
M.MenuStatusView = MenuStatusView

function MenuStatusView:_initInternal()
    MenuStatusView.__super._initInternal(self)
    self._statusBoxList = {}
end

function MenuStatusView:_createChildren()
    MenuStatusView.__super._createChildren(self)
    
    local members = repositry.getMembers()
    --[[
    for i, actor in ipairs(actors) do
        local statusBox = MenuActorStatusBox {
            actor = actor,
            parent = self,
            pos = {5, 5 + (i - 1) * 110},
        }
    end]]
    self.detailBox = MenuActorDetailBox {
        actor = {members[1]},
        parent = self,
        pos = {5, 5}
    }
    
    self.memberList = MemberListBox {
        pos = {5, self.detailBox:getBottom()},
        selectedIndex = 1,
        parent = self,
        onItemChanged = function(e)
            local actor = e.data
            self.detailBox:setActor(actor)
        end,
    }
end

--------------------------------------------------------------------------------
-- @type MenuMemberView
-- メンバーメニューのビュークラスです.
-- メンバーの入れ替えを行うメニューです.
--------------------------------------------------------------------------------
MenuMemberView = class(UIView)
M.MenuMemberView = MenuMemberView

function MenuMemberView:_initInternal()
    MenuMemberView.__super._initInternal(self)
end

function MenuMemberView:_createChildren()
    MenuStatusView.__super._createChildren(self)
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

--------------------------------------------------------------------------------
-- @type MenuActorStatusBox
-- アクターの簡易的なステータスを表示するボックスです.
--------------------------------------------------------------------------------
MenuActorStatusBox = class(Panel)
M.MenuActorStatusBox = MenuActorStatusBox

function MenuActorStatusBox:_initInternal()
    MenuActorStatusBox.__super._initInternal(self)
    self._faceImage = nil
    self._statusLabel = nil
    self._actor = nil
end

function MenuActorStatusBox:_createChildren()
    MenuActorStatusBox.__super._createChildren(self)
    self:_createFaceImage()
    self:_createStatusLabel()
    
    self:setSize(310, 110)
end

function MenuActorStatusBox:_createFaceImage()
    self._faceImage = FaceImage(1)
    self._faceImage:setPos(5, 5)
    self:addChild(self._faceImage)
end

function MenuActorStatusBox:_createStatusLabel()
    self._statusLabel = Label("NAME:ダミー\nHP:100/100\nMP:50/50", 200, 90, nil, 20)
    self._statusLabel:setPos(self._faceImage:getRight() + 10, 5)
    self:addChild(self._statusLabel)
end

function MenuActorStatusBox:updateDisplay()
    MenuActorStatusBox.__super.updateDisplay(self)
end

function MenuActorStatusBox:setActor(actor)
    self._actor = actor
end

function MenuActorStatusBox:makeStatusMsg()
    if not self._actor then
        return ""
    end
    
end

--------------------------------------------------------------------------------
-- @type MenuActorDetailBox
-- アクターのステータス詳細を表示するボックスです.
--------------------------------------------------------------------------------
MenuActorDetailBox = class(Panel)
M.MenuActorDetailBox = MenuActorDetailBox

-- Label names
MenuActorDetailBox.STATUS_LABEL_NAMES = {
    "STR",
    "VIT",
    "INT",
    "MEN",
    "SPD",
}

-- Label names
MenuActorDetailBox.EQUIP_ICONS = {
    1,
    2,
    3,
    4,
}

function MenuActorDetailBox:_initInternal()
    MenuActorDetailBox.__super._initInternal(self)
    self._faceImage = nil
    self._statusNameLabels = {}
    self._statusValueLabels = {}
    self._actor = nil
end

function MenuActorDetailBox:_createChildren()
    MenuActorDetailBox.__super._createChildren(self)
    self:_createFaceImage()
    self:_createHeaderLabel()
    self:_createStatusLabel()
    
    self:setSize(310, 260)
end

function MenuActorDetailBox:_createFaceImage()
    self._faceImage = FaceImage(1)
    self._faceImage:setPos(10, 10)
    self:addChild(self._faceImage)
end

function MenuActorDetailBox:_createHeaderLabel()
    self._headerLabel = Label("DUMMY", 200, 100, nil, 20)
    self._headerLabel:setPos(self._faceImage:getRight() + 10, 10)
    self:addChild(self._headerLabel)
end

function MenuActorDetailBox:_createStatusLabel()
    local offsetX, offsetY = self._faceImage:getLeft(), 5 + self._faceImage:getBottom()
    for i, name in ipairs(MenuActorDetailBox.STATUS_LABEL_NAMES) do
        local nameLabel = Label(name, 50, 30, nil, 20)
        nameLabel:setPos(offsetX, offsetY + (i - 1) * nameLabel:getHeight())

        local valueLabel = Label("", 50, 30, nil, 20)
        valueLabel:setPos(nameLabel:getRight(), offsetY + (i - 1) * nameLabel:getHeight())

        self:addChild(nameLabel)
        self:addChild(valueLabel)
        table.insert(self._statusNameLabels, nameLabel)
        table.insert(self._statusValueLabels, valueLabel)
    end 
end

function MenuActorDetailBox:updateDisplay()
    MenuActorDetailBox.__super.updateDisplay(self)
    self:updateHeaderLabel()
    self:updateStatusLabel()
end

function MenuActorDetailBox:setActor(actor)
    self._actor = actor
    self:updateDisplay()
end

function MenuActorDetailBox:updateHeaderLabel()
    if not self._actor then
        return
    end
    local a = self._actor
    local text = string.format("%s\nHP:%d/%d\nMP:%d/%d", a.name, a.hp, a.mhp, a.mp, a.mmp)
    self._headerLabel:setString(text)
end

function MenuActorDetailBox:updateStatusLabel()
    if not self._actor then
        return
    end
    local actor = self._actor
    self._statusValueLabels[1]:setString(tostring(actor.str))
    self._statusValueLabels[2]:setString(tostring(actor.vit))
    self._statusValueLabels[3]:setString(tostring(actor.int))
    self._statusValueLabels[4]:setString(tostring(actor.men))
    self._statusValueLabels[5]:setString(tostring(actor.spd))
end

--------------------------------------------------------------------------------
-- @type ItemListBox
-- アイテムを表示するリストボックスです.
--------------------------------------------------------------------------------
ItemListBox = class(ListBox)
M.ItemListBox = ItemListBox

function ItemListBox:init(params)
    ItemListBox.__super.init(self, params)
    
    self:setListData(repositry.getItemMenus())
    self:setWidth(310)
    self:setRowCount(8)
    self:setLabelField("label")
end


--------------------------------------------------------------------------------
-- @type MemberListBox
-- メンバーを表示するリストボックスです.
--------------------------------------------------------------------------------
MemberListBox = class(ListBox)
M.MemberListBox = MemberListBox

function MemberListBox:init(params)
    MemberListBox.__super.init(self, params)
    
    self:setListData(repositry.getMembers())
    self:setWidth(310)
    self:setRowCount(4)
    self:setLabelField("name")
end

return M
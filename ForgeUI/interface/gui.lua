----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		hui.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI GUI library
-----------------------------------------------------------------------------------------------

require "Window"

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local ForgeColor

-----------------------------------------------------------------------------------------------
-- ForgeUI Library Definition
-----------------------------------------------------------------------------------------------
local Gui = {
	_NAME = "gui",
	_API_VERSION = 3,
	_VERSION = "1.0",
}

-----------------------------------------------------------------------------------------------
-- ForgeUI Library Initialization
-----------------------------------------------------------------------------------------------
local strPrefix
local xmlDoc = nil

local new = function(self, o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	o.tDefaults = {
		strFont = "Nameplates",
	}

	return o
end

function Gui:ForgeAPI_Init()
	ForgeColor = F:API_GetModule("forgecolor")

	strPrefix = Apollo.GetAssetFolder()
	local tToc = XmlDoc.CreateFromFile("toc.xml"):ToTable()
	for k,v in ipairs(tToc) do
		local strPath = string.match(v.Name, "(.*)[\\/]Interface")
		if strPath ~= nil and strPath ~= "" then
			strPrefix = strPrefix .. "\\" .. strPath .. "\\"
			break
		end
	end

	xmlDoc = XmlDoc.CreateFromFile(strPrefix .. "\\interface\\gui.xml")
end

-----------------------------------------------------------------------------------------------
-- ForgeUI GUI elements
-----------------------------------------------------------------------------------------------
local EnumWindowType = {
	["Holder"] = 1,
	["Text"] = 2,
	["ColorBox"] = 3,
	["CheckBox"] = 4,
	["ComboBox"] = 5,
	["ComboBoxItem"] = 6,
	["EditBox"] = 7,
	["NumberBox"] = 6,
	["Button"] = 9,
}

-----------------------------------------------------------------------------------------------
-- Holder
-----------------------------------------------------------------------------------------------
function Gui:API_AddHolder(tModule, wnd, tOptions)
	local wndText = Apollo.LoadForm(xmlDoc, "ForgeUI_Holder", wnd, self)

	return wndText
end

-----------------------------------------------------------------------------------------------
-- Text
-----------------------------------------------------------------------------------------------
function Gui:API_AddText(tModule, wnd, strText, tOptions)
	-- defaults
	local strFont = self.tDefaults.strFont
	local strText = strText

	-- load wnd
	local wndText = Apollo.LoadForm(xmlDoc, "ForgeUI_Text", wnd, self)

	-- options
	if tOptions then
		if tOptions.tOffsets then
			wndText:SetAnchorOffsets(unpack(tOptions.tOffsets))
		end

		if tOptions.tMove then
			local nLeft, nTop, nRight, nBottom = wndText:GetAnchorOffsets()
			nLeft = nLeft + tOptions.tMove[1]
			nTop = nTop + tOptions.tMove[2]
			nRight = nRight + tOptions.tMove[1]
			nBottom = nBottom + tOptions.tMove[2]
			wndText:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
		end

		if tOptions.strFont then
			strFont = tOptions.strFont
		end
	end

	-- set wnd
	wndText:SetText(strText)
	wndText:SetFont(strFont)

	-- calculate width of element
	local nTextWidth = Apollo.GetTextWidth(strFont, "  " .. strText .. "  ")
	local nLeft, nTop, nRight, nBottom = wndText:GetAnchorOffsets()
	wndText:SetAnchorOffsets(nLeft, nTop, nLeft + nTextWidth, nBottom)

	return wndText
end

-----------------------------------------------------------------------------------------------
-- Button
-----------------------------------------------------------------------------------------------
function Gui:API_AddButton(tModule, wnd, strText, tOptions)
	-- defaults
	local tData = {
		tModule = tModule,
		eType = EnumWindowType.Button,
	}

	local strFont = self.tDefaults.strFont

	-- load wnd
	local wndButton = Apollo.LoadForm(xmlDoc, "ForgeUI_Button", wnd, self)

	-- options
	if tOptions then
		if tOptions.tOffsets then
			wndButton:SetAnchorOffsets(unpack(tOptions.tOffsets))
		end

		if tOptions.tMove then
			local nLeft, nTop, nRight, nBottom = wndButton:GetAnchorOffsets()
			nLeft = nLeft + tOptions.tMove[1]
			nTop = nTop + tOptions.tMove[2]
			nRight = nRight + tOptions.tMove[1]
			nBottom = nBottom + tOptions.tMove[2]
			wndButton:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
		end

		if tOptions.strFont then
			strFont = tOptions.strFont
		end

		if tOptions.fnCallback then
			tData.fnCallback = tOptions.fnCallback
		end
	end

	-- set wnd
	wndButton:SetText(strText)
	wndButton:SetFont(strFont)
	wndButton:AddEventHandler("ButtonSignal", "OnButtonSignal", self)
	wndButton:SetData(tData)

	return wndButton
end

function Gui:OnButtonSignal(wndControl)
	local tData = wndControl:GetData()
	if tData == nil then return end

	if tData.fnCallback ~= nil then
		tData.fnCallback(tData.tModule)
	end
end

-----------------------------------------------------------------------------------------------
-- ColorBox
-----------------------------------------------------------------------------------------------
function Gui:API_AddColorBox(tModule, wnd, strText, tSettings, strKey, tOptions)
	-- defaults
	local tData = {
		tModule = tModule,
		tSettings = tSettings,
		strKey = strKey,
		eType = EnumWindowType.ColorBox,
	}

	if tSettings ~= nil then
		tData.strColor = tSettings[strKey]
	end

	local strFont = self.tDefaults.strFont
	local strText = strText

	-- load wnd
	local wndColorBox = Apollo.LoadForm(xmlDoc, "ForgeUI_ColorBox", wnd, self)

	-- event handlers
	wndColorBox:FindChild("ColorBox"):AddEventHandler("MouseButtonDown", "OnColorBoxDown", self)

	-- options
	if tOptions then
		if tOptions.tOffsets then
			wndColorBox:SetAnchorOffsets(unpack(tOptions.tOffsets))
		end

		if tOptions.tMove then
			local nLeft, nTop, nRight, nBottom = wndColorBox:GetAnchorOffsets()
			nLeft = nLeft + tOptions.tMove[1]
			nTop = nTop + tOptions.tMove[2]
			nRight = nRight + tOptions.tMove[1]
			nBottom = nBottom + tOptions.tMove[2]
			wndColorBox:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
		end

		if tOptions.fnCallback then
			tData.fnCallback = tOptions.fnCallback
		end
	end

	-- set wnd
	wndColorBox:FindChild("Text"):SetText(strText)
	wndColorBox:FindChild("Text"):SetFont(strFont)

	-- data
	wndColorBox:SetData(tData)

	self:SetColorBox(wndColorBox, true)

	return wndColorBox
end

function Gui:SetColorBox(wndControl, bChangeText)
	local tData = wndControl:GetData()

	wndControl:FindChild("ColorBox"):SetBGColor(tData.strColor)

	if tData.tSettings and tData.strKey then
		tData.tSettings[tData.strKey] = tData.strColor
	end

	if tData.tModule and tData.fnCallback then
		tData.fnCallback(tData.tModule, tData.strColor, tData.strKey)
	end
end

function Gui:OnColorBoxDown(wndHandler, wndControl, eMouseButton)
	local tData = wndControl:GetParent():GetParent():GetData()

	ForgeColor:API_ShowPicker(tData.tModule, tData.tSettings[tData.strKey], {
		tSettings = tData.tSettings,
		strKey = tData.strKey,
		wndControl = wndControl,
		fnCallback = tData.fnCallback,
	})
end

-----------------------------------------------------------------------------------------------
-- CheckBox
-----------------------------------------------------------------------------------------------
function Gui:API_AddCheckBox(tModule, wnd, strText, tSettings, strKey, tOptions)
	-- defaults
	local tData = {
		tModule = tModule,
		tSettings = tSettings,
		strKey = strKey,
		eType = EnumWindowType.CheckBox,
	}

	if tSettings ~= nil then
		tData.bCheck = tSettings[strKey]
	end

	local strFont = self.tDefaults.strFont
	local strText = strText

	-- load wnd
	local wndCheckBox = Apollo.LoadForm(xmlDoc, "ForgeUI_CheckBox", wnd, self)

	-- event handlers
	wndCheckBox:AddEventHandler("ButtonCheck", "OnCheckBoxCheck", self)
	wndCheckBox:AddEventHandler("ButtonUncheck", "OnCheckBoxCheck", self)

	-- options
	if tOptions then
		if tOptions.tOffsets then
			wndCheckBox:SetAnchorOffsets(unpack(tOptions.tOffsets))
		end

		if tOptions.tMove then
			local nLeft, nTop, nRight, nBottom = wndCheckBox:GetAnchorOffsets()
			nLeft = nLeft + tOptions.tMove[1]
			nTop = nTop + tOptions.tMove[2]
			nRight = nRight + tOptions.tMove[1]
			nBottom = nBottom + tOptions.tMove[2]
			wndCheckBox:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
		end

		if tOptions.nAddWidth then
			local nLeft, nTop, nRight, nBottom = wndCheckBox:GetAnchorOffsets()
			wndCheckBox:SetAnchorOffsets(nLeft, nTop, nRight + tOptions.nAddWidth, nBottom)
		end

		if tOptions.fnCallback then
			tData.fnCallback = tOptions.fnCallback
		end

		if tOptions.strTooltip then
			wndCheckBox:SetTooltip(tOptions.strTooltip)
		end
	end

	-- data
	wndCheckBox:SetData(tData)

	-- set wnd
	wndCheckBox:FindChild("Text"):SetFont(strFont)
	wndCheckBox:FindChild("Text"):SetText(strText)

	self:SetCheckBox(wndCheckBox)

	return wndCheckBox
end

function Gui:SetCheckBox(wndControl)
	local tData = wndControl:GetData()

	wndControl:FindChild("CheckBox"):SetCheck(tData.bCheck)

	if tData.tSettings and tData.strKey then
		tData.tSettings[tData.strKey] = tData.bCheck
	end
end

function Gui:OnCheckBoxCheck(wndHandler, wndControl, eMouseButton)
	local tData = wndControl:GetParent():GetData()

	tData.bCheck = wndControl:IsChecked()

	self:SetCheckBox(wndControl:GetParent())

	if tData.fnCallback then
		tData.fnCallback(tData.tModule, tData.bCheck)
	end
end

-----------------------------------------------------------------------------------------------
-- ComboBox
-----------------------------------------------------------------------------------------------
function Gui:API_AddComboBox(tModule, wnd, strText, tSettings, strKey, tOptions)
	-- defaults
	local tData = {
		tModule = tModule,
		tSettings = tSettings,
		strKey = strKey,
		eType = EnumWindowType.ComboBox,
	}

	local strFont = self.tDefaults.strFont
	local strText = strText

	-- load wnd
	local wndComboBox = Apollo.LoadForm(xmlDoc, "ForgeUI_ComboBox", wnd, self)

	-- event handlers
	wndComboBox:FindChild("Button"):AddEventHandler("ButtonSignal", "OnComboBoxButton", self)

	-- options
	if tOptions then
		if tOptions.tOffsets then
			wndComboBox:SetAnchorOffsets(unpack(tOptions.tOffsets))
		end

		if tOptions.tWidths then
			local nLeft, nTop, nRight, nBottom = wndComboBox:GetAnchorOffsets()
			wndComboBox:SetAnchorOffsets(nLeft, nTop, nLeft + tOptions.tWidths[1] + tOptions.tWidths[2] + 5, nBottom)

			nLeft, nTop, nRight, nBottom = wndComboBox:FindChild("ComboBox"):GetAnchorOffsets()
			wndComboBox:FindChild("ComboBox"):SetAnchorOffsets(nLeft, nTop, tOptions.tWidths[1], nBottom)

			nLeft, nTop, nRight, nBottom = wndComboBox:FindChild("Text"):GetAnchorOffsets()
			wndComboBox:FindChild("Text"):SetAnchorOffsets(- tOptions.tWidths[2], nTop, nRight, nBottom)
		end

		if tOptions.tMove then
			local nLeft, nTop, nRight, nBottom = wndComboBox:GetAnchorOffsets()
			nLeft = nLeft + tOptions.tMove[1]
			nTop = nTop + tOptions.tMove[2]
			nRight = nRight + tOptions.tMove[1]
			nBottom = nBottom + tOptions.tMove[2]
			wndComboBox:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
		end

		if tOptions.fnCallback then
			tData.fnCallback = tOptions.fnCallback
		end

		if tOptions.strTooltip then
			wndComboBox:SetTooltip(tOptions.strTooltip)
		end
	end

	-- data
	wndComboBox:SetData(tData)

	-- set wnd
	if tOptions and tOptions.bInnerText == true then
		wndComboBox:FindChild("EditBox"):SetFont(strFont)
		wndComboBox:FindChild("EditBox"):SetText(strText)
	else
		wndComboBox:FindChild("Text"):SetFont(strFont)
		wndComboBox:FindChild("Text"):SetText(strText)
	end

	return wndComboBox
end

function Gui:API_AddOptionToComboBox(tModule, wnd, strText, vValue, tOptions)
	if wnd:GetData().eType ~= EnumWindowType.ComboBox then return end

	-- defaults
	local tData = {
		tModule = tModule,
		vValue = vValue,
		eType = EnumWindowType.ComboBoxItem,
		wndParent = wnd,
		tParentData = wnd:GetData(),
	}

	if wnd:GetData().tSettings and wnd:GetData().strKey then
		if vValue == wnd:GetData().tSettings[wnd:GetData().strKey] then
			wnd:FindChild("EditBox"):SetText(tostring(strText))
		end
	elseif tOptions and tOptions.bDefault then
		wnd:FindChild("EditBox"):SetText(tostring(strText))
	end

	local strFont = self.tDefaults.strFont
	local strText = strText

	-- load wnd
	local wndItem = Apollo.LoadForm(xmlDoc, "ForgeUI_ComboBoxItem", wnd:FindChild("Menu"), self)

	-- event handlers
	wndItem:FindChild("Button"):AddEventHandler("ButtonSignal", "OnComboBoxItemButton", self)

	-- data
	wndItem:SetData(tData)

	-- set wnd
	wndItem:FindChild("Button"):SetFont(strFont)
	wndItem:FindChild("Button"):SetText(strText)

	local wndMenu = wnd:FindChild("Menu")
	local nLeft, nTop, nRight, nBottom = wndMenu:GetAnchorOffsets()
	wndMenu:SetAnchorOffsets(nLeft, nTop, nRight, nTop + 25 * #wndMenu:GetChildren() + 4)
	wndMenu:ArrangeChildrenVert()

	return wndItem
end

function Gui:OnComboBoxButton(wndHandler, wndControl, eMouseButton)
	wndControl:GetParent():FindChild("Menu"):Show(true)
end

function Gui:OnComboBoxItemButton(wndHandler, wndControl, eMouseButton)
	local tData = wndControl:GetParent():GetData()
	local tParentData = tData.tParentData

	tData.wndParent:FindChild("EditBox"):SetText(wndControl:GetText())

	if tParentData.tSettings and tParentData.strKey then
		tParentData.tSettings[tParentData.strKey] = tData.vValue
	end

	if tParentData.fnCallback then
		tParentData.fnCallback(tParentData.tModule, tData.vValue, tParentData.strKey)
	end

	wndControl:GetParent():GetParent():Show(false)
end

-----------------------------------------------------------------------------------------------
-- EditBox
-----------------------------------------------------------------------------------------------
function Gui:API_EditBox(tModule, wnd, strText, tSettings, strKey, tOptions)
	-- defaults
	local tData = {
		tModule = tModule,
		tSettings = tSettings,
		strKey = strKey,
		eType = EnumWindowType.EditBox,
	}

	local strFont = self.tDefaults.strFont
	local strText = strText

	-- load wnd
	local wndEditBox = Apollo.LoadForm(xmlDoc, "ForgeUI_EditBox", wnd, self)

	-- event handlers
	wndEditBox:FindChild("EditBox"):AddEventHandler("EditBoxChanged", "OnEditBoxChanged", self)
	wndEditBox:FindChild("EditBox"):AddEventHandler("EditBoxReturn", "OnEditBoxReturn", self)

	-- options
	if tOptions then
		if tOptions.tOffsets then
			wndEditBox:SetAnchorOffsets(unpack(tOptions.tOffsets))
		end

		if tOptions.tWidths then
			local nLeft, nTop, nRight, nBottom = wndEditBox:GetAnchorOffsets()
			wndEditBox:SetAnchorOffsets(nLeft, nTop, nLeft + tOptions.tWidths[1] + tOptions.tWidths[2] + 5, nBottom)

			nLeft, nTop, nRight, nBottom = wndEditBox:FindChild("Background"):GetAnchorOffsets()
			wndEditBox:FindChild("Background"):SetAnchorOffsets(nLeft, nTop, tOptions.tWidths[1], nBottom)

			nLeft, nTop, nRight, nBottom = wndEditBox:FindChild("Text"):GetAnchorOffsets()
			wndEditBox:FindChild("Text"):SetAnchorOffsets(- tOptions.tWidths[2], nTop, nRight, nBottom)
		end

		if tOptions.tMove then
			local nLeft, nTop, nRight, nBottom = wndEditBox:GetAnchorOffsets()
			nLeft = nLeft + tOptions.tMove[1]
			nTop = nTop + tOptions.tMove[2]
			nRight = nRight + tOptions.tMove[1]
			nBottom = nBottom + tOptions.tMove[2]
			wndEditBox:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
		end

		if tOptions.fnCallback then
			tData.fnCallback = tOptions.fnCallback
		end

		if tOptions.fnCallbackReturn then
			tData.fnCallbackReturn = tOptions.fnCallbackReturn
		end

		if tOptions.strHint then
			wndEditBox:FindChild("EditBox"):SetPrompt(tOptions.strHint)
		end
	end

	-- data
	wndEditBox:SetData(tData)

	-- set wnd
	if tOptions and tOptions.bInnerText then
		wndEditBox:FindChild("EditBox"):SetFont(strFont)
		wndEditBox:FindChild("EditBox"):SetText(strText)
	else
		wndEditBox:FindChild("Text"):SetFont(strFont)
		wndEditBox:FindChild("Text"):SetText(strText)
	end

	return wndEditBox
end

function Gui:OnEditBoxChanged(wndHandler, wndControl, strText)
	local tData = wndControl:GetParent():GetParent():GetData()

	if tData.tModule and tData.fnCallback then
		tData.fnCallback(tData.tModule, strText, tData.strKey)
	end
end

function Gui:OnEditBoxReturn(wndHandler, wndControl, strText)
	local tData = wndControl:GetParent():GetParent():GetData()

	if tData.tModule and tData.fnCallbackReturn then
		tData.fnCallbackReturn(tData.tModule, strText, tData.strKey)
	end
end

-----------------------------------------------------------------------------------------------
-- NumberBox
-----------------------------------------------------------------------------------------------
function Gui:API_AddNumberBox(tModule, wnd, strText, tSettings, strKey, tOptions)
	-- defaults
	local tData = {
		tModule = tModule,
		tSettings = tSettings,
		strKey = strKey,
		eType = EnumWindowType.NumberBox,
		nPrevValue = tSettings[strKey],
	}

	local strFont = self.tDefaults.strFont
	local strText = strText

	-- load wnd
	local wndNumberBox = Apollo.LoadForm(xmlDoc, "ForgeUI_NumberBox", wnd, self)

	-- event handlers
	wndNumberBox:FindChild("NumberBox"):AddEventHandler("EditBoxChanged", "OnNumberBoxChanged", self)

	-- options
	if tOptions then
		if tOptions.tOffsets then
			wndNumberBox:SetAnchorOffsets(unpack(tOptions.tOffsets))
		end

		if tOptions.tWidths then
			local nLeft, nTop, nRight, nBottom = wndNumberBox:GetAnchorOffsets()
			wndNumberBox:SetAnchorOffsets(nLeft, nTop, nLeft + tOptions.tWidths[1] + tOptions.tWidths[2] + 5, nBottom)

			nLeft, nTop, nRight, nBottom = wndNumberBox:FindChild("Background"):GetAnchorOffsets()
			wndNumberBox:FindChild("Background"):SetAnchorOffsets(nLeft, nTop, tOptions.tWidths[1], nBottom)

			nLeft, nTop, nRight, nBottom = wndNumberBox:FindChild("Text"):GetAnchorOffsets()
			wndNumberBox:FindChild("Text"):SetAnchorOffsets(- tOptions.tWidths[2], nTop, nRight, nBottom)
		end

		if tOptions.tMove then
			local nLeft, nTop, nRight, nBottom = wndNumberBox:GetAnchorOffsets()
			nLeft = nLeft + tOptions.tMove[1]
			nTop = nTop + tOptions.tMove[2]
			nRight = nRight + tOptions.tMove[1]
			nBottom = nBottom + tOptions.tMove[2]
			wndNumberBox:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
		end

		if tOptions.fnCallback then
			tData.fnCallback = tOptions.fnCallback
		end

		if tOptions.fnCallbackReturn then
			tData.fnCallbackReturn = tOptions.fnCallbackReturn
		end

		if tOptions.strHint then
			wndNumberBox:FindChild("NumberBox"):SetPrompt(tOptions.strHint)
		end

		if tOptions.strTooltip then
			wndNumberBox:SetTooltip(tOptions.strTooltip)
		end
	end

	-- data
	wndNumberBox:SetData(tData)

	-- set wnd
	wndNumberBox:FindChild("Text"):SetFont(strFont)
	wndNumberBox:FindChild("Text"):SetText(strText)
	wndNumberBox:FindChild("NumberBox"):SetText(tSettings[strKey])

	self:SetNumberBox(wndNumberBox)

	return wndNumberBox
end

function Gui:SetNumberBox(wndControl)
	local tData = wndControl:GetData()
	local wnd = wndControl:FindChild("NumberBox")

	if wnd:GetText() == "" then wnd:SetText(0) end
	if not tonumber(wnd:GetText()) then
		wnd:SetText(tData.nPrevValue)
	end

	tData.nPrevValue = wnd:GetText()

	if tData.tSettings and tData.strKey then
		tData.tSettings[tData.strKey] = tonumber(wndControl:FindChild("NumberBox"):GetText())
	end
end

function Gui:OnNumberBoxChanged(wndHandler, wndControl, strText)
	local tData = wndControl:GetParent():GetParent():GetData()

	self:SetNumberBox(wndControl:GetParent():GetParent())

	if tData.tModule and tData.fnCallback then
		tData.fnCallback(tData.tModule, strText, tData.strKey)
	end
end

-----------------------------------------------------------------------------------------------
-- ScrollWindow
-----------------------------------------------------------------------------------------------
function Gui:API_AddVScrollWindow(tModule, wndParent, wndScroll, tOptions)
	local wndVScrollWindow = Apollo.LoadForm(xmlDoc, "ForgeUI_VScrollWindow", wndParent, self)

	wndVScrollWindow:FindChild("VScrollButton"):AddEventHandler("WindowMove", "OnVScrollButtonMove", self)
	wndScroll:AddEventHandler("MouseWheel", "OnVScrollMouseWheel", self)

	local tData = {
		wndScroll = wndScroll,
	}

	wndVScrollWindow:SetData(tData)

	return wndVScrollWindow
end

function Gui:OnVScrollButtonMove(wndHandler, wndControl)
	local nLeft, nTop, nRight, nBottom = wndControl:GetAnchorOffsets()

	local tData = wndControl:GetParent():GetParent():GetParent():GetData()

	local nHeight = wndControl:GetHeight()
	local nParentHeight = wndControl:GetParent():GetHeight()

	nLeft = 0
	nRight = 0

	if nTop < 0 then
		nTop = 0
		nBottom = nHeight
	end

	if nBottom > nParentHeight then
		nBottom = nParentHeight
		nTop = nParentHeight - nHeight
	end

	local fPos = nTop / (nParentHeight - nHeight)

	tData.wndScroll:SetVScrollPos(fPos * tData.wndScroll:GetVScrollRange())

	wndControl:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
end

function Gui:OnVScrollMouseWheel(wndHandler, wndControl, nLastRelativeMouseX, nLastRelativeMouseY, fScrollAmount, bConsumeMouseWheel)
	local wndScrollWindow = wndControl:GetParent():FindChild("ForgeUI_VScrollWindow")
	if not wndScrollWindow then return end
	local wndButton = wndScrollWindow:FindChild("VScrollButton")

	local tData = wndButton:GetParent():GetParent():GetParent():GetData()

	local nRange = tData.wndScroll:GetVScrollRange()
	local nPos = tData.wndScroll:GetVScrollPos()

	local nHeight = wndButton:GetHeight()
	local nParentHeight = wndButton:GetParent():GetHeight()

	local nPercent = nPos / nRange

	local nLeft, nTop, nRight, nBottom = wndButton:GetAnchorOffsets()

	nTop = nPercent * nParentHeight
	nBottom = nPercent * nParentHeight + nHeight

	nLeft = 0
	nRight = 0

	if nTop < 0 then
		nTop = 0
		nBottom = nHeight
	end

	if nBottom > nParentHeight then
		nBottom = nParentHeight
		nTop = nParentHeight - nHeight
	end

	wndButton:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
end

_G["ForgeLibs"]["ForgeGUI"] = new(Gui)

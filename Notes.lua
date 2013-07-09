Notes = {}

local addon = ...
local context = UI.CreateContext("Notes")
local notesWindow = UI.CreateFrame("SimpleWindow", "NotesNotesWindow", context)
local textFrame = UI.CreateFrame("Text","NotesTextFrame",notesWindow:GetContent())
local inputFieldScroll = UI.CreateFrame("SimpleScrollView", "NotesInputFieldScroll", textFrame)
local inputField
local closeButton = UI.CreateFrame("RiftButton", "NotesCloseButton", notesWindow)

local function init()
	local windowWidth = 840
	local windowHeight = 600
	
	local windowStartX
	if _editorX then
		windowStartX = _editorX
	else
		windowStartX = 100
	end
	
	local windowStartY
	if _editorY then
		windowStartY = _editorY
	else
		windowStartY = 100
	end

	local edgeGap = 15
	local topGap = 70
	local innerWidth = windowWidth - (edgeGap * 2)
	local innerHeight = windowHeight - ((edgeGap*2) + topGap + closeButton:GetHeight())

	-- create the main notes window
	notesWindow:SetVisible(false)
	notesWindow:SetWidth(windowWidth)
	notesWindow:SetHeight(windowHeight)
	notesWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", windowStartX, windowStartY)
	notesWindow:SetTitle("Notes")
	notesWindow:SetLayer(1)
	notesWindow:SetAlpha(1)

	-- create the text frame to control fonts
	textFrame:SetWidth(innerWidth)
	textFrame:SetHeight(innerHeight)
	textFrame:SetPoint("TOPLEFT", notesWindow, "TOPLEFT", edgeGap, topGap)
	textFrame:SetFontSize(21)

	-- create the text field
	inputFieldScroll:SetWidth(textFrame:GetWidth())
	inputFieldScroll:SetHeight(textFrame:GetHeight())
	inputFieldScroll:SetBorder(1,1,1,1,0.2)
	inputFieldScroll:SetPoint("TOPLEFT", textFrame, "TOPLEFT", 0, 0)
	inputField = UI.CreateFrame("SimpleTextArea", "NotesInputField", inputFieldScroll)
	inputField:SetBackgroundColor(0,0,0,0.5)
	inputField:SetHeight(inputFieldScroll:GetHeight())
	inputField:SetText("")
	inputFieldScroll:SetContent(inputField)

	-- close button
	closeButton:SetLayer(2)
	closeButton:SetText("Close")
	local closeButtonRight = (0-edgeGap*2)
	local closeButtonBottom = (0-edgeGap)-(edgeGap/2)
	closeButton:SetPoint("BOTTOMRIGHT", notesWindow, "BOTTOMRIGHT", closeButtonRight, closeButtonBottom)
	closeButton:SetWidth(100)
	function closeButton.Event:LeftPress()
		Notes.saveAndClose(inputField:GetText())
	end

	-- events
	inputField:EventAttach(Event.UI.Input.Key.Type, Notes.OnKeyType, "KeyType")
end

function Notes.OnKeyType(self, _, key)
	Notes.saveText(inputField:GetText())
end

function Notes.saveAndClose(notesText)
	Notes.saveText(notesText)
	Notes.toggleEditor()
end

function Notes.saveText(notesText)
	_notesText = notesText
end

local function AddonSavedVariablesLoadEnd(handle, identifier)
	if identifier == addon.identifier then
		Command.Event.Detach(Event.Addon.SavedVariables.Load.End, AddonSavedVariablesLoadEnd)
		print('Notes v'..addon.toc.Version..' loaded')
		print('/notes to toggle the notes window')
		init()
	end
end

function Notes.toggleEditor()
	if(notesWindow:GetVisible()) then
        inputField:SetKeyFocus(false)
        Notes.saveText(inputField:GetText())
		
		local x = notesWindow:GetLeft()
		local y = notesWindow:GetTop()

		if x < 0 then
			x = 0
		end

		if y < 0 then
			y = 0
		end

		_editorX = x
		_editorY = y
	else
		local notesText = _notesText
		if(notesText) then
			inputField:SetText(notesText)
        end
    end

    -- toggle the window
    notesWindow:SetVisible(not notesWindow:GetVisible())
end

Command.Event.Attach(Event.Addon.SavedVariables.Load.End, AddonSavedVariablesLoadEnd, "AddonSavedVariablesLoadEnd")
table.insert(Command.Slash.Register("notes"), {Notes.toggleEditor, "Notes", "Slash command"})

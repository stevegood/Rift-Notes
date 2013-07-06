Notes = {}

local context = UI.CreateContext("Notes")
local notesWindow = UI.CreateFrame("SimpleWindow", "NotesNotesWindow", context)
local textFrame = UI.CreateFrame("Text","NotesTextFrame",notesWindow:GetContent())
local inputFieldScroll = UI.CreateFrame("SimpleScrollView", "NotesInputFieldScroll", textFrame)
local inputField = nil

local function init()
	local windowWidth = 840
	local windowHeight = 600
	local windowStartX = 100
	local windowStartY = 100
	local edgeGap = 15
	local topGap = 70
	local innerWidth = windowWidth - (edgeGap * 2)
	local innerHeight = windowHeight - (edgeGap + topGap)

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
	inputField = UI.CreateFrame("RiftTextfield", "NotesInputField", inputFieldScroll)
	inputField:SetBackgroundColor(0,0,0,0.5)
	inputField:SetHeight(inputFieldScroll:GetHeight())
	inputField:SetText("")
	inputFieldScroll:SetContent(inputField)

	function inputField.Event:KeyDown(button)
		local code = string.byte(button)
		local txt = inputField:GetText()
		local pos = inputField:GetCursor()
		-- split txt into two by pos
		local txtPre = string.sub(txt, 0, pos)
		local txtPost = string.sub(txt, pos+1)
		inputField:SetKeyFocus(true) 
		if tonumber(code) == 82 then
			inputField:SetText(txtPre.."\n"..txtPost)
			inputField:SetCursor(pos+1)
		elseif tonumber(code) == 84 then
			inputField:SetText(txtPre.."\t "..txtPost)
			inputField:SetCursor(pos+1)
		end	
		
		-- resize inputField
		_, count = string.gsub(inputField:GetText(), "\r", "\r")
		local t = inputField:GetText()
		inputField:SetHeight(math.max(14*(count), 510))
	end

	function inputField.Event:KeyUp(button)
		_notesText = inputField:GetText()
	end
end

local function showNotes()
	local isOpen = notesWindow:GetVisible()
	if(isOpen) then
		_notesText = inputField:GetText()
		notesWindow:SetVisible(false)
	else
		local notesText = _notesText
		if(notesText) then
			inputField:SetText(notesText)
		end
		notesWindow:SetVisible(true)
	end
end

table.insert(Command.Slash.Register("notes"), {showNotes, "Notes", "Slash command"})

-- initialization
init()
--!strict
--- CONST ---
local PADDING = 5 / 100

--- SERVICES ---
local UserInputService = game:GetService("UserInputService")

--- IMPORTS ---
local Picross = require(game.ReplicatedStorage.Picross)


-- VARS --
local GameGui = game.StarterGui.GameFrame.Frame -- only for types

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local toggleState: Picross.CellValue | "Uncross" = "Marked"
local mouseClicking = false


--- TYPE HEADER ---
-- type aliases
-- types
type PicrossViewObj = {
	puzzle: Picross.Puzzle,
	baseFrame: typeof(GameGui)
}
type PicrossViewImpl = {
	__index: PicrossViewImpl,
	create: (frame: typeof(GameGui), Puzzle: Picross.Puzzle) -> (PicrossView),
	
	createCell: (self: PicrossView, row: number, col: number) -> (),
	removeCell: (self: PicrossView, row: number, col: number) -> (),
	
	getRowClueFrame: (self: PicrossView) -> (typeof(GameGui.RowClueFrame)),
	getColumnClueFrame: (self: PicrossView) -> (typeof(GameGui.ColumnClueFrame)),
	getGridFrame: (self: PicrossView) -> (typeof(GameGui.PuzzleFrame)),
	
	clear: (self: PicrossView) -> (),
	updateCell: (self: PicrossView, row: number, col: number) -> (),
	update: (self: PicrossView, row: number?, col: number?) -> (),
	
	renderClues: (self: PicrossView) -> (),
	renderGrid: (self: PicrossView) -> (),
	render: (self: PicrossView) -> (),
}

export type PicrossView = typeof(setmetatable({} :: PicrossViewObj , {} :: PicrossViewImpl))

--- IMPLEMENTATION ---
local picrossView: PicrossViewImpl = {} :: PicrossViewImpl
picrossView.__index = picrossView
-- STATIC METHODS -
function picrossView.create(frame, puzzle)
	return setmetatable( {
		puzzle = puzzle,
		baseFrame = frame
	} , picrossView)
end

-- CLASS METHODS
function picrossView:getGridFrame()
	return self.baseFrame.PuzzleFrame
end
function picrossView:getRowClueFrame()
	return self.baseFrame.RowClueFrame
end
function picrossView:getColumnClueFrame()
	return self.baseFrame.ColumnClueFrame
end

function picrossView:clear()
	for _, i in self:getGridFrame():GetChildren() do
		if not i:IsA("UIGridLayout") then
			i:Destroy()
		end
	end
end

function picrossView:removeCell(row: number, col: number)
	self:getGridFrame():FindFirstChild(tostring(row * self.puzzle:getGrid():columns() + col)):Destroy()
end

function picrossView:createCell(row: number, col: number)
	local gridLayout = self:getGridFrame().UIGridLayout
	local frame = if self.puzzle:isMarked(row, col) 
			then gridLayout.ACTIVE_TEMPLATE:Clone() 
		else if self.puzzle:isCrossed(row, col) 
			then gridLayout.CROSSED_TEMPLATE:Clone()
			else gridLayout.INACTIVE_TEMPLATE:Clone()
	frame.LayoutOrder = row * self.puzzle:getGrid():columns() + col
	frame.Name = frame.LayoutOrder

	frame.MouseButton1Down:Connect(function()
		self.puzzle:toggle(row, col)
		mouseClicking = true
		toggleState = if self.puzzle:isMarked(row, col) then "Marked" else "Unmarked"
	end)
	frame.MouseEnter:Connect(function()
		if not mouseClicking then return end
		local cellValue: Picross.CellValue = self.puzzle:get(row, col)
		if cellValue == "Unmarked" then
			if toggleState == "Marked" then
				self.puzzle:mark(row, col)
			elseif toggleState == "Crossed" then
				self.puzzle:cross(row, col)
			end
		elseif cellValue == "Crossed" then
			if toggleState == "Uncross" then
				self.puzzle:uncross(row, col)
			end
		elseif cellValue == "Marked" then
			if toggleState == "Unmarked" then
				self.puzzle:unmark(row, col)
			end
		end		
	end)
	frame.MouseButton2Down:Connect(function() 
		self.puzzle:toggleCross(row, col)
		mouseClicking = true
		toggleState = if self.puzzle:isCrossed(row, col) then "Crossed" else "Uncross"
	end)
	frame.MouseButton1Up:Connect(function() mouseClicking = false end)
	frame.MouseButton2Up:Connect(function() mouseClicking = false end)
	
	frame.Parent = self:getGridFrame()
end

function picrossView:renderClues()
	local row = self.puzzle:getGrid():rows()
	local col = self.puzzle:getGrid():columns()
	
	for _, i in self:getRowClueFrame():GetChildren() do
		if not i:IsA("UIGridLayout") then
			i:Destroy()
		end
	end
	for _, i in self:getColumnClueFrame():GetChildren() do
		if not i:IsA("UIGridLayout") then
			i:Destroy()
		end
	end
	
	self:getRowClueFrame().UIGridLayout.CellPadding = UDim2.fromScale(0, PADDING / row)
	self:getRowClueFrame().UIGridLayout.CellSize = UDim2.fromScale(1, (1 - PADDING + PADDING/row)/row)
	local maxClueSize = -1
	for i = 1, row do
		local rowClueAmount = #self.puzzle:getClues().rows[i] 
		if rowClueAmount > maxClueSize then
			maxClueSize = rowClueAmount
		end
	end
	for i = 1, row do
		local colClueAmount = #self.puzzle:getClues().columns[i] 
		if colClueAmount > maxClueSize then
			maxClueSize = colClueAmount
		end
	end
	
	for i = 1, row do
		local clues = self.puzzle:getClues().rows[i]
		local frame = self:getRowClueFrame().UIGridLayout.TEMPLATE:Clone()
		
		local isRowFinished = self.puzzle:isRowSatisfied(i)
		
		frame.UIGridLayout.CellPadding = UDim2.fromScale(PADDING / col, 0)
		frame.UIGridLayout.CellSize = UDim2.fromScale((1 - PADDING + PADDING/maxClueSize)/maxClueSize, 1)

		for ind, clue in clues do
			local clueFrame = frame.UIGridLayout.CLUE_TEMPLATE:Clone()
			
			if isRowFinished then
				clueFrame.TextColor3 = Color3.fromRGB(97, 97, 97)
				clueFrame.UIStroke.Transparency = .4
			end
			
			clueFrame.LayoutOrder = ind
			clueFrame.Text = clue
			
			clueFrame.Parent = frame
		end
		
		frame.Parent = self:getRowClueFrame()
	end
		
	self:getColumnClueFrame().UIGridLayout.CellPadding = UDim2.fromScale(PADDING / col, 0)
	self:getColumnClueFrame().UIGridLayout.CellSize = UDim2.fromScale((1 - PADDING + PADDING/col)/col, 1)
	for i = 1, col do
		local clues = self.puzzle:getClues().columns[i]
		local frame = self:getColumnClueFrame().UIGridLayout.TEMPLATE:Clone()
		
		local isColfinished = self.puzzle:isColumnSatisfied(i)
		
		frame.UIGridLayout.CellPadding = UDim2.fromScale(0, PADDING/row)
		frame.UIGridLayout.CellSize = UDim2.fromScale(1, (1 - PADDING + PADDING/maxClueSize)/maxClueSize)
		
		for ind, clue in clues do
			local clueFrame = frame.UIGridLayout.CLUE_TEMPLATE:Clone()
			
			if isColfinished then
				clueFrame.TextColor3 = Color3.fromRGB(100,100,100)
				clueFrame.UIStroke.Transparency = .4
			end

			clueFrame.LayoutOrder = ind
			clueFrame.Text = clue

			clueFrame.Parent = frame
		end

		frame.Parent = self:getColumnClueFrame()
	end
end

function picrossView:renderGrid()
	self:clear()
	local gridLayout = self:getGridFrame().UIGridLayout
	
	local row = self.puzzle:getGrid():rows()
	local col = self.puzzle:getGrid():columns()
	
	gridLayout.CellPadding = UDim2.fromScale(PADDING / col, PADDING / row)
	gridLayout.CellSize = UDim2.fromScale((1 - PADDING + PADDING/col)/col, (1 - PADDING + PADDING/row)/row)


	for i = 1, row do
		for j = 1, col do		
			self:createCell(i, j)
		end
	end
end

function picrossView:render()
	self:renderGrid()
	self:renderClues()
end

function picrossView:update(row, column)
	if row and column then
		self:updateCell(row, column)
		self:renderClues() -- TODO make this take row and columns as args
	else
		self:render()
	end
end
function picrossView:updateCell(row, col)
	self:removeCell(row, col)
	self:createCell(row, col)
end

mouse.Button1Up:Connect(function() 
	mouseClicking = false
end)
mouse.Button2Up:Connect(function() 
	mouseClicking = false
end)

return picrossView
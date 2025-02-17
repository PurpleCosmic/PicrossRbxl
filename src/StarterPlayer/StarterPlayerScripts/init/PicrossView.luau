--!strict
--- CONST ---
local PADDING = 5 / 100

-- VARS --
local GameGui = game.StarterGui.GameFrame.Frame -- only for types

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local toggleState: Picross.CellValue | "Uncross" = "Marked"
local mouseClicking = false

--- SERVICES ---
local UserInputService = game:GetService("UserInputService")

--- IMPORTS ---
local Picross = require(game.ReplicatedStorage.Picross)
local GridView = require(player.PlayerScripts.init.GridView)

--- TYPE HEADER ---
-- type aliases
-- types
type PicrossViewObj = {
	puzzle: Picross.Puzzle,
	gridView: GridView.GridView<Picross.CellValue>,
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
	local gridFrame = frame.baseFrame.PuzzleFrame
	local function setupCellController(row: number, col: number)
		frame.MouseButton1Down:Connect(function()
			puzzle:toggle(row, col)
			mouseClicking = true
			toggleState = if puzzle:isMarked(row, col) then "Marked" else "Unmarked"
		end)
		frame.MouseEnter:Connect(function()
			if not mouseClicking then return end
			local cellValue: Picross.CellValue = puzzle:get(row, col)
			if cellValue == "Unmarked" then
				if toggleState == "Marked" then
					puzzle:mark(row, col)
				elseif toggleState == "Crossed" then
					puzzle:cross(row, col)
				end
			elseif cellValue == "Crossed" then
				if toggleState == "Uncross" then
					puzzle:uncross(row, col)
				end
			elseif cellValue == "Marked" then
				if toggleState == "Unmarked" then
					puzzle:unmark(row, col)
				end
			end		
		end)
		frame.MouseButton2Down:Connect(function() 
			puzzle:toggleCross(row, col)
			mouseClicking = true
			toggleState = if puzzle:isCrossed(row, col) then "Crossed" else "Uncross"
		end)
		frame.MouseButton1Up:Connect(function() mouseClicking = false end)
		frame.MouseButton2Up:Connect(function() mouseClicking = false end)
	end

	return setmetatable( {
		puzzle = puzzle,
		gridView = GridView.create(gridFrame, puzzle.grid, {
			["Marked"] = function(row, col)
				local frame = gridFrame.UIGridLayout.ACTIVE_TEMPLATE:Clone()
				setupCellController(row, col)
				return frame
			end,
			["Unmarked"] = function(row, col)
				local frame = gridFrame.UIGridLayout.INACTIVE_TEMPLATE:Clone()
				setupCellController(row, col)
				return frame
			end,
			["Crossed"] = function(row, col)
				local frame = gridFrame.UIGridLayout.CROSSED_TEMPLATE:Clone()
				setupCellController(row, col)
				return frame
			end
		}, {padding = PADDING}),
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
	self.gridView:render()
end

function picrossView:render()
	self:renderGrid()
	self:renderClues()
end

function picrossView:update(row, column)
	if row and column then
		self.gridView:update(row, column)
		self:renderClues() -- TODO make this take row and columns as args
	else
		self:render()
	end
end

mouse.Button1Up:Connect(function()
	mouseClicking = false
end)
mouse.Button2Up:Connect(function()
	mouseClicking = false
end)

return picrossView
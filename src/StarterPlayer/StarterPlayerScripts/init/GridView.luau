--!strict
--- CONST ---

--- SERVICES ---
--- IMPORTS ---
local Grid = require(game.ReplicatedStorage.Grid)


-- VARS --
--- TYPE HEADER ---
-- type aliases
type ValueMap<T> = {[T]: GuiBase2d | (row: number, col: number) -> (GuiBase2d)}

-- types
type GridViewObj<T> = {
    grid: Grid.Grid<T>,
    valueMap: ValueMap<T>,
    padding: number,
	baseFrame: Frame
}
type GridViewImpl<T> = {
	__index: GridViewImpl<T>,
	create: (frame: Frame, grid: Grid.Grid<T>, valueMap: ValueMap<T>, props: {padding: number?}? ) -> (GridView<T>),
	
	createCell: (self: GridView<T>, row: number, col: number) -> (),
	removeCell: (self: GridView<T>, row: number, col: number) -> (),
	
	getGridFrame: (self: GridView<T>) -> (Frame),
	
	clear: (self: GridView<T>) -> (),
	updateCell: (self: GridView<T>, row: number, col: number) -> (),
	update: (self: GridView<T>, row: number?, col: number?) -> (),
	
    render: (self: GridView<T>) -> (),
}

export type GridView<T> = typeof(setmetatable({} :: GridViewObj<T> , {} :: GridViewImpl<T>))

--- IMPLEMENTATION ---
local gridView: GridViewImpl<any> = {} :: GridViewImpl<any>
gridView.__index = gridView
-- STATIC METHODS -
function gridView.create(frame, grid, frameDict, props)
	return setmetatable( {
		grid = grid,
        frameDict = frameDict,
        padding = (props and props.padding or 0),
		baseFrame = frame
	} , gridView)
end

-- CLASS METHODS
function gridView:getGridFrame()
	return self.baseFrame.PuzzleFrame
end

function gridView:clear()
	for _, i in self:getGridFrame():GetChildren() do
		if not i:IsA("UIGridLayout") then
			i:Destroy()
		end
	end
end

function gridView:removeCell(row: number, col: number)
	self:getGridFrame():FindFirstChild(tostring(row * self.grid:columns() + col)):Destroy()
end

function gridView:createCell(row: number, col: number)
	local gridLayout = self:getGridFrame().UIGridLayout

    local valueFrame = self.valueMap[self.grid:get(row, col)]
	local frame = if typeof(valueFrame) == "Instance" then valueFrame:Clone() else valueFrame(row, col)
    frame.LayoutOrder = row * self.grid:columns() + col
	frame.Name = frame.LayoutOrder
	
	frame.Parent = self:getGridFrame()
end

function gridView:render()
	self:clear()
	
	local row = self.grid:rows()
	local col = self.grid:columns()
	
	local gridLayout = self:getGridFrame().UIGridLayout
	gridLayout.CellPadding = UDim2.fromScale(self.padding / col, self.padding / row)
	gridLayout.CellSize = UDim2.fromScale((1 - self.padding + self.padding/col)/col, (1 - self.padding + self.padding/row)/row)

	for i = 1, row do
		for j = 1, col do		
			self:createCell(i, j)
		end
	end
end

function gridView:update(row, column)
	if row and column then
		self:updateCell(row, column)
	else
		self:render()
	end
end
function gridView:updateCell(row, col)
	self:removeCell(row, col)
	self:createCell(row, col)
end

return gridView
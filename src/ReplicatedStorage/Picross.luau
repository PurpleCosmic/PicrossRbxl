--!strict
--- IMPORTS ---
local Grid = require(game.ReplicatedStorage.Grid)
local TableUtil = require(game.ReplicatedStorage.TableUtil)

--- TYPE HEADER ---
-- type aliases
type Grid<T> = Grid.Grid<T>
export type CellValue = "Marked" | "Unmarked" | "Crossed"
type Listener = {
	update: (self: any, number?, number?) -> (),
	[any]: any
}

-- types
export type Clues = {
	rows: { {number} },
	columns: { {number} }
}
type PuzzleObj = {
	grid: Grid.Grid<CellValue>,
	clues: Clues,
	solvedGrid: Grid.Grid<CellValue>?,

	listeners: { Listener }
}

type PuzzleImpl = {
	__index: PuzzleImpl,

	createClues: (grid: Grid<CellValue>) -> (Clues),

	fromClues: (clues: Clues) -> (Puzzle),
	fromBoolGrid: (grid: Grid<boolean>) -> (Puzzle),
	fromGrid: (grid: Grid<CellValue>) -> (Puzzle),

	getGrid: (self: Puzzle) -> (Grid<CellValue>),
	getClues: (self: Puzzle) -> (Clues),

	set: (self: Puzzle, row: number, column: number, value: CellValue) -> (Puzzle),
	get: (self: Puzzle, row: number, column: number) -> (CellValue),

	isMarked: (self: Puzzle, row: number, column: number) -> (boolean),
	mark: (self: Puzzle, row: number, column: number) -> (Puzzle),
	unmark: (self: Puzzle, row: number, column: number) -> (Puzzle),
	toggle: (self: Puzzle, row: number, column: number) -> (Puzzle),

	isCrossed: (self: Puzzle, row: number, column: number) -> (boolean),
	cross: (self: Puzzle, row: number, column: number) -> (Puzzle),
	uncross: (self: Puzzle, row: number, column: number) -> (Puzzle),
	toggleCross: (self: Puzzle, row: number, column: number) -> (Puzzle),

	isSolved: (self: Puzzle) -> (boolean),

	isRowSatisfied: (self: Puzzle, row: number) -> (boolean),
	isColumnSatisfied: (self: Puzzle, column: number) -> (boolean),

	addListener: (self: Puzzle, listener: any) -> (),
	updateListeners: (self: Puzzle) -> (),
}
export type Puzzle = typeof(setmetatable({} :: PuzzleObj, {} :: PuzzleImpl))

--- IMPLEMENTATION ---
local puzzle: PuzzleImpl = {} :: PuzzleImpl
puzzle.__index = puzzle

-- STATIC METHODS --
local function getPredClues(n: number, pred: (number) -> (boolean))
	local clues = {}
	local checkIndex = 1

	local len = 0
	local counting = false
	for i = checkIndex, n do
		if pred(i) then
			counting = true
			len += 1
		elseif counting then
			table.insert(clues, len)
			checkIndex = i
			counting = false
			len = 0
		end
	end
	if #clues == 0 or counting == true then table.insert(clues, len) end

	return clues
end

local function getRowClues(grid: Grid<CellValue>, row: number): { number }
	return getPredClues(grid:columns(), function(i) return grid:get(row, i) == "Marked" end)
end
local function getColClues(grid: Grid<CellValue>, col: number): { number }
	return getPredClues(grid:rows(), function(i) return grid:get(i, col) == "Marked" end)
end

function puzzle.createClues(grid: Grid<CellValue>)
	local clues = {rows = table.create(grid:rows()), columns = table.create(grid:columns())}
	for i = 1, grid:rows() do
		table.insert(clues.rows, getRowClues(grid, i))
	end
	for i = 1, grid:columns() do
		table.insert(clues.columns, getColClues(grid, i))
	end
	return clues
end

function puzzle.fromBoolGrid(grid): Puzzle
	local tbl: { { CellValue } } = {}
	for i = 1, grid:rows() do
		tbl[i] = {}
		for j = 1, grid:columns() do
			tbl[i][j] = if grid:get(i, j) == true then "Marked" else "Unmarked"
		end
	end

	local cellGrid = Grid.fromTable(tbl)

	local self = {
		grid = Grid.constructEmptyGrid(grid:rows(), grid:columns(), "Unmarked"),
		solvedGrid = cellGrid,
		clues = puzzle.createClues(cellGrid),
		listeners = {}
	}

	return setmetatable(self, puzzle)
end

function puzzle.fromGrid(grid): Puzzle
	local self = {
		grid = Grid.constructEmptyGrid(grid:rows(), grid:columns(), "Unmarked"),
		solvedGrid = grid,
		clues = puzzle.createClues(grid),
		listeners = {}
	}

	return setmetatable(self, puzzle)
end
function puzzle.fromClues(clues: Clues): Puzzle
	local self = {
		solvedGrid = nil,
		grid = Grid.constructEmptyGrid(#clues.rows, #clues.columns, "Unmarked"),
		clues = clues,
		listeners = {}
	}

	return setmetatable(self, puzzle)
end

-- CLASS METHODS --
function puzzle:getClues() 	return self.clues end
function puzzle:getGrid(): Grid<CellValue> 	return self.grid end
function puzzle:get(row, col) return self:getGrid():get(row, col) end

function puzzle:isMarked(row, col)  return self:get(row, col) == "Marked" end
function puzzle:set(row, column, value: CellValue) 
	self.grid:set(row, column, value)
	self:updateListeners()
	return self
end
function puzzle:mark(row, column) return self:set(row, column, "Marked") end
function puzzle:unmark(row, column)	return self:set(row, column, "Unmarked") end
function puzzle:toggle(row, col)
	if self:isMarked(row, col) then
		self:unmark(row, col)
	elseif not self:isCrossed(row, col) then
		self:mark(row, col)
	end
	return self
end

function puzzle:isCrossed(row, col) return self:get(row, col) == "Crossed" end
function puzzle:cross(row, column) 	return self:set(row, column, "Crossed") end
function puzzle:uncross(row, column) return self:set(row, column, "Unmarked") end
function puzzle:toggleCross(row, column)
	if self:isCrossed(row, column) then
		self:uncross(row, column)
	elseif not self:isMarked(row, column) then
		self:cross(row, column)
	end
	self:updateListeners()
	return self
end

function puzzle:isRowSatisfied(row) return TableUtil.deepEqual(self:getClues().rows[row], getRowClues(self:getGrid(), row)) end
function puzzle:isColumnSatisfied(column) return TableUtil.deepEqual(self:getClues().columns[column], getColClues(self:getGrid(), column)) end

function puzzle:isSolved(): boolean
	for i = 1, self.grid:rows() do
		if not self:isRowSatisfied(i) then
			return false
		end
	end
	for i = 1, self.grid:columns() do
		if not self:isColumnSatisfied(i) then
			return false
		end
	end	
	return true
end

function puzzle:addListener(listener)
	if listener.update ~= nil then
		table.insert(self.listeners, listener)
	else
		warn("Tried to add listener that is not listener")
	end
end

function puzzle:updateListeners()
	for _, i in self.listeners do
		i:update()
	end
end

return puzzle
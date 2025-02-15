--!strict
type GridObj<T> = {
	grid: {[number]: {
		T
	}},
}

type GridImpl<T> = {
	__index: GridImpl<T>,
	__tostring: (self: Grid<T>) -> (string),
	

	fromTable: (tbl: {{T}}) -> (Grid<T>),
	constructEmptyGrid: (rows: number, columns: number, defaultValue: T?) -> (Grid<T>),
	
	set: (self: Grid<T>, row: number, column: number, value: T) -> (),
	get: (self: Grid<T>, row: number, column: number) -> (T),
	
	rows: (self: Grid<T>) -> (number),
	columns: (self: Grid<T>) -> (number),
}

export type Grid<T> = typeof(setmetatable({} :: GridObj<T> , {} :: GridImpl<T>))

local grid: GridImpl<any> = {} :: GridImpl<any>
grid.__index = grid
grid.__tostring = function(self)
	local str = "{\n"
	for i = 1, #self.grid do
		for j = 1, #self.grid[i] do
			str ..= tostring(self.grid[i][j]).." "
		end
		str ..= "\n"
	end
	str ..= "}"
	return str
end


function grid.constructEmptyGrid<T>(rows, columns, defaultValue): Grid<T>
	local self = {}
	
	local tbl = {}
	for i = 1, rows do
		table.insert(tbl, table.create(columns, defaultValue))
	end
	self.grid = tbl
	
	return setmetatable(self, grid)
end

function grid.fromTable<T>(tbl): Grid<T>
	return setmetatable({grid = tbl}, grid)
end

function grid:set(row, column, value)
	self.grid[row][column] = value
end

function grid:get(row, column)
	return self.grid[row][column]
end

function grid:rows()
	return #self.grid
end

function grid:columns()
	return #self.grid[1]
end

return grid
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Grid = require(script.Parent:WaitForChild("Grid"))
local Picross = require(script.Parent:WaitForChild("Picross"))

local random = Random.new(1234)

export type Picross = {
	Title: string,
	Picross: Picross.Puzzle
}

local function generateRandomBoolTable(rows: number, columns: number, density: number): {{boolean}}
	local res = table.create(rows)
	for r = 1, rows do
		local row = table.create(columns)
		for c = 1, columns do
			row[c] = random:NextNumber() < density
		end
		table.insert(res, row)
	end
	return res
end

local module = {
	{
		Title = "Lines",
		Picross = Picross.fromClues(Picross.fromBoolGrid(Grid.fromTable({
			{true, 	true, 	true},
			{false, false, 	false},
			{true,	true, 	true}
		})).clues)
	},
	{
		Title = "Cross",
		Picross = Picross.fromClues(Picross.fromBoolGrid(Grid.fromTable({
			{true,	false, 	true},
			{false, false, 	false},
			{true, 	false, 	true}
		})).clues)
	},
	{
		Title = "Random 10x10",
		Picross = Picross.fromClues(Picross.fromBoolGrid(Grid.fromTable(generateRandomBoolTable(10, 10, .8))).clues)
	},
	{
		Title = "Random 15x15",
		Picross = Picross.fromClues(Picross.fromBoolGrid(Grid.fromTable(generateRandomBoolTable(15, 15, .8))).clues)
	},
	{
		Title = "Random 11x11",
		Picross = Picross.fromClues(Picross.fromBoolGrid(Grid.fromTable(generateRandomBoolTable(11 , 11, .8))).clues)
	},
	{
		Title = "Random 10x10 2",
		Picross = Picross.fromClues(Picross.fromBoolGrid(Grid.fromTable(generateRandomBoolTable(10, 10, .75))).clues)
	},
	{
		Title = "Random 10x10 3",
		Picross = Picross.fromClues(Picross.fromBoolGrid(Grid.fromTable(generateRandomBoolTable(10, 10, .75))).clues)
	},
}

return module

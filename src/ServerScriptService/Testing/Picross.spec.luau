local TableUtil = require(game.ReplicatedStorage.TableUtil)

return function() 
	local Grid = require(game.ReplicatedStorage.Grid)
	local Picross = require(game.ReplicatedStorage.Picross)

	local puzzle;
	local testClues2x2 = {
		columns = { {1}, {0} },
		rows = { 
			{1}, 
			{0} },
	}
	local testClues3x3 = {
		columns = { {1,1}, {0}, {0} },
		rows = { 
			{1}, 
			{0}, 
			{1} },
	}

	describe("fromClues", function()

		describe("2x2", function ()
			beforeEach(function()
				puzzle = Picross.fromClues(testClues2x2)
			end)

			do -- non-specific
				it (`should say a new puzzle created from a non-empty clue grid is unsolved in a 2x2`, function() 
					expect(puzzle:isSolved()).to.equal(false)
				end)

				it (`should set a cell to true when marking 2x2`, function() 
					puzzle:mark(1, 1)
					expect(puzzle:get(1, 1)).to.equal("Marked")
					expect(puzzle:get(2, 2)).to.equal("Unmarked")
					puzzle:mark(2, 2)
					expect(puzzle:get(2, 2)).to.equal("Marked")
				end)

				it (`methods :mark() and :unmark() should be inverse to each other in a 2x2`, function() 
					puzzle:mark(2, 1)
					expect(puzzle:get(2, 1)).to.equal("Marked")
					puzzle:unmark(2, 1)
					expect(puzzle:get(2, 1)).to.equal("Unmarked")

					puzzle:mark(2,1):unmark(2,1)
					expect(puzzle:get(2, 1)).to.equal("Unmarked")
				end)
			end

			it ("should say it is solved upon solving in a 2x2", function() 
				expect(puzzle:isSolved()).to.equal(false)				
			end)
		end)



		describe("3x3", function ()
			beforeEach(function()
				puzzle = Picross.fromClues(testClues3x3)
			end)

			it ("should say it is solved upon solving a 3x3", function() 
				expect(puzzle:isSolved()).to.equal(false)
				expect(puzzle:mark(1,1):mark(3,1):isSolved()).to.equal(true)
			end)

			do -- non-specific tests
				it (`should say a new puzzle created from a non-empty clue grid is unsolved in a 3x3`, function() 
					expect(puzzle:isSolved()).to.equal(false)
				end)

				it (`should set a cell to true when marking in a 3x3`, function() 
					puzzle:mark(1, 1)
					expect(puzzle:get(1, 1)).to.equal("Marked")
					expect(puzzle:get(2, 2)).to.equal("Unmarked")
					puzzle:mark(2, 2)
					expect(puzzle:get(2, 2)).to.equal("Marked")
				end)

				it (`methods :mark() and :unmark() should be inverse to each other in a 3x3`, function() 
					puzzle:mark(2, 1)
					expect(puzzle:get(2, 1)).to.equal("Marked")
					puzzle:unmark(2, 1)
					expect(puzzle:get(2, 1)).to.equal("Unmarked")

					puzzle:mark(2,1):unmark(2,1)
					expect(puzzle:get(2, 1)).to.equal("Unmarked")
				end)
			end
		end)
	end)

	describe("fromGrid", function() 
		it ("should construct the correct clues given when calling Picross.fromGrid (1)", function()
			local grid = Grid.constructEmptyGrid(2, 2, false)
			grid:set(1, 1, true) -- x o
			grid:set(2, 1, true) -- x o
			puzzle = Picross.fromBoolGrid(grid)
			TableUtil.assertEq({ rows = {{1}, {1}}, columns = { {2}, {0} } }, puzzle:getClues())
		end)
		
		it ("should construct the correct clues given when calling Picross.fromGrid (2)", function()
			local grid = Grid.constructEmptyGrid(2, 2, false)
			puzzle = Picross.fromBoolGrid(grid)
			TableUtil.assertEq({ rows = {{0}, {0}}, columns = { {0}, {0} } }, puzzle:getClues())
		end)

		it ("should construct the correct clues given when calling Picross.fromGrid (3)", function()
			local grid = Grid.constructEmptyGrid(2, 2, false)
			grid:set(1, 1, true)
			puzzle = Picross.fromBoolGrid(grid)
			TableUtil.assertEq({ rows = {{1}, {0}}, columns = { {1}, {0} } }, puzzle:getClues())
		end)
		
		it ("should construct the correct clues given when calling Picross.fromGrid (4)", function()
			local grid = Grid.constructEmptyGrid(2, 2, false)
			grid:set(1, 1, true)
			grid:set(2, 2, true)
			puzzle = Picross.fromBoolGrid(grid)
			TableUtil.assertEq({ rows = {{1}, {1}}, columns = { {1}, {1} } }, puzzle:getClues())
		end)
		
		it ("should create a solved puzzle when constructing from grid", function() 
			puzzle = Picross.fromBoolGrid(Grid.fromTable({
				{false, true},
				{true, true}
			}))
			expect(puzzle:isSolved()).to.equal(true)
			
			puzzle = Picross.fromBoolGrid(Grid.fromTable({
				{false, true, false},
				{true, true, false},
				{false, false, false}
			}))
			expect(puzzle:isSolved()).to.equal(true)

			puzzle = Picross.fromBoolGrid(Grid.fromTable({
				{true, false, false},
				{false, false, false},
				{true, false, false}
			}))
			expect(puzzle:isSolved()).to.equal(true)
		end)		
	end)
end


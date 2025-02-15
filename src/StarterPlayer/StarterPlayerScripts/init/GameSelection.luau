--!strict
--- IMPORTS ---
local Players = game:GetService("Players")
local Puzzles = require(game:GetService("ReplicatedStorage"):WaitForChild("Puzzles"))
local PicrossView = require(script.Parent:WaitForChild("PicrossView"))

--- FIELDS ---
-- CONSTANTS
local PUZZLES_PER_PAGE = 6

-- PUBLIC VARIABLES
-- PRIVATE VARIABLES
local player = Players.LocalPlayer
local SelectionMenu = player.PlayerGui:WaitForChild("SelectionMenu")
local SelectionList = SelectionMenu.Selection
local page = 1

local displayedList: {Puzzles.Picross}

--- TYPE HEADER ---
-- type aliases
-- types



--- IMPLEMENTATION ---
local module = {}
SelectionList.BackgroundTransparency = 1

module.Clear = function()
	for _, frame in SelectionList:GetChildren() do
		if not frame:IsA("UIGridLayout") and not frame:IsA("UIListLayout") then
			frame:Destroy()
		end
	end
end
module.Hide = function()
	SelectionMenu.Enabled = false
end
module.Show = function() 
	SelectionMenu.Enabled = true
end

local function getMaxPage() return (#displayedList-1)//PUZZLES_PER_PAGE + 1  end

module.Update = function()
	module.Clear()
	SelectionMenu.PageController.PageLabel.Text = page
	SelectionMenu.PageController.Left.Visible = page > 1
	SelectionMenu.PageController.Right.Visible = page < getMaxPage()
	
	for i = (page-1) * PUZZLES_PER_PAGE, page * PUZZLES_PER_PAGE do
		local puzzle = displayedList[i]
		if puzzle then
			local frame = SelectionList.UIGridLayout.TEMPLATE:Clone()
			frame.Text = puzzle.Title
			frame.Parent = SelectionList

			local p = PicrossView.create(player.PlayerGui.GameFrame.Frame, puzzle.Picross)
			puzzle.Picross:addListener(p)
			frame.MouseButton1Click:Connect(function()
				module.Hide()
				p:render()
				player.PlayerGui.GameFrame.Enabled = true

				player.PlayerGui.GameFrame.BackButton.MouseButton1Click:Connect(function() 
					player.PlayerGui.GameFrame.Enabled = false
					module.Show()
				end)
			end)	
		end	
	end
end
module.Display = function(list: {Puzzles.Picross}?)
	if list ~= nil then
		displayedList = list
	end
	module.Update()
	module.Show()
end

module.NextPage = function()
	page = math.min( getMaxPage() , page + 1)
	module.Update()
end
module.PreviousPage = function() 
	page = math.max(page - 1, 1)
	module.Update()
end

SelectionMenu.PageController.Left.MouseButton1Click:Connect(module.PreviousPage)
SelectionMenu.PageController.Right.MouseButton1Click:Connect(module.NextPage)

module.Reset = function()
	module.Clear()
	page = 1
end

return module

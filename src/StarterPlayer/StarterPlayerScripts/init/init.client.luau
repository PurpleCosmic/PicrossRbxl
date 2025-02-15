--!strict
local Players = game:GetService("Players")
local Puzzles = require(game:GetService("ReplicatedStorage"):WaitForChild("Puzzles"))
local GameSelection = require(script:WaitForChild("GameSelection"))
local Grid = require(game.ReplicatedStorage.Grid)
local Picross = require(game.ReplicatedStorage.Picross)
local PicrossView = require(script.PicrossView)
local GameSeleciton = require(script.GameSelection)

local player = Players.LocalPlayer

local MainMenu = player.PlayerGui:WaitForChild("MainMenu")
local GameMenu = player.PlayerGui:WaitForChild("GameFrame")

GameMenu.Enabled = false
GameSelection.Hide()

MainMenu.Enabled = true
MainMenu.StartButton.MouseButton1Click:Connect(function() 
	MainMenu.Enabled = false
	GameSelection.Display(Puzzles)
end)
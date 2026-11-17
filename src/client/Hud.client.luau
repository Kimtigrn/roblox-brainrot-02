-- Tsunami Brainrot HUD: money, income, the wave countdown, the carried catch,
-- the owned count, the egg buttons and the rebirth button. Everything sits
-- clear of the top-left corner, where Roblox puts its own menu buttons.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local remotes = ReplicatedStorage:WaitForChild("BrainrotRemotes")
local StateChanged = remotes:WaitForChild("StateChanged")
local WaveChanged = remotes:WaitForChild("WaveChanged")
local Notify = remotes:WaitForChild("Notify")
local HatchEgg = remotes:WaitForChild("HatchEgg")
local DoRebirth = remotes:WaitForChild("DoRebirth")

local gui = Instance.new("ScreenGui")
gui.Name = "TsunamiHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local function makeLabel(name, text, size, position)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Text = text
	label.Size = size
	label.Position = position
	label.BackgroundColor3 = Color3.new(0, 0, 0)
	label.BackgroundTransparency = 0.4
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.Parent = gui
	return label
end

-- Top right: money and income. Top center: the wave banner.
local moneyLabel = makeLabel("Money", "$0", UDim2.new(0, 220, 0, 44), UDim2.new(1, -230, 0, 10))
local incomeLabel = makeLabel("Income", "+$0/s", UDim2.new(0, 220, 0, 30), UDim2.new(1, -230, 0, 58))
local waveLabel = makeLabel("Wave", "WAVE IN 0:45", UDim2.new(0, 360, 0, 44), UDim2.new(0.5, -180, 0, 10))
local carriedLabel = makeLabel("Carried", "Hands empty - go catch a brainrot!", UDim2.new(0, 560, 0, 40), UDim2.new(0.5, -280, 1, -50))
local ownedLabel = makeLabel("Owned", "Owned: 0 brainrots", UDim2.new(0, 200, 0, 36), UDim2.new(1, -210, 1, -46))

local notifyLabel = makeLabel("Notify", "", UDim2.new(0, 560, 0, 40), UDim2.new(0.5, -280, 0, 120))
notifyLabel.BackgroundTransparency = 1
notifyLabel.TextColor3 = Color3.fromRGB(255, 220, 80)

local function makeButton(name, text, yOffset, color)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.Size = UDim2.new(0, 230, 0, 40)
	button.Position = UDim2.new(0, 10, 1, yOffset)
	button.BackgroundColor3 = color
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Font = Enum.Font.SourceSansBold
	button.Parent = gui
	return button
end

local eggButton = makeButton("EggButton", "Hatch Egg - $100", -170, Color3.fromRGB(40, 120, 200))
local goldenEggButton = makeButton("GoldenEggButton", "Golden Egg - $500", -125, Color3.fromRGB(200, 150, 40))
local godEggButton = makeButton("GodEggButton", "God Egg - $2,000", -80, Color3.fromRGB(180, 40, 40))
local rebirthButton = makeButton("RebirthButton", "Rebirth - $5,000 + 5 owned", -215, Color3.fromRGB(40, 160, 80))

local function showEggResult(result)
	if result.Error then
		notifyLabel.Text = result.Error
	else
		notifyLabel.Text = "Hatched " .. result.Name .. " (" .. result.Rarity .. ")!"
	end
	task.delay(3, function()
		notifyLabel.Text = ""
	end)
end

eggButton.MouseButton1Click:Connect(function()
	showEggResult(HatchEgg:InvokeServer("Egg"))
end)
goldenEggButton.MouseButton1Click:Connect(function()
	showEggResult(HatchEgg:InvokeServer("GoldenEgg"))
end)
godEggButton.MouseButton1Click:Connect(function()
	showEggResult(HatchEgg:InvokeServer("GodEgg"))
end)
rebirthButton.MouseButton1Click:Connect(function()
	local ok = DoRebirth:InvokeServer()
	if not ok then
		notifyLabel.Text = "Rebirth needs more money and brainrots!"
		task.delay(3, function()
			notifyLabel.Text = ""
		end)
	end
end)

StateChanged.OnClientEvent:Connect(function(state)
	moneyLabel.Text = "$" .. tostring(state.Money)
	incomeLabel.Text = "+$" .. tostring(state.Income) .. "/s"
	ownedLabel.Text = "Owned: " .. tostring(state.Owned) .. " brainrots"
	if state.Carried then
		carriedLabel.Text = "Carrying: " .. state.Carried.Name .. " (" .. state.Carried.Rarity .. ") - $" .. tostring(state.Carried.TotalRate) .. "/s - DASH HOME!"
	else
		carriedLabel.Text = "Hands empty - go catch a brainrot!"
	end
	rebirthButton.Text = "Rebirth - x" .. tostring(1 + 0.5 * state.Rebirths) .. " income"
end)

WaveChanged.OnClientEvent:Connect(function(phase, countdown)
	if phase == "Calm" then
		waveLabel.Text = "WAVE IN 0:" .. string.format("%02d", countdown)
		waveLabel.BackgroundColor3 = Color3.new(0, 0, 0)
	elseif phase == "Warning" then
		waveLabel.Text = "WAVE IN 0:0" .. tostring(countdown) .. " - GET READY!"
		waveLabel.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
	else
		waveLabel.Text = "TSUNAMI! RUN HOME!"
		waveLabel.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
	end
end)

Notify.OnClientEvent:Connect(function(text)
	notifyLabel.Text = text
	task.delay(3, function()
		notifyLabel.Text = ""
	end)
end)

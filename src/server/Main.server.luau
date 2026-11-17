-- Tsunami Brainrot, server entry: wires the remotes, starts the brainrot
-- spawner, the wave and the one-second tick that pays every player their
-- income and banks a carried brainrot the moment its owner reaches the base.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local BrainrotData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotData"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local Spawner = require(script.Parent:WaitForChild("BrainrotSpawner"))
local WaveController = require(script.Parent:WaitForChild("WaveController"))
local EggMachine = require(script.Parent:WaitForChild("EggMachine"))

local remotes = Instance.new("Folder")
remotes.Name = "BrainrotRemotes"
remotes.Parent = ReplicatedStorage

local StateChanged = Instance.new("RemoteEvent")
StateChanged.Name = "StateChanged"
StateChanged.Parent = remotes

local WaveChanged = Instance.new("RemoteEvent")
WaveChanged.Name = "WaveChanged"
WaveChanged.Parent = remotes

local Notify = Instance.new("RemoteEvent")
Notify.Name = "Notify"
Notify.Parent = remotes

local HatchEgg = Instance.new("RemoteFunction")
HatchEgg.Name = "HatchEgg"
HatchEgg.Parent = remotes

local DoRebirth = Instance.new("RemoteFunction")
DoRebirth.Name = "DoRebirth"
DoRebirth.Parent = remotes

local function sendState(player)
	local state = PlayerData.get(player)
	if not state then
		return
	end
	StateChanged:FireClient(player, {
		Money = math.floor(state.Money),
		Income = math.floor(PlayerData.incomePerSecond(player)),
		Owned = #state.Owned,
		Carried = state.Carried,
		Rebirths = state.Rebirths,
	})
end

local function notify(player, text)
	Notify:FireClient(player, text)
end

local function onCaughtOutside(player)
	local state = PlayerData.get(player)
	if state and state.Carried then
		local lost = PlayerData.clearCarried(player)
		notify(player, "The wave took your " .. lost.Name .. "!")
		sendState(player)
	end
end

local function inSafeZone(position)
	return position.Z < -100 and math.abs(position.X) < 45
end

-- Banks a carried brainrot the moment its owner steps onto the safe base.
local function bankCarriedIfHome(player)
	local state = PlayerData.get(player)
	if not state or not state.Carried then
		return
	end
	local character = player.Character
	if not character then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root or not inSafeZone(root.Position) then
		return
	end
	local placed = state.Carried
	PlayerData.addOwned(player, placed)
	PlayerData.clearCarried(player)
	notify(player, placed.Name .. " is safe on your base! +$" .. tostring(placed.TotalRate) .. "/s")
end

Players.PlayerAdded:Connect(function(player)
	PlayerData.newPlayer(player)
	task.wait(1)
	sendState(player)
end)

Players.PlayerRemoving:Connect(function(player)
	PlayerData.wipe(player)
end)

HatchEgg.OnServerInvoke = function(player, eggType)
	local result, err = EggMachine.hatch(player, eggType, PlayerData)
	if result then
		notify(player, "Hatched " .. result.Name .. " (" .. result.Rarity .. ")!")
		sendState(player)
		return result
	end
	return { Error = err }
end

DoRebirth.OnServerInvoke = function(player)
	if PlayerData.doRebirth(player) then
		local state = PlayerData.get(player)
		notify(player, "Rebirth! Your income is now x" .. tostring(1 + BrainrotData.REBIRTH.Bonus * state.Rebirths))
		sendState(player)
		return true
	end
	return false
end

-- The signs on the base are plain parts in the place; their lettering is
-- built here at runtime, so the island reads clearly in the game.
local function buildSigns()
	local signs = {
		{ Part = "SafeSign", Text = "SAFE ZONE" },
		{ Part = "EggSign", Text = "EGG MACHINE" },
		{ Part = "PortalSign", Text = "REBIRTH" },
	}
	for _, sign in ipairs(signs) do
		local board = Workspace:WaitForChild(sign.Part)
		local gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Front
		gui.AlwaysOnTop = true
		gui.Parent = board
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextScaled = true
		label.Font = Enum.Font.SourceSansBold
		label.Text = sign.Text
		label.Parent = gui
	end
end

buildSigns()
Spawner.init({ PlayerData = PlayerData, Notify = notify, SendState = sendState })
WaveController.init()
task.spawn(function()
	Spawner.spawnLoop()
end)
task.spawn(function()
	WaveController.run(onCaughtOutside)
end)

while true do
	task.wait(1)
	for _, player in ipairs(Players:GetPlayers()) do
		local state = PlayerData.get(player)
		if state then
			PlayerData.addMoney(player, PlayerData.incomePerSecond(player))
			bankCarriedIfHome(player)
			sendState(player)
		end
	end
	local phase, countdown = WaveController.getStatus()
	WaveChanged:FireAllClients(phase, countdown)
end

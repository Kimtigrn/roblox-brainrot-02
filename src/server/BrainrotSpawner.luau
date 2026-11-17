-- Tsunami Brainrot: grows the brainrots on the beach spawn pads, one per pad,
-- and hands a caught one to the player who presses E on it.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local BrainrotData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotData"))

local Spawner = {}
local pads = {}
local occupied = {}
local context = nil

function Spawner.init(gameContext)
	context = gameContext
	for i = 1, 6 do
		pads[i] = Workspace:WaitForChild("Pad" .. tostring(i))
		occupied[i] = nil
	end
end

local function labelText(entry, mutation, totalRate)
	local text = entry.Name .. "\n" .. entry.Rarity .. " - $" .. tostring(totalRate) .. "/s"
	if mutation ~= "Normal" then
		text = text .. "\n" .. mutation
	end
	return text
end

-- Builds one brainrot as a Model at the origin: a round body, two eyes, a
-- floating name plate and a Catch prompt. The caller pivots it onto a pad.
function Spawner.buildBrainrotModel(entry, mutation, totalRate)
	local size = entry.Size
	local model = Instance.new("Model")
	model.Name = entry.Name

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Shape = Enum.PartType.Ball
	body.Size = Vector3.new(size, size, size)
	body.Color = entry.Color
	body.Material = Enum.Material.SmoothPlastic
	body.Anchored = true
	body.CanCollide = false
	body.Parent = model

	local eyeOffset = size * 0.22
	local eyeSize = size * 0.28
	for _, side in ipairs({ -1, 1 }) do
		local eye = Instance.new("Part")
		eye.Name = "Eye"
		eye.Shape = Enum.PartType.Ball
		eye.Size = Vector3.new(eyeSize, eyeSize, eyeSize)
		eye.Color = Color3.fromRGB(255, 255, 255)
		eye.Material = Enum.Material.SmoothPlastic
		eye.Anchored = true
		eye.CanCollide = false
		eye.Position = Vector3.new(side * eyeOffset, eyeOffset, size * 0.42)
		eye.Parent = model

		local pupil = Instance.new("Part")
		pupil.Name = "Pupil"
		pupil.Shape = Enum.PartType.Ball
		pupil.Size = Vector3.new(eyeSize * 0.5, eyeSize * 0.5, eyeSize * 0.5)
		pupil.Color = Color3.fromRGB(20, 20, 20)
		pupil.Material = Enum.Material.SmoothPlastic
		pupil.Anchored = true
		pupil.CanCollide = false
		pupil.Position = Vector3.new(side * eyeOffset, eyeOffset, size * 0.42 + eyeSize * 0.3)
		pupil.Parent = model
	end

	local plate = Instance.new("BillboardGui")
	plate.Name = "NamePlate"
	plate.Size = UDim2.new(0, 150, 0, 60)
	plate.StudsOffset = Vector3.new(0, size * 0.9, 0)
	plate.AlwaysOnTop = true
	plate.Parent = body

	local plateText = Instance.new("TextLabel")
	plateText.Name = "Label"
	plateText.Size = UDim2.new(1, 0, 1, 0)
	plateText.BackgroundColor3 = Color3.new(0, 0, 0)
	plateText.BackgroundTransparency = 0.4
	plateText.TextColor3 = Color3.new(1, 1, 1)
	plateText.TextScaled = true
	plateText.Font = Enum.Font.SourceSansBold
	plateText.Text = labelText(entry, mutation, totalRate)
	plateText.Parent = plate

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "CatchPrompt"
	prompt.ActionText = "Catch"
	prompt.ObjectText = entry.Name
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = body

	return model, prompt
end

local function onPrompt(player, model, entry, mutation, totalRate, padIndex)
	local state = context.PlayerData.get(player)
	if not state then
		return
	end
	if state.Carried then
		context.Notify(player, "Your hands are full! Bring it home first.")
		return
	end
	context.PlayerData.setCarried(player, {
		Name = entry.Name,
		Rarity = entry.Rarity,
		Rate = entry.Rate,
		Mutation = mutation,
		TotalRate = totalRate,
	})
	model:Destroy()
	occupied[padIndex] = nil
	context.Notify(player, "Caught " .. entry.Name .. "! Dash home before the wave!")
	context.SendState(player)
end

function Spawner.spawnLoop()
	while true do
		task.wait(6)
		local padIndex = math.random(1, 6)
		if not occupied[padIndex] then
			local pool = BrainrotData.PAD_POOLS[padIndex]
			local rarity = BrainrotData.rollRarity(pool)
			local entry = BrainrotData.rollCast(rarity)
			local mutation, multiplier = BrainrotData.rollMutation()
			local totalRate = entry.Rate * multiplier
			local model, prompt = Spawner.buildBrainrotModel(entry, mutation, totalRate)
			local pad = pads[padIndex]
			model:PivotTo(CFrame.new(pad.Position + Vector3.new(0, 2 + entry.Size / 2, 0)))
			model.Parent = Workspace
			occupied[padIndex] = model
			prompt.Triggered:Connect(function(player)
				onPrompt(player, model, entry, mutation, totalRate, padIndex)
			end)
			task.delay(60, function()
				if occupied[padIndex] == model then
					model:Destroy()
					occupied[padIndex] = nil
				end
			end)
		end
	end
end

return Spawner

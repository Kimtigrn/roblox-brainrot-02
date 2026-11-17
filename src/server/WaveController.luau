-- Tsunami Brainrot: the wave itself. It rests at the south end of the beach,
-- counts down, warns the island, then sweeps north across the whole map.
-- Any player it passes while they stand outside the safe zone loses the
-- brainrot they are carrying. The safe zone is the raised base in the north.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local BrainrotData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotData"))

local WaveController = {}
local phase = "Calm"
local countdown = BrainrotData.WAVE.CalmSeconds
local wall = nil
local foam = nil
local START_Z = 150
local END_Z = -150
local WALL_Y = 22
local FOAM_Y = 43

function WaveController.init()
	local wave = Workspace:WaitForChild("TsunamiWave")
	wall = wave:WaitForChild("Wall")
	foam = wave:WaitForChild("Foam")
end

function WaveController.getStatus()
	return phase, countdown
end

-- Lets a tour, or a test, jump the countdown: 0 starts the warning at once.
function WaveController.setWaveCountdown(seconds)
	countdown = seconds
end

function WaveController.startWaveNow()
	if phase == "Calm" then
		countdown = 0
	end
end

local function moveWaveTo(z)
	wall.CFrame = CFrame.new(0, WALL_Y, z)
	foam.CFrame = CFrame.new(0, FOAM_Y, z)
end

local function isInSafeZone(position)
	return position.Z < -100 and math.abs(position.X) < 45
end

-- Punishes only players the wall has already passed: the wall is south of
-- them (its Z is at or below theirs) while they stand outside the safe zone.
local function sweepPlayers(wallZ, onCaughtOutside)
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local root = character:FindFirstChild("HumanoidRootPart")
			if root then
				local position = root.Position
				if not isInSafeZone(position) and wallZ <= position.Z then
					onCaughtOutside(player)
				end
			end
		end
	end
end

function WaveController.run(onCaughtOutside)
	while true do
		phase = "Calm"
		countdown = BrainrotData.WAVE.CalmSeconds
		while countdown > 0 do
			task.wait(1)
			countdown = countdown - 1
		end

		phase = "Warning"
		countdown = BrainrotData.WAVE.WarningSeconds
		while countdown > 0 do
			task.wait(1)
			countdown = countdown - 1
		end

		phase = "Wave"
		countdown = 0
		local steps = 100
		local sweepSeconds = BrainrotData.WAVE.SweepSeconds
		for i = 1, steps do
			local z = START_Z + (END_Z - START_Z) * (i / steps)
			moveWaveTo(z)
			if i % 10 == 0 then
				sweepPlayers(z, onCaughtOutside)
			end
			task.wait(sweepSeconds / steps)
		end
		moveWaveTo(START_Z)
	end
end

return WaveController

-- Tsunami Brainrot: the egg machine. Pay the egg's cost, hatch a random
-- brainrot from that egg's rarity pool, and it joins your owned collection.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BrainrotData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotData"))

local EggMachine = {}

function EggMachine.hatch(player, eggType, playerData)
	local egg = BrainrotData.EGGS[eggType]
	if not egg then
		return nil, "Unknown egg"
	end
	local state = playerData.get(player)
	if not state then
		return nil, "No player state"
	end
	if state.Money < egg.Cost then
		return nil, "Not enough money for that egg"
	end
	state.Money = state.Money - egg.Cost
	local hatched = BrainrotData.rollEgg(eggType)
	playerData.addOwned(player, hatched)
	return hatched, nil
end

return EggMachine

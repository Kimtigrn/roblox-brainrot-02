-- Tsunami Brainrot: one place keeps every player's state, so the money, the
-- owned brainrots, the carried catch and the rebirths never drift apart.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BrainrotData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotData"))

local PlayerData = {}
local states = {}

function PlayerData.newPlayer(player)
	states[player] = { Money = 0, Owned = {}, Carried = nil, Rebirths = 0 }
end

function PlayerData.get(player)
	return states[player]
end

function PlayerData.addMoney(player, amount)
	local state = states[player]
	if state then
		state.Money = state.Money + amount
	end
end

function PlayerData.incomePerSecond(player)
	local state = states[player]
	if not state then
		return 0
	end
	return BrainrotData.incomePerSecond(state.Owned, state.Rebirths)
end

function PlayerData.addOwned(player, brainrot)
	local state = states[player]
	if state then
		table.insert(state.Owned, brainrot)
	end
end

function PlayerData.setCarried(player, brainrot)
	local state = states[player]
	if state then
		state.Carried = brainrot
	end
end

function PlayerData.clearCarried(player)
	local state = states[player]
	if not state then
		return nil
	end
	local carried = state.Carried
	state.Carried = nil
	return carried
end

function PlayerData.rebirthCost(player)
	local state = states[player]
	if not state then
		return { Money = 0, Owned = 0 }
	end
	return BrainrotData.rebirthCost(state.Rebirths)
end

function PlayerData.canRebirth(player)
	local state = states[player]
	if not state then
		return false
	end
	local cost = PlayerData.rebirthCost(player)
	return state.Money >= cost.Money and #state.Owned >= cost.Owned
end

function PlayerData.doRebirth(player)
	if not PlayerData.canRebirth(player) then
		return false
	end
	local state = states[player]
	local cost = PlayerData.rebirthCost(player)
	state.Money = state.Money - cost.Money
	state.Owned = {}
	state.Carried = nil
	state.Rebirths = state.Rebirths + 1
	return true
end

function PlayerData.wipe(player)
	states[player] = nil
end

return PlayerData

-- Tsunami Brainrot: every number the game runs on lives in this one module,
-- so the server and the client always agree on names, rarities, rates and costs.

local BrainrotData = {}

-- The rarity ladder, weakest first. Weight is the spawn weight inside a pool.
BrainrotData.RARITIES = {
	{ Name = "Common", Color = Color3.fromRGB(170, 170, 170), Weight = 40 },
	{ Name = "Rare", Color = Color3.fromRGB(60, 200, 90), Weight = 28 },
	{ Name = "Epic", Color = Color3.fromRGB(160, 80, 230), Weight = 16 },
	{ Name = "Legendary", Color = Color3.fromRGB(255, 200, 40), Weight = 10 },
	{ Name = "Mythic", Color = Color3.fromRGB(255, 90, 170), Weight = 5 },
	{ Name = "Brainrot God", Color = Color3.fromRGB(255, 60, 60), Weight = 1 },
}

-- The cast: ten absurd meme-born characters of this game's own invention.
-- Rate is the money per second one of them earns on your home base.
BrainrotData.CAST = {
	{ Name = "Sir Splashalot", Rarity = "Common", Rate = 2, Color = Color3.fromRGB(70, 130, 255), Size = 3, Blurb = "A knight fish who guards the shallow end." },
	{ Name = "Banana Bandito", Rarity = "Common", Rate = 3, Color = Color3.fromRGB(255, 220, 60), Size = 3, Blurb = "Steals your lunch, then sells it back to you." },
	{ Name = "DJ Dolphin", Rarity = "Rare", Rate = 6, Color = Color3.fromRGB(60, 220, 230), Size = 4, Blurb = "Drops beats and drops the bass, never the ball." },
	{ Name = "Professor Pickle", Rarity = "Rare", Rate = 9, Color = Color3.fromRGB(90, 200, 90), Size = 4, Blurb = "Has a PhD in brine and a minor in chaos." },
	{ Name = "Turbo Tuna", Rarity = "Epic", Rate = 15, Color = Color3.fromRGB(190, 200, 210), Size = 4, Blurb = "A fish with a spoiler and a need for speed." },
	{ Name = "Waffle Wizard", Rarity = "Epic", Rate = 22, Color = Color3.fromRGB(200, 150, 80), Size = 4, Blurb = "Casts syrup spells. Sticky, but powerful." },
	{ Name = "Grandma Gator", Rarity = "Legendary", Rate = 35, Color = Color3.fromRGB(40, 120, 70), Size = 5, Blurb = "Bakes cookies. Bites first, hugs later." },
	{ Name = "Pixel Penguin", Rarity = "Legendary", Rate = 48, Color = Color3.fromRGB(40, 40, 50), Size = 5, Blurb = "An 8-bit bird that renders in real life." },
	{ Name = "Mango Maniac", Rarity = "Mythic", Rate = 80, Color = Color3.fromRGB(255, 150, 40), Size = 5, Blurb = "One bite and the whole beach goes mango." },
	{ Name = "Captain Croc Crunch", Rarity = "Brainrot God", Rate = 150, Color = Color3.fromRGB(255, 190, 40), Size = 6, Blurb = "The crunch heard around the island." },
}

-- Mutations multiply a brainrot's rate. Chance is the percent of a roll.
BrainrotData.MUTATIONS = {
	{ Name = "Normal", Multiplier = 1, Chance = 89.5 },
	{ Name = "Golden", Multiplier = 2, Chance = 8 },
	{ Name = "Rainbow", Multiplier = 5, Chance = 2 },
	{ Name = "Diamond", Multiplier = 10, Chance = 0.5 },
}

-- Eggs: pay the cost, hatch a random brainrot from the egg's rarity pool.
BrainrotData.EGGS = {
	Egg = { Cost = 100, Pool = { "Common", "Rare" } },
	GoldenEgg = { Cost = 500, Pool = { "Rare", "Epic", "Legendary" } },
	GodEgg = { Cost = 2000, Pool = { "Legendary", "Mythic", "Brainrot God" } },
}

-- Rebirth: pay money and own enough brainrots, lose them, earn a permanent bonus.
BrainrotData.REBIRTH = { Money = 5000, Owned = 5, Bonus = 0.5 }

-- The wave's rhythm, in seconds.
BrainrotData.WAVE = { CalmSeconds = 45, WarningSeconds = 10, SweepSeconds = 20 }

-- What each of the six beach spawn pads can grow, weakest pad first.
BrainrotData.PAD_POOLS = {
	{ "Common" },
	{ "Common", "Rare" },
	{ "Rare", "Epic" },
	{ "Epic", "Legendary" },
	{ "Legendary", "Mythic" },
	{ "Mythic", "Brainrot God" },
}

local function pickWeighted(entries, weightOf)
	local total = 0
	for _, entry in ipairs(entries) do
		total = total + weightOf(entry)
	end
	local roll = math.random() * total
	for _, entry in ipairs(entries) do
		roll = roll - weightOf(entry)
		if roll <= 0 then
			return entry
		end
	end
	return entries[#entries]
end

function BrainrotData.getByName(name)
	for _, entry in ipairs(BrainrotData.CAST) do
		if entry.Name == name then
			return entry
		end
	end
	return nil
end

function BrainrotData.rollRarity(pool)
	local inPool = {}
	for _, rarity in ipairs(BrainrotData.RARITIES) do
		for _, wanted in ipairs(pool) do
			if rarity.Name == wanted then
				table.insert(inPool, rarity)
			end
		end
	end
	return pickWeighted(inPool, function(rarity)
		return rarity.Weight
	end).Name
end

function BrainrotData.rollCast(rarity)
	local ofRarity = {}
	for _, entry in ipairs(BrainrotData.CAST) do
		if entry.Rarity == rarity then
			table.insert(ofRarity, entry)
		end
	end
	return ofRarity[math.random(1, #ofRarity)]
end

function BrainrotData.rollMutation()
	local picked = pickWeighted(BrainrotData.MUTATIONS, function(mutation)
		return mutation.Chance
	end)
	return picked.Name, picked.Multiplier
end

function BrainrotData.rollEgg(eggType)
	local egg = BrainrotData.EGGS[eggType]
	if not egg then
		return nil
	end
	local rarity = BrainrotData.rollRarity(egg.Pool)
	local entry = BrainrotData.rollCast(rarity)
	local mutation, multiplier = BrainrotData.rollMutation()
	return {
		Name = entry.Name,
		Rarity = entry.Rarity,
		Rate = entry.Rate,
		Mutation = mutation,
		TotalRate = entry.Rate * multiplier,
	}
end

function BrainrotData.rebirthCost(level)
	return {
		Money = BrainrotData.REBIRTH.Money * (level + 1),
		Owned = BrainrotData.REBIRTH.Owned + level,
	}
end

function BrainrotData.incomePerSecond(owned, rebirths)
	local total = 0
	for _, brainrot in ipairs(owned) do
		total = total + brainrot.TotalRate
	end
	return total * (1 + BrainrotData.REBIRTH.Bonus * rebirths)
end

return BrainrotData

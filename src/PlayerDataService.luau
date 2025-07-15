--[[
@TheAlmightyForehead
May 21st, 2024
Using a mix of ProfileStore and DataStoreService, this service is used to handle player data
]]

local DATA_STORE_VERSION = 1 -- change if needed

-- SERVICES --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

-- MODULES --
local Signal = require(script.Parent.Packages.Signal)

-- PROFILESTORE --
local ProfileStore = require(script.Parent.Packages.ProfileStore)

-- TYPES --
export type ProfileData = {
	[string] : any
}

local PlayerData = {
	PlayerStore = ProfileStore.New("PlayerStore_" .. DATA_STORE_VERSION, {}),
	
	Profiles = {},
	OrderedDataStores = {},
	NormalDataStores = {},

	DataChanged = Signal.new(),
	DataLoaded = Signal.new()
}

function PlayerData:UpdateOrderedDataFor(key : string, valueName : string, value : number)
	if type(key) == "string" and type(valueName) == "string" and tonumber(value) then
		if not self.OrderedDataStores[valueName] then
			self.OrderedDataStores[valueName] = DataStoreService:GetOrderedDataStore(valueName .. "_" .. DATA_STORE_VERSION)
		end

		local success, err = pcall(function()
			self.OrderedDataStores[valueName]:SetAsync(key, value)
		end)

		if not success then
			warn("Error while updating Ordered " .. valueName .. " Data for " .. key .. " |", err)
		end
	end
end

function PlayerData:UpdateOrderedDataForPlayer(player : Player, valueName : string, value : number)
	if player and type(valueName) == "string" and tonumber(value) then
		if not self.OrderedDataStores[valueName] then
			self.OrderedDataStores[valueName] = DataStoreService:GetOrderedDataStore(valueName .. "_" .. DATA_STORE_VERSION)
		end

		local success, err = pcall(function()
			self.OrderedDataStores[valueName]:SetAsync(player.UserId .. "_" .. valueName .. "_DATA", value)
		end)

		if not success then
			warn("Error while updating Ordered " .. valueName .. " Data for " .. player.Name .. " (" .. player.UserId .. ") |", err)
		end
	end
end

function PlayerData:GetOrderedData(valueName : string, ascending : boolean?, amount : number?) : DataStorePages?
	if not self.OrderedDataStores[valueName] then
		self.OrderedDataStores[valueName] = DataStoreService:GetOrderedDataStore(valueName .. "_" .. DATA_STORE_VERSION)
	end

	local success, data = pcall(function()
		return self.OrderedDataStores[valueName]:GetSortedAsync(ascending, amount or 100)
	end)

	return (success and data) or (nil)
end

function PlayerData:UpdateNormalDataForPlayer(player : Player, valueName : string, value : any)
	if player and type(valueName) == "string" then
		if not self.NormalDataStores[valueName] then
			self.NormalDataStores[valueName] = DataStoreService:GetDataStore(valueName .. "_" .. DATA_STORE_VERSION)
		end

		local success, err = pcall(function()
			self.NormalDataStores[valueName]:SetAsync(player.UserId .. "_" .. valueName .. "_DATA", value)
		end)

		if not success then
			warn("Error while updating Normal " .. valueName .. " Data for " .. player.Name .. " (" .. player.UserId .. ") |", err)
		end
	end
end

function PlayerData:UpdateNormalDataWithUserId(userId : number, valueName : string, value : any)
	if userId and type(valueName) == "string" then
		if not self.NormalDataStores[valueName] then
			self.NormalDataStores[valueName] = DataStoreService:GetDataStore(valueName .. "_" .. DATA_STORE_VERSION)
		end

		local success, err = pcall(function()
			self.NormalDataStores[valueName]:SetAsync(userId .. "_" .. valueName .. "_DATA", value)
		end)

		if not success then
			warn("Error while updating Normal " .. valueName .. " Data for " .. userId .. " |", err)
		end
	end
end

function PlayerData:GetNormalDataForPlayer(userId : number, valueName : string) : any?
	if not self.NormalDataStores[valueName] then
		self.NormalDataStores[valueName] = DataStoreService:GetDataStore(valueName .. "_" .. DATA_STORE_VERSION)
	end

	local success, data = pcall(function()
		return self.NormalDataStores[valueName]:GetAsync(userId .. "_" .. valueName .. "_DATA")
	end)

	return (success and data) or (nil)
end

function PlayerData:SetValue(player : Player, valueName : string, value : any)
	if self.Profiles[player] and self.Profiles[player].Data then
		self.Profiles[player].Data[valueName] = value
		self.DataChanged:Fire(player, self.Profiles[player].Data)
	end
end

function PlayerData:GetValue(player : Player, valueName : string) : any?
	return self.Profiles[player] and self.Profiles[player].Data and self.Profiles[player].Data[valueName]
end

function PlayerData:Load(player : Player)
	local profile = self.PlayerStore:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile.OnSessionEnd:Connect(function()
			self.Profiles[player] = nil
			player:Kick(`Profile session end - Please rejoin`)
		end)

		if player.Parent == Players then
			self.Profiles[player] = profile
			self.DataLoaded:Fire(player, profile.Data, self)
		else
			profile:EndSession()
		end

	else
		player:Kick(`Profile load fail - Please rejoin`)
	end
end

function PlayerData:OnPlayerAdded(player : Player)
	self:Load(player)
end

function PlayerData:OnPlayerRemoving(player : Player)
	local profile = self.Profiles[player]

	if profile ~= nil then
		profile:EndSession()
	end
end

Players.PlayerRemoving:Connect(function(player : Player)
	PlayerData:OnPlayerRemoving(player)
end)

for _, player in Players:GetPlayers() do
	task.spawn(function()
		PlayerData:OnPlayerAdded(player)
	end)
end

Players.PlayerAdded:Connect(function(player : Player)
	PlayerData:OnPlayerAdded(player)
end)

return PlayerData

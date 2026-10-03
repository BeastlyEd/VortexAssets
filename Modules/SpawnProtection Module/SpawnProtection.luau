--!strict

--[[
	Ed776 Free Script License

	This script was created by Ed776.

	Permission is granted to anyone to use, modify, and include
	this script in their own Vortex games for free.

	Credit is NOT required.

	Restrictions:
	- You may NOT sell this script or any modified version of it.
	- You may NOT redistribute, re-upload, or share this script
	  as a standalone script or asset.
	- You may NOT claim the original script was created by you.

	You are free to use and modify this script as long as the
	restrictions above are followed.

	Script: SpawnProtection
	Description: Allows user to manage and create a SpawnProtection
	system while it is not a standalone feature in Vortex.

	Copyright © 2026 Ed776
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local SpawnProtection = {}

SpawnProtection.Protected = {} :: { [number]: number }
SpawnProtection.RunLocation = RunService:IsServer() and "Server" or "Client"

--== Private ==--

local _defaultShieldColor = Color3.fromRGB(6, 151, 170)
local _defaultShieldTime = 3
local _defaultVisibility = true
local _tickRate = 0.05
local _clientShields: { [string]: { Part } } = {}

--== Settings ==--

SpawnProtection._ShieldTime = _defaultShieldTime
SpawnProtection._ShowShield = _defaultVisibility
SpawnProtection._ShieldColor = _defaultShieldColor

--== Private Functions ==--

local function SetProtectionAttribute(player: Player, enabled: boolean)
	if enabled then
		player:SetAttribute("SpawnProtection", true)
	else
		player:SetAttribute("SpawnProtection", nil)
		player:SetAttribute("SpawnProtectionEnd", nil)
	end
end

local function UpdatePlayerAttributes(player: Player)
	player:SetAttribute("SpawnProtectionColor", SpawnProtection._ShieldColor)

	player:SetAttribute("SpawnProtectionVisible", SpawnProtection._ShowShield)
end

--== Public Functions ==--

-- Sets the global shield time length
function SpawnProtection:SetShieldLength(time: number?)
	if SpawnProtection.RunLocation ~= "Server" then
		print("Server Only: Settings will automatically update on the client once changed on the server")
		return
	end

	SpawnProtection._ShieldTime = time or _defaultShieldTime
end

-- Disable a player's shield
function SpawnProtection:DisableUserShield(userId: number)
	if SpawnProtection.RunLocation ~= "Server" then
		print("Server Only: Settings will automatically update on the client once changed on the server")
		return
	end

	local player = Players:GetPlayerByUserId(userId)

	if not player then
		return
	end

	SpawnProtection.Protected[userId] = nil

	SetProtectionAttribute(player, false)
end

-- Give a player a shield, or extend a current one
function SpawnProtection:EnableUserShield(userId: number)
	if SpawnProtection.RunLocation ~= "Server" then
		print("Server Only: Settings will automatically update on the client once changed on the server")
		return
	end

	local player = Players:GetPlayerByUserId(userId)

	if not player then
		return
	end

	SpawnProtection.Protected[userId] = 0

	UpdatePlayerAttributes(player)
	SetProtectionAttribute(player, true)
end

-- Whether the client will visually see shields
function SpawnProtection:ToggleVisuals(toggle: boolean?)
	if SpawnProtection.RunLocation ~= "Server" then
		print("Server Only: Settings will automatically update on the client once changed on the server")
		return
	end

	SpawnProtection._ShowShield = toggle or _defaultVisibility

	for _, player in Players:GetPlayers() do
		player:SetAttribute("SpawnProtectionVisible", SpawnProtection._ShowShield)
	end
end

-- Sets the color of the visuals
function SpawnProtection:SetShieldColor(color: Color3)
	if SpawnProtection.RunLocation ~= "Server" then
		print("Server Only: Settings will automatically update on the client once changed on the server")
		return
	end

	SpawnProtection._ShieldColor = color

	for _, player in Players:GetPlayers() do
		player:SetAttribute("SpawnProtectionColor", color)
	end
end

--== Get ==--

function SpawnProtection.IsPlayerProtected(userId: number): boolean
    if SpawnProtection.Protected[userId] then
        return true
    end

    return false
end

--== Initialization ==--

function SpawnProtection.init()
	-- Server:
	if SpawnProtection.RunLocation == "Server" then
		Players.PlayerAdded:Connect(function(player: Player)
			SpawnProtection.Protected[player.UserId] = nil

			player:SetAttribute("SpawnProtectionVisible", SpawnProtection._ShowShield)
			player:SetAttribute("SpawnProtectionColor", SpawnProtection._ShieldColor)

            player.CharacterAdded:Connect(function(character: Model)
                SpawnProtection:EnableUserShield(player.UserId)
            end)
		end)

		Players.PlayerRemoving:Connect(function(player: Player)
			SpawnProtection.Protected[player.UserId] = nil
		end)
	else
		-- Client:

		local function RemoveShield(player: Player)
			if not _clientShields[player.Name] then
				return
			end

			for _, part in _clientShields[player.Name] do
				part:Destroy()
			end

			_clientShields[player.Name] = nil
		end

		local function WatchPlayer(player: Player)
			local function UpdateShield()
				local protected = player:GetAttribute("SpawnProtection") == true

				if protected then -- Shield
					local visible = player:GetAttribute("SpawnProtectionVisible")

					if not visible then
						return
					end

					_clientShields[player.Name] = {}

					local color = player:GetAttribute("SpawnProtectionColor") :: Color3 or Color3.fromRGB(255, 255, 255)

					for _, letter in { "A", "B" } do
						local shield = Instance.new("Part")
						shield.Size = Vector3.new(5, 5, 5)
						shield.Name = string.format("Shield%s%s", letter, player.Name)
						shield.CanCollide = false
						shield.CastShadow = false
						shield.Transparency = 0.7
						shield.Color = color
                        shield.Parent = workspace
                        table.insert(_clientShields[player.Name], shield)
					end
				else -- Remove Shield
					RemoveShield(player)
				end
			end

			UpdateShield()

			player:GetAttributeChangedSignal("SpawnProtection"):Connect(UpdateShield)
			player:GetAttributeChangedSignal("SpawnProtectionColor"):Connect(UpdateShield)
			player:GetAttributeChangedSignal("SpawnProtectionVisible"):Connect(UpdateShield)
		end

		for _, player in Players:GetPlayers() do
			WatchPlayer(player)
		end

		Players.PlayerAdded:Connect(WatchPlayer)
		Players.PlayerRemoving:Connect(RemoveShield)
	end

	-- Start loop. You could technically do this in another loop if you want but I just wanted to make it as accessible as possible. Kinda like a plug and play thing
	task.spawn(function()
		while true do
			local dt = task.wait(_tickRate)

			--Server tick upd
			if SpawnProtection.RunLocation == "Server" then
				for userId, elapsed in SpawnProtection.Protected do
					elapsed += dt

					if elapsed >= SpawnProtection._ShieldTime then
						SpawnProtection.Protected[userId] = nil

						local player = Players:GetPlayerByUserId(userId)

						if player then
							SetProtectionAttribute(player, false)
						end
					else
						SpawnProtection.Protected[userId] = elapsed
					end
				end
				return
			end

			for _, shieldParts in _clientShields do
                
			end
		end
	end)
end
return SpawnProtection

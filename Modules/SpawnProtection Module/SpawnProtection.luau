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
    Description: Allows user to manage and create a Spawnprotection system while its not a standalone feature in Vortex.

	Copyright © 2026 Ed776
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SpawnProtection = {}

SpawnProtection.Protected = {} :: { [number]: number } -- [UserID]: TimeLeft
SpawnProtection.RunLocation = RunService:IsServer() and "Server" or "Client"

--== Priv ==--
local _defaultShieldColor = Color3.fromRGB(6, 151, 170)
local _defaultShieldTime = 3
local _defaultVisiblity = true
local networker: RemoteEvent

--== Settings ==--

SpawnProtection._ShieldTime = _defaultShieldTime
SpawnProtection._ShowShield = _defaultVisiblity
SpawnProtection._ShieldColor = _defaultShieldColor

--== Networking ==--

--Update client settings using attributes
local function UpdateClientSettings(setting: string, value: boolean | number | Color3)
    networker:SetAttribute(setting, value)
end

--Tell client someone needs a shield
local function NotifyClient(userId: number)
    if not SpawnProtection._ShowShield then
        return
    end

    networker:FireAllClients(userId)
end

--== Publics Functions ==--

-- Sets the global shield time length
function SpawnProtection:SetShieldLength(time: number?)
    SpawnProtection._ShieldTime = time or _defaultShieldTime
end

-- If a player has a shield on, disable it
function SpawnProtection:DisableUserShied()
    
end

-- Give a player a shield, or extend a current one
function SpawnProtection:EnableUserShield()
    
end

-- Whether the client will visually see the shields or not
function SpawnProtection:ToggleVisuals(toggle: boolean?)
    SpawnProtection._ShowShield = toggle or _defaultVisiblity
end

-- Sets the color of the visuals
function SpawnProtection:SetShieldColor(color: Color3)
    SpawnProtection._ShieldColor = color or _defaultShieldColor
end

--== Initialization ==--

function SpawnProtection.init()

    -- Networking
	local _networker: RemoteEvent
	if SpawnProtection.RunLocation == "Server" then
		_networker = Instance.new("RemoteEvent")
		_networker.Parent = ReplicatedStorage
		_networker.Name = "SpawnProtection_Networker"
	else
		_networker = ReplicatedStorage:WaitForChild("SpawnProtection_Networker") :: RemoteEvent
	end

    networker = _networker

    -- Attributes

    if SpawnProtection.RunLocation == "Server" then
        
    end

    -- Connections
    
    Players.PlayerAdded:Connect(function(p: Player)
        if SpawnProtection.RunLocation == "Server" then
            SpawnProtection.Protected = 
        else

        end
    end)

end

return SpawnProtection

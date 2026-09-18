_G.FriendColor = Color3.fromRGB(0, 0, 255)
_G.EnemyColor = Color3.fromRGB(255, 0, 0)
_G.UseTeamColor = true

--------------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local DISTANCE_MULTIPLIER = 0.346

--------------------------------------------------------------------
local Holder = Instance.new("Folder")
Holder.Name = "ESP"
Holder.Parent = game.CoreGui

local Box = Instance.new("BoxHandleAdornment")
Box.Name = "nilBox"
Box.Size = Vector3.new(1, 2, 1)
Box.Color3 = Color3.new(100 / 255, 100 / 255, 100 / 255)
Box.Transparency = 0.7
Box.ZIndex = 0
Box.AlwaysOnTop = false
Box.Visible = false

local NameTag = Instance.new("BillboardGui")
NameTag.Name = "nilNameTag"
NameTag.Enabled = false
NameTag.Size = UDim2.new(0, 200, 0, 50)
NameTag.AlwaysOnTop = true
NameTag.StudsOffset = Vector3.new(0, 1.8, 0)

local Tag = Instance.new("TextLabel")
Tag.Name = "Tag"
Tag.BackgroundTransparency = 1
Tag.Position = UDim2.new(0, -50, 0, 0)
Tag.Size = UDim2.new(0, 300, 0, 40)
Tag.TextSize = 15
Tag.TextColor3 = Color3.new(100 / 255, 100 / 255, 100 / 255)
Tag.TextStrokeColor3 = Color3.new(0, 0, 0)
Tag.TextStrokeTransparency = 0.4
Tag.Text = "nil"
Tag.Font = Enum.Font.SourceSansBold
Tag.TextScaled = false
Tag.Parent = NameTag

--------------------------------------------------------------------
local UnloadCharacter

local LoadCharacter = function(v)
	repeat
		task.wait()
	until v.Character ~= nil

	local humanoid = v.Character:WaitForChild("Humanoid", 5)
	if not humanoid then
		return
	end

	local vHolder = Holder:FindFirstChild(v.Name)
	if not vHolder then
		return
	end

	vHolder:ClearAllChildren()

	-- Box
	local b = Box:Clone()
	b.Name = v.Name .. "Box"
	b.Adornee = v.Character
	b.Visible = true
	b.Parent = vHolder

	-- Name + Distance
	local t = NameTag:Clone()
	t.Name = v.Name .. "NameTag"
	t.Enabled = true
	t.Parent = vHolder

	local head = v.Character:WaitForChild("Head", 5)
	if not head then
		UnloadCharacter(v)
		return
	end

	t.Adornee = head
	t.Tag.Text = v.Name .. "\n[--m]"

	-- Team color
	b.Color3 = v.TeamColor.Color
	t.Tag.TextColor3 = v.TeamColor.Color

	-- Hide Roblox name
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
end

--------------------------------------------------------------------
UnloadCharacter = function(v)
	local vHolder = Holder:FindFirstChild(v.Name)

	if vHolder then
		vHolder:ClearAllChildren()
	end
end

--------------------------------------------------------------------
local LoadPlayer = function(v)
	if v == LocalPlayer then
		return
	end

	local vHolder = Holder:FindFirstChild(v.Name)

	if not vHolder then
		vHolder = Instance.new("Folder")
		vHolder.Name = v.Name
		vHolder.Parent = Holder
	end

	v.CharacterAdded:Connect(function()
		task.wait(0.1)
		pcall(LoadCharacter, v)
	end)

	v.CharacterRemoving:Connect(function()
		pcall(UnloadCharacter, v)
	end)

	v.Changed:Connect(function(prop)
		if prop == "TeamColor" then
			pcall(function()
				UnloadCharacter(v)
				task.wait()
				LoadCharacter(v)
			end)
		end
	end)

	pcall(LoadCharacter, v)
end

--------------------------------------------------------------------
local UnloadPlayer = function(v)
	UnloadCharacter(v)

	local vHolder = Holder:FindFirstChild(v.Name)

	if vHolder then
		vHolder:Destroy()
	end
end

--------------------------------------------------------------------
for _, v in pairs(Players:GetPlayers()) do
	task.spawn(function()
		pcall(LoadPlayer, v)
	end)
end

Players.PlayerAdded:Connect(function(v)
	pcall(LoadPlayer, v)
end)

Players.PlayerRemoving:Connect(function(v)
	pcall(UnloadPlayer, v)
end)

LocalPlayer.NameDisplayDistance = 0

--------------------------------------------------------------------
-- REAL-TIME DISTANCE
--------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
	local localCharacter = LocalPlayer.Character
	if not localCharacter then
		return
	end

	local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
	if not localRoot then
		return
	end

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then

			local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
			local playerHolder = Holder:FindFirstChild(player.Name)

			if targetRoot and playerHolder then
				local nameTag = playerHolder:FindFirstChild(player.Name .. "NameTag")

				if nameTag and nameTag:FindFirstChild("Tag") then

					local studs = (localRoot.Position - targetRoot.Position).Magnitude

					-- Roblox studs -> meters
					local meters = math.floor(studs * DISTANCE_MULTIPLIER)

					nameTag.Tag.Text = player.Name .. "\n[" .. meters .. "m]"
				end
			end
		end
	end
end)

--------------------------------------------------------------------
-- CHAMS / HIGHLIGHT
--------------------------------------------------------------------
if _G.Reantheajfdfjdgs then
	return
end

_G.Reantheajfdfjdgs = ":suifayhgvsdghfsfkajewfrhk321rk213kjrgkhj432rj34f67df"

local function esp(target, color)
	if target.Character then

		if not target.Character:FindFirstChild("GetReal") then
			local highlight = Instance.new("Highlight")

			highlight.RobloxLocked = true
			highlight.Name = "GetReal"
			highlight.Adornee = target.Character
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.FillColor = color
			highlight.Parent = target.Character

		else
			target.Character.GetReal.FillColor = color
		end
	end
end

--------------------------------------------------------------------
while task.wait() do
	for _, v in pairs(Players:GetPlayers()) do
		if v ~= LocalPlayer then
			local color

			if _G.UseTeamColor then
				color = v.TeamColor.Color
			else
				if LocalPlayer.TeamColor == v.TeamColor then
					color = _G.FriendColor
				else
					color = _G.EnemyColor
				end
			end

			esp(v, color)
		end
	end
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Networker = require(ReplicatedStorage.Packages.Networker)
local CameraServiceUtils = require(script.Parent.CameraServiceUtils)

local CameraServiceClient = {}

CameraServiceClient.locked = false
CameraServiceClient.renderName = "CameraServiceClient"
CameraServiceClient.renderPriority = Enum.RenderPriority.Camera.Value
CameraServiceClient.HabilitZoomInProjectZomboidMode = true
CameraServiceClient.Enums = {
    CameraCollisionMode = CameraServiceUtils.enums.CameraCollisionMode,
    CameraStyle = CameraServiceUtils.enums.CameraStyle,
}

type Options = {
    CameraType: typeof(CameraServiceUtils.enums.CameraStyle),
}

function CameraServiceClient.Init(self: CameraServiceClient): ()
    self.Networker = Networker.client.new("CameraService", self)
end

function CameraServiceClient.SetLimitZoom(self: CameraServiceClient): ()
	local player = Players.LocalPlayer
	player.CameraMaxZoomDistance = CameraServiceUtils.settings.zoom_settings.max_zoom_distance
    player.CameraMinZoomDistance = CameraServiceUtils.settings.zoom_settings.min_zoom_distance
end

function CameraServiceClient.SetZoom(self: CameraServiceClient, distance: number): ()
	assert(typeof(distance) == "number", `distance deve ser um número, recebido: {typeof(distance)}`)
	distance = distance > CameraServiceUtils.settings.zoom_settings.max_zoom_distance and CameraServiceUtils.settings.zoom_settings.max_zoom_distance and CameraServiceUtils.settings.zoom_settings.max_zoom_distance < CameraServiceUtils.settings.zoom_settings.min_zoom_distance and CameraServiceUtils.settings.zoom_settings.min_zoom_distance or distance
	local player = Players.LocalPlayer
	local camera = workspace.CurrentCamera
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootpart") then
		local root = character.HumanoidRootPart
		camera.CFrame = CFrame.new(root.Position + Vector3.new(0, 5, distance), root.Position)
	end
end

function CameraServiceClient.CurrentZoom(self: CameraServiceClient): any
	local player = Players.LocalPlayer
	local camera = workspace.CurrentCamera
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local root = character.HumanoidRootPart
		local distance = (root.Position - camera.CFrame.Position).Magnitude
		return distance
	end
	return nil 
end

local function RayDetection(origin, detection, options): ()
	if not origin or not detection then
		return
	end
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = options.exclude or options.include or {}
	if options.tp == Enum.RaycastFilterType.Exclude then
		rayParams.FilterType = Enum.RaycastFilterType.Exclude
	else
		rayParams.FilterType = Enum.RaycastFilterType.Include
	end
	local result = workspace:Raycast(origin, detection, rayParams)
	return result
end

function CameraServiceClient.GhostWalls(self: CameraServiceClient)
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local camera = workspace.CurrentCamera
	local lastHitPart
	
	local g = self:SelfSpot()
	
	RunService:BindToRenderStep(self.renderName, self.renderPriority, function()
		if not character and not character:FindFirstChild("HumanoidRootPart") then
			return
		end
		local camPos = camera.CFrame.Position
		local humanoidRoot = character:WaitForChild("HumanoidRootPart")
		local characterPos = humanoidRoot.Position
		local detection = (characterPos - camPos).Unit * (characterPos - camPos).Magnitude
		local options = {
			exclude = {character},
			tp = Enum.RaycastFilterType.Exclude
		}
		local result = RayDetection(camPos, detection, options)
		if result and result.Instance then
			local hitPart = result.Instance :: BasePart
			if hitPart:IsA("BasePart") then
				if lastHitPart and lastHitPart ~= hitPart then
					lastHitPart.Transparency = 0
					g.Enabled = true
				end
				hitPart.Transparency = 0.6
				lastHitPart = hitPart
			end
		else
			g.Enabled = false
			if lastHitPart then
				lastHitPart.Transparency = 0
				lastHitPart = nil
			end
		end
	end)
end

function CameraServiceClient.SelfSpot(self: CameraServiceClient): ()
	local function ve(In, name)
		local catched = false
		if typeof (In) == "Instance" then
			for _, f in ipairs(In:GetChildren()) do
				if catched then
					break
				end
			end
		end
		return catched
	end
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local exist = ve(character, "TSPOT")
	if exist then
		return
	end
	local HightLight_instance = Instance.new("Highlight")
	HightLight_instance.Name = "TSPOT"
	HightLight_instance.FillTransparency = 1
	HightLight_instance.OutlineTransparency = 0
	HightLight_instance.Parent = character
	return HightLight_instance
end

function CameraServiceClient.ZomboidCameraStyle(self: CameraServiceClient): () 
	local fov = 10
	local offset = Vector3.new(200, 104, -50)
	local cameraType = Enum.CameraType.Scriptable
	local camera = workspace.CurrentCamera
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		camera.CameraType = cameraType
		camera.FieldOfView = fov
		camera.CFrame = CFrame.new(root.Position + offset, root.Position)
	end
end

function CameraServiceClient.DefaultCameraStyle(self: CameraServiceClient): ()
	local fov = 70
	local cameraType = Enum.CameraType.Custom
	local camera = workspace.CurrentCamera
	camera.CameraType = cameraType
	camera.FieldOfView = fov
end

function CameraServiceClient.StopPespective(self: CameraServiceClient): ()
	RunService:UnbindFromRenderStep(self.renderName)
end

function CameraServiceClient.StartPespective(self: CameraServiceClient, style: typeof(CameraServiceUtils.enums.CameraStyle)): ()
	RunService:BindToRenderStep(self.renderName, self.renderPriority, function()
		local responseStatus, _ = pcall(function()
			if style == CameraServiceUtils.enums.CameraStyle.Zomboid then
                self:ZomboidCameraStyle()
            elseif style == CameraServiceUtils.enums.CameraStyle.Classic then
                self:DefaultCameraStyle()
            end
		end)
		if not responseStatus then
			self:DefaultCameraStyle()
		end
	end)
end

type CameraServiceClient = typeof(CameraServiceClient) & {
    Networker: Networker.Client
}

return CameraServiceClient :: CameraServiceClient
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CameraServiceClient = require(ReplicatedStorage.Shared.Services.CameraService.CameraServiceClient)
local DataServiceClient = require(ReplicatedStorage.Shared.Services.DataService.DataServiceClient)

DataServiceClient:Init()
CameraServiceClient:Init()
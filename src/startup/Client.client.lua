local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CameraServiceClient = require(ReplicatedStorage.Shared.Services.CameraService.CameraServiceClient)
local DataServiceClient = require(ReplicatedStorage.Shared.Services.DataService.DataServiceClient)
local MovesetServiceClient = require(ReplicatedStorage.Shared.Services.MovesetService.MovesetServiceClient)

DataServiceClient:Init()
CameraServiceClient:Init()
MovesetServiceClient:Init()
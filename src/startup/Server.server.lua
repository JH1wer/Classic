local ServerScriptService = game:GetService("ServerScriptService")
local CameraServiceServer = require(ServerScriptService.Services.CameraService.CameraServiceServer)
local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)
local MovesetServiceServer = require(ServerScriptService.Services.MovesetService.MovesetServiceServer)

DataServiceServer:Init()
CameraServiceServer:Init()
MovesetServiceServer:Init()
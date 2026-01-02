local ServerScriptService = game:GetService("ServerScriptService")
local CameraServiceServer = require(ServerScriptService.Services.CameraService.CameraServiceServer)
local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)

DataServiceServer:Init()
CameraServiceServer:Init()
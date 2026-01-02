local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataServiceClient = require(ReplicatedStorage.Shared.Services.DataService.DataServiceClient)

DataServiceClient:Init()
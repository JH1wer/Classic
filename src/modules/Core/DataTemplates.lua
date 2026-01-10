local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MovesetServiceUtils = require(ReplicatedStorage.Shared.Services.MovesetService.MovesetServiceUtils)

local DataTemplates = {}

DataTemplates.TEMPLATE = {
  character = MovesetServiceUtils.Enums.Characters.Baller -- DEFAULT character
}

return DataTemplates
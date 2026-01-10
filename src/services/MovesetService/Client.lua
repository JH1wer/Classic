local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Networker = require(ReplicatedStorage.Packages.Networker)
local MovesetServiceUtils = require(ReplicatedStorage.Shared.Services.MovesetService.MovesetServiceUtils)

local MovesetServiceClient = {}

MovesetServiceClient.inputController = nil

function MovesetServiceClient.Init(self: MovesetServiceClient): ()
  self.Networker = Networker.client.new('MovesetService', self);
end

function MovesetServiceClient._resetInputsController(self: MovesetServiceClient): ()
  if(self.inputController) then
    self.inputController:Disconnect()
  end
end

function MovesetServiceClient.BallerSetup(self: MovesetServiceClient): ()
  self.inputController = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if(gameProcessedEvent) then
      return
    end

    print(input.KeyCode, "baller")
  end)
end

MovesetServiceClient[MovesetServiceUtils.Enums.Action.resetController] = MovesetServiceClient._resetInputsController
MovesetServiceClient[MovesetServiceUtils.Enums.Characters.Baller] = MovesetServiceClient.BallerSetup

type MovesetServiceClient = typeof(MovesetServiceClient) & {
  Networker: Networker.Client
}

return MovesetServiceClient :: MovesetServiceClient
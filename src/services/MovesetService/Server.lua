local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Networker = require(ReplicatedStorage.Packages.Networker)
local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)
local MovesetServiceUtils = require(ReplicatedStorage.Shared.Services.MovesetService.MovesetServiceUtils)

local MovesetServiceServer = {}

MovesetServiceServer.DEFAULT_CHARACTER = MovesetServiceUtils.Enums.Characters.Baller

function MovesetServiceServer.getCharacter(self: MovesetServiceServer, player: Player): number
  local character = DataServiceServer:waitData(player):Get("character");
  return character
end

function MovesetServiceServer.Init(self: MovesetServiceServer): ()
  self.Networker = Networker.server.new(script.Parent.Name, self, {
    self[MovesetServiceUtils.Enums.Action.changer]
  });
  Players.PlayerAdded:Connect(function(player)
    self:_init(player)
  end)
  for _, player: Player in Players:GetPlayers() do
    task.spawn(function()
      self:_init(player)
    end)
  end
end

function MovesetServiceServer.changer(self: MovesetServiceServer, _player: Player, characterEnum: number?): ()
  local cnumCap: number

  for _, cnum in MovesetServiceUtils.Enums.Characters do
    if(characterEnum == cnum) then
      cnumCap = cnum
      break
    end
  end

  cnumCap = cnumCap or self.DEFAULT_CHARACTER

  if(cnumCap == self.DEFAULT_CHARACTER) then
    print("mudou porra nenhuma")
    return
  end

  print("character changed")
end

function MovesetServiceServer._init(self: MovesetServiceServer, player: Player): ()
  player.CharacterAdded:Connect(function(char)
    local humanoid = char.Humanoid
    local characterSelected = self:getCharacter(player)
    self:_initializeCharacterSetup(player, characterSelected);
    humanoid.Died:Connect(function()
      self.Networker:fire(player, MovesetServiceUtils.Enums.Action.resetController)
    end)
  end)
end

function MovesetServiceServer._initializeCharacterSetup(self: MovesetServiceServer, _player: Player, characterEnum: number?): ()
  characterEnum = characterEnum
  self.Networker:fire(_player, characterEnum)
end

MovesetServiceServer[MovesetServiceUtils.Enums.Action.changer] = MovesetServiceServer.changer

type MovesetServiceServer = typeof(MovesetServiceServer) & {
  Networker: Networker.Server
}

return MovesetServiceServer :: MovesetServiceServer
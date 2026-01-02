local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)
local Networker = require(ReplicatedStorage.Packages.Networker)
local DataHandler = require(ReplicatedStorage.Shared.Classes.Handlers.DataHandler)
local DataTemplates = require(ReplicatedStorage.Shared.Modules.Core.DataTemplates)

local DataServiceServer = {
    Profiles = {} :: { [Player]: ProfileStore.Profile<any> },
    Datas = {} :: { [Player]: DataHandler.DataHandler<any> }
}

function DataServiceServer.Init(self: DataServiceServer): ()
    local StoreName = if RunService:IsStudio() then "TestPlace" else "Official"
    self.StoreGame = ProfileStore.New(StoreName, DataTemplates.TEMPLATE)
    self.Networker = Networker.server.new("DataService", self, {
        self.Get,
    })

    Players.PlayerAdded:Connect(function(Player: Player)
        self:_PlayerAddedConnect(Player)
    end)

    for _, Player: Player in Players:GetPlayers() do
        task.spawn(function()
            self:_PlayerAddedConnect(Player)
        end)
    end
end

function DataServiceServer._PlayerAddedConnect(self: DataServiceServer, Player: Player): ()
    local Profile = self.StoreGame:StartSessionAsync(tostring(Player.UserId), { Cancel = function()
        return Player.Parent ~= Players
    end})

    if Profile then
        Profile:AddUserId(Player.UserId)
        Profile:Reconcile()
        Profile.OnSessionEnd:Connect(function()
            self.Profiles[Player] = nil
            Player:Kick("Profile Session end")
        end)

        if Player:IsDescendantOf(Players) then
            self.Profiles[Player] = Profile
            
            local ProfileData = Profile.Data
            self.Datas[Player] = DataHandler.New(ProfileData)

            self.Datas[Player]._signals.save:Connect(function()
                local ThatPlayer = Player

                print("[DataServiceServer] A data de " .. ThatPlayer.DisplayName .. " foi salva!")
            end)
        else
            Profile:EndSession()
        end
    else
        Player:Kick("Profile Error")
    end
end

function DataServiceServer._PlayerRemovingConnect(self: DataServiceServer, Player: Player): ()
    local Profile = self.Profiles[Player]
    if Profile then
        Profile:EndSession()
    end
end

function DataServiceServer.Get(self: DataServiceServer, Player: Player, Path: DataHandler.Path?): any
    return self.Datas[Player]:Get(Path)
end

function DataServiceServer.Set(self: DataServiceServer, Player: Player, Path: DataHandler.Path, Value: any): ()
    self.Datas[Player]:Set(Path, Value)
end

type DataServiceServer = typeof(DataServiceServer) & {
    Networker: Networker.Server,
    StoreGame: ProfileStore.ProfileStore<any>
}

return DataServiceServer :: DataServiceServer
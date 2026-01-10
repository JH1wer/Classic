local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)
local Networker = require(ReplicatedStorage.Packages.Networker)
local DataHandler = require(ReplicatedStorage.Shared.Classes.Handlers.DataHandler)
local DataTemplates = require(ReplicatedStorage.Shared.Modules.Core.DataTemplates)
local DataServiceUtils = require(ReplicatedStorage.Shared.Services.DataService.DataServiceUtils)
local Signal = require(ReplicatedStorage.Packages.Signal)

local DataServiceServer = {
    Profiles = {} :: { [Player]: ProfileStore.Profile<any> },
    Datas = {} :: { [Player]: DataHandler.DataHandler<any> },
    _signals = {} :: { [Player]: Signal.Signal<any> }
}

function DataServiceServer.Init(self: DataServiceServer): ()
    local StoreName = if RunService:IsStudio() then "MockPlace" else "OfficialGamedata"
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

            self:_initializePlayerdata(Player, Profile.Data)
        else
            Profile:EndSession()
        end
    else
        Player:Kick("Profile Error")
    end
end

function DataServiceServer.waitData(self: DataServiceServer, Player: Player): DataHandler.DataHandler<any>
    local data = self.Datas[Player]
    if data then
        return data
    end

    local waitSignal = self._signals[Player]
    if(not waitSignal) then
        waitSignal = Signal.new()
        self._signals[Player] = waitSignal
    end

    waitSignal:Wait()
    return self.Datas[Player]
end

function DataServiceServer._initializePlayerdata(self: DataServiceServer, Player: Player, Data: any): ()
    self.Datas[Player] = DataHandler.New(Data)
    self:PlayerEvent(Player, Data)
    self.Networker:fire(Player, DataServiceUtils.Enums.Action.Init, Data)

    local waitSignal = self._signals[Player]
    if waitSignal then
        waitSignal:Fire()
        waitSignal:Destroy()
        self._signals[Player] = nil
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

function DataServiceServer.PlayerEvent(self: DataServiceServer, _Player: Player, _data: any): () end

type DataServiceServer = typeof(DataServiceServer) & {
    Networker: Networker.Server,
    StoreGame: ProfileStore.ProfileStore<any>
}

return DataServiceServer :: DataServiceServer
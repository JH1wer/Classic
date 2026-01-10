local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)
local DataHandler = require(ReplicatedStorage.Shared.Classes.Handlers.DataHandler)
local Signal = require (ReplicatedStorage.Packages.Signal)
local DataServiceUtils = require(script.Parent.DataServiceUtils)

local DataServiceClient = {
    _data = nil :: DataHandler.DataHandler<any>?
}

DataServiceClient.waiting = Signal.new()

function DataServiceClient.Init(self: DataServiceClient, data: any): ()
    self.Networker = Networker.client.new('DataService', self)

    if(data) then
        self:_init(data)
    end

    self:waitForPlayerdata()
end

function DataServiceClient.waitForPlayerdata(self: DataServiceClient): any
    local data = self._data
    if data then
        return data
    end

    self.waiting:Wait()
    return self._data
end

function DataServiceClient._init(self: DataServiceClient, data: any): ()
    self._data = DataHandler.New(data)
    self.waiting:Fire()
end

DataServiceClient[DataServiceUtils.Enums.Action.Init] = DataServiceClient._init

type DataServiceClient = typeof(DataServiceClient) & {
    Networker: Networker.Client
}

return DataServiceClient :: DataServiceClient
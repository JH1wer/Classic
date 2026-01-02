local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)
local DataServiceClient = {}

function DataServiceClient.Init(self: DataServiceClient): ()
    self.Networker = Networker.client.new('DataService', self)
end

type DataServiceClient = typeof(DataServiceClient) & {
    Networker: Networker.Client
}

return DataServiceClient :: DataServiceClient
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)

local CameraServiceServer = {}

function CameraServiceServer.Init(self: CameraServiceServer): ()
    self.Networker = Networker.server.new(tostring(script.Parent.Name), self, {})
end

type CameraServiceServer = typeof(CameraServiceServer) & {
    Networker: Networker.Server
}

return CameraServiceServer :: CameraServiceServer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Server = {}

function Server.InterceptSpecificPack(name: string, callback: (any) -> ()): ()
    if RunService:IsServer() then
        -- find pack
        local path = ReplicatedStorage.Packages:FindFirstChild("Networker")
        local container: Folder = nil
        for _, child in path:GetChildren() do
            if child:IsA("Folder") then
                container = child
                break
            end
        end

        local targetPack = nil

        if container then
            local targetContainerChild = container:FindFirstChild(name)
            if typeof(targetContainerChild) == "Folder" then
                targetPack = targetContainerChild
            end
        end

        if targetPack then
            local events = targetPack:GetChildren()
            task.spawn(function()
                while wait(1) do
                    for _, event in events do
                        if event:IsA("RemoteEvent") then
                            if RunService:IsServer() then
                                event.OnServerEvent:Connect(function(player: Player, ...)
                                    callback(player, ...)
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end
end

function Server.BlockTempReplicatedMethod(pack_name: string, method: string, time: number): () end

return Server

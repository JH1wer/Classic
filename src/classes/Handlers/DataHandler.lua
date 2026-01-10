local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)
local DataConfigs = require(ReplicatedStorage.Shared.Modules.Core.DataConfigs)
local DataServiceTypes = require(ReplicatedStorage.Shared.Services.DataService.DataServiceTypes)

local DataHandler = {}
DataHandler.__index = DataHandler

local AUTO_SAVE = DataConfigs.AUTO_SAVE
local TIME_AUTOSAVE = DataConfigs.TIME_AUTOSAVE

type DataRequest<T> = DataServiceTypes.DataRequest<T>
export type Path = DataServiceTypes.Path
export type DataHandler<T> = typeof(
    setmetatable({} :: {
        _data: T,
        _thread: thread?,
        _signals: {
            save: Signal.Signal<any>
        }
    }, DataHandler)
)

function DataHandler.New<T>(data: T): DataHandler<T> 
    local self = setmetatable({
        _data = data,
        _thread = nil,
        _signals = {
            save = Signal.new()
        }
    }, DataHandler)

    self._thread = task.spawn(function()
        if AUTO_SAVE then
            while task.wait(TIME_AUTOSAVE) do
                self._signals.save:Fire()
                -- apply last save data on PLayerData
            end
        end
    end)

    return self
end

function DataHandler.Get<T>(self: DataHandler<T>, Path: Path?): DataRequest<T>
    if not Path then
        return self._data
    end

    local data = self._data
    if type(Path) == "string" then
        return data[Path]
    end

    for _, k in Path do
        data = data[k]
    end

    return data
end

function DataHandler.Set<T>(self: DataHandler<T>, Path: Path, Value: any): ()
    local Data = self._data
    if not Value then
        return
    end

    if type(Path) == "string" then
        Data[Path] = Value
        return
    end

    for i = 1, #Path - 1 do
        local key = Path[i]
        if Data[key] == nil then
            Data[key] = {}
        end
        Data = Data[Path[i]]
    end

    Data[Path[#Path]] = Value
end

return DataHandler
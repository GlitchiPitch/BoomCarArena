local server = game.ServerScriptService.Server
local shared = game.ReplicatedStorage.Shared
local items = game.ServerStorage.Items
local timerEvent = Instance.new("RemoteEvent")

local gameModule = require(server.GameModule)
local types = require(shared.Types)

local data: types.ServerData = {
    carPrefab = items.Car :: types.Car,
    bombPrefab = items.Bomb :: types.Bomb,
    carFolder = workspace.CarFolder :: Folder & {types.Car},
    spawnPoints = workspace.SpawnPoints :: Folder,
    currentBomb = Instance.new("ObjectValue"),
}

function timer(time: number, msg: string)
    for i = 1, time do
        task.wait(1)
        timerEvent:FireAllClients(time - i, msg)
        if not msg then
            if not data.currentBomb.Value then
                break
            end
        end
    end
end

function addPoint(player: Player)
    local leaderstats = player:FindFirstChild('leaderstats') :: Folder
    local points = leaderstats:FindFirstChild('Points') :: IntValue
    points.Value += 1
end

function onPlayerAdded(player: Player)
    game.ServerStorage.leaderstats:Clone().Parent = player
end

function intermission()
    timer(5, "STARING GAME AFTER: ")

    if #game.Players:GetPlayers() < 2 then
        intermission()
    end

    for i, player in game.Players:GetPlayers() do
        if not player.Character then
            intermission()
        end
    end
end

function start()
    gameModule.start()
    timer(40)
    if data.currentBomb.Value then
        gameModule.bombExplosion()
    end
end

function finish()
    timer(5, "FINISH GAME AFTER: ")
    for i, car: types.Car in data.carFolder:GetChildren() do
        if not car.IsAlive.Value then continue end
        local humanoid = car.DriveSeat.Occupant
        if not humanoid then continue end
        humanoid.JumpPower = 50
        local player = game.Players:GetPlayerFromCharacter(humanoid.Parent)
        player:LoadCharacter()
        addPoint(player)
    end
    data.carFolder:ClearAllChildren()
end

function init()
    game.Players.PlayerAdded:Connect(onPlayerAdded)
    gameModule.init(data)

    timerEvent.Parent = game.ReplicatedStorage
    timerEvent.Name = 'TimerEvent'

    while task.wait(.1) do
        intermission()
        start()
        finish()
    end
end

init()
local shared = game.ReplicatedStorage.Shared
local types = require(shared.Types)

local data: types.ServerData
local bombTimer: thread
local BOMB_TIME = 20
local debounce = 5

function spawnCar(spawnPoint: Part)
    local car = data.carPrefab:Clone()
    car.Parent = data.carFolder
    car:PivotTo(spawnPoint.CFrame)
    return car
end

function bombExplosion()
    local hitbox = data.currentBomb.Value.Parent
    local bomber = hitbox.Parent :: types.Car
    local isAlive = bomber.IsAlive
    isAlive.Value = false

    local explosion = Instance.new("Explosion")
    explosion.Parent = data.currentBomb.Value
    explosion.Position = data.currentBomb.Value.Position
    explosion.BlastPressure = 15
    explosion.BlastRadius = 15    
    data.currentBomb.Value = nil
    stopBombTimer()
end

function sitPlayerToCar(car: types.Car, humanoid: Humanoid)
    humanoid.JumpPower = 0
    car.DriveSeat:Sit(humanoid)
end

function setupBomb(bomber: types.Car)
    local bomb = data.currentBomb.Value
    if not data.currentBomb.Value then return end
    data.currentBomb.Value.Parent = bomber.Hitbox
    data.currentBomb.Value.CFrame = bomber.Hitbox.BombAttachment.WorldCFrame
    bomber.Hitbox.Weld.Part1 = data.currentBomb.Value
    setupCar(bomber)
    startBombTimer()
end

function stopBombTimer()
    if bombTimer then
        task.cancel(bombTimer)
        bombTimer = nil
    end
end

function startBombTimer()
    stopBombTimer()
    bombTimer = task.defer(function()
        for i = 1, BOMB_TIME do
            task.wait(1)
            data.currentBomb.Value.SurfaceGui.Label.Text = BOMB_TIME - i
        end
        bombExplosion()
    end)
end

function setupCar(car: types.Car)
    local touchConnect
    task.wait(debounce)
    touchConnect = car.Hitbox.Touched:Connect(function(hit: Part)
        if hit.Name == 'Hitbox' then
            car.Hitbox.CanTouch = false
            car.Hitbox.Weld.Part1 = nil
            local bomber = hit.Parent
            setupBomb(bomber)
            car.Hitbox.CanTouch = true
            touchConnect:Disconnect()
        end
    end)

    car.Destroying:Once(function()
        if touchConnect.Connected then
            touchConnect:Disconnect()
        end 
    end)
end

function spawnBomb(bomber: types.Car)
    local bomb = data.bombPrefab:Clone()
    data.currentBomb.Value = bomb
    setupBomb(bomber)
end

function start()
    for i, player in game.Players:GetPlayers() do
        local humanoid = player.Character.Humanoid
        local car = spawnCar(data.spawnPoints[i])
        sitPlayerToCar(car, humanoid)
    end

    local cars = data.carFolder:GetChildren()
    local bomber = cars[math.random(#cars)]
    spawnBomb(bomber)
end

function init(data_)
    data = data_
end

return {
    init = init,
    spawnBomb = spawnBomb,
    start = start,
    bombExplosion = bombExplosion,
}
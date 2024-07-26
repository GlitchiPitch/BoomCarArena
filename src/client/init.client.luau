
local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui
local mainGui = playerGui:WaitForChild('Main') :: {TextLabel: TextLabel}

local timerEvent = game.ReplicatedStorage:WaitForChild('TimerEvent') :: RemoteEvent

function onTimerEvent(time: number, msg: string)
    mainGui.TextLabel.Text = (msg or '') .. time
end

timerEvent.OnClientEvent:Connect(onTimerEvent)


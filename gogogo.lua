local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = Workspace.CurrentCamera

-- Настраиваемая скорость передвижения
local SPEED = 35 

-- 1. Удаляем хуманоид (обходим античит)
local humanoid = character:FindFirstChildOfClass("Humanoid")
if humanoid then
    humanoid:Destroy()
end

-- 2. Возвращаем камеру обратно на персонажа, чтобы она не улетала
camera.CameraSubject = rootPart
camera.CameraType = Enum.CameraType.Custom

-- 3. Создаем кастомное управление на WASD
local directions = {
    W = Vector3.new(0, 0, -1),
    S = Vector3.new(0, 0, 1),
    A = Vector3.new(-1, 0, 0),
    D = Vector3.new(1, 0, 0)
}

local activeKeys = {}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then activeKeys.W = true end
    if input.KeyCode == Enum.KeyCode.S then activeKeys.S = true end
    if input.KeyCode == Enum.KeyCode.A then activeKeys.A = true end
    if input.KeyCode == Enum.KeyCode.D then activeKeys.D = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then activeKeys.W = false end
    if input.KeyCode == Enum.KeyCode.S then activeKeys.S = false end
    if input.KeyCode == Enum.KeyCode.A then activeKeys.A = false end
    if input.KeyCode == Enum.KeyCode.D then activeKeys.D = false end
end)

-- Цикл движения (каждый кадр двигаем HumanoidRootPart относительно камеры)
RunService.RenderStepped:Connect(function(dt)
    if not character or not rootPart or not rootPart.Parent then return end
    
    local moveVector = Vector3.new()
    local lookVector = camera.CFrame.LookVector
    local rightVector = camera.CFrame.RightVector
    
    -- Убираем наклон по вертикали, чтобы персонаж не летал вверх/вниз при взгляде камеры
    local flatLook = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
    local flatRight = Vector3.new(rightVector.X, 0, rightVector.Z).Unit

    if activeKeys.W then moveVector = moveVector + flatLook end
    if activeKeys.S then moveVector = moveVector - flatLook end
    if activeKeys.A then moveVector = moveVector - flatRight end
    if activeKeys.D then moveVector = moveVector + flatRight end

    if moveVector.Magnitude > 0 then
        moveVector = moveVector.Unit
        -- Перемещаем персонажа плавным шагом
        rootPart.CFrame = rootPart.CFrame + (moveVector * SPEED * dt)
        -- Поворачиваем персонажа по направлению движения
        rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + flatLook)
    end
end)

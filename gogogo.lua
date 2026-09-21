local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local currentSpeed = 35
local useCustomMove = true -- Флаг: работаем ли мы по кастомному движению

-- 1. Создаем крутое GUI с двумя кнопками
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggBypassGUI"
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 180)
frame.Position = UDim2.new(0.5, -120, 0.3, -90)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Egg Helper GUI"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 15
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- Поле ввода скорости
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0.85, 0, 0, 30)
textBox.Position = UDim2.new(0.075, 0, 0.2, 0)
textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.PlaceholderText = "Скорость..."
textBox.Text = tostring(currentSpeed)
textBox.TextSize = 14
textBox.Font = Enum.Font.SourceSans
textBox.Parent = frame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 6)
boxCorner.Parent = textBox

-- Кнопка изменения скорости
local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(0.85, 0, 0, 30)
speedButton.Position = UDim2.new(0.075, 0, 0.42, 0)
speedButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedButton.Text = "Применить скорость"
speedButton.TextSize = 13
speedButton.Font = Enum.Font.SourceSansBold
speedButton.Parent = frame

local sBtnCorner = Instance.new("UICorner")
sBtnCorner.CornerRadius = UDim.new(0, 6)
sBtnCorner.Parent = speedButton

-- Кнопка возврата хуманоида (для получения яйца!)
local restoreButton = Instance.new("TextButton")
restoreButton.Size = UDim2.new(0.85, 0, 0, 35)
restoreButton.Position = UDim2.new(0.075, 0, 0.68, 0)
restoreButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Зеленая
restoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
restoreButton.Text = "ВЕРНУТЬ ХУМАНОИД (ЯЙЦО)"
restoreButton.TextSize = 12
restoreButton.Font = Enum.Font.SourceSansBold
restoreButton.Parent = frame

local rBtnCorner = Instance.new("UICorner")
rBtnCorner.CornerRadius = UDim.new(0, 6)
rBtnCorner.Parent = restoreButton

-- Обработка кнопки скорости
speedButton.MouseButton1Click:Connect(function()
    local val = tonumber(textBox.Text)
    if val then
        currentSpeed = val
    end
end)

-- Функция удаления хуманоида (для быстрого бега)
local function removeHumanoid(char)
    if not useCustomMove then return end
    local rootPart = char:WaitForChild("HumanoidRootPart", 5)
    if not rootPart then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:Destroy()
    end

    camera.CameraSubject = rootPart
    camera.CameraType = Enum.CameraType.Custom
end

-- Обработка кнопки возврата хуманоида
restoreButton.MouseButton1Click:Connect(function()
    useCustomMove = false -- Отключаем кастомное движение, чтобы вернуть контроль игре
    
    local char = player.Character
    if char then
        -- Проверяем, есть ли уже хуманоид, если нет — создаем стандартный
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            humanoid = Instance.new("Humanoid")
            humanoid.Parent = char
        end
        humanoid.WalkSpeed = 16 -- Возвращаем нормальную скорость для безопасности
        
        -- Возвращаем камере стандартный субъект
        camera.CameraSubject = humanoid
        
        -- Сбрасываем платформу/партию, чтобы сервер обновил состояние игрока
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end
end)

-- Инициализация при старте персонажа
local function onCharacterAdded(char)
    useCustomMove = true
    task.wait(0.5) -- Небольшая задержка, чтобы персонаж успел прогрузиться
    if useCustomMove then
        removeHumanoid(char)
    end
end

if player.Character then
    task.spawn(function()
        onCharacterAdded(player.Character)
    end)
end

player.CharacterAdded:Connect(onCharacterAdded)

-- Управление на WASD без хуманоида
local activeKeys = {W = false, S = false, A = false, D = false}

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

RunService.RenderStepped:Connect(function(dt)
    if not useCustomMove then return end -- Если нажали вернуть хуманоид — скрипт движения молчит
    
    local char = player.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local moveVector = Vector3.new()
    local lookVector = camera.CFrame.LookVector
    local rightVector = camera.CFrame.RightVector
    
    local flatLook = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
    local flatRight = Vector3.new(rightVector.X, 0, rightVector.Z).Unit

    if activeKeys.W then moveVector = moveVector + flatLook end
    if activeKeys.S then moveVector = moveVector - flatLook end
    if activeKeys.A then moveVector = moveVector - flatRight end
    if activeKeys.D then moveVector = moveVector + flatRight end

    if moveVector.Magnitude > 0 then
        moveVector = moveVector.Unit
        rootPart.CFrame = rootPart.CFrame + (moveVector * currentSpeed * dt)
        rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + flatLook)
    end
end)

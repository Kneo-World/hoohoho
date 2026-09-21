---ваыуаыуаы
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Переменная скорости (по умолчанию 35)
local currentSpeed = 35

-- 1. Создаем GUI для управления скоростью
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BypassSpeedGUI"
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0.5, -110, 0.3, -70)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "Anti-Cheat Bypass Speed"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize: 14
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0.8, 0, 0, 35)
textBox.Position = UDim2.new(0.1, 0, 0.3, 0)
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

local button = Instance.new("TextButton")
button.Size = UDim2.new(0.8, 0, 0, 35)
button.Position = UDim2.new(0.1, 0, 0.65, 0)
button.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = "Изменить скорость"
button.TextSize = 14
button.Font = Enum.Font.SourceSansBold
button.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = button

button.MouseButton1Click:Connect(function()
    local val = tonumber(textBox.Text)
    if val then
        currentSpeed = val
    end
end)

-- 2. Функция настройки персонажа (удаление хуманоида + фикс камеры)
local function setupCharacter(char)
    local rootPart = char:WaitForChild("HumanoidRootPart", 5)
    if not rootPart then return end

    -- Удаляем хуманоид, чтобы сервер не кикал за WalkSpeed
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:Destroy()
    end

    -- Возвращаем камеру на персонажа
    camera.CameraSubject = rootPart
    camera.CameraType = Enum.CameraType.Custom
end

if player.Character then
    setupCharacter(player.Character)
end

player.CharacterAdded:Connect(setupCharacter)

-- 3. Кастомное управление на WASD без хуманоида
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
        -- Двигаем персонажа через CFrame с учетом введенной в GUI скорости
        rootPart.CFrame = rootPart.CFrame + (moveVector * currentSpeed * dt)
        rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + flatLook)
    end
end)

-- Загрузка интерфейса Rayfield67
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Steal the Egg | Anti-Cheat Bypass Hub",
   LoadingTitle = "Bypass Loader...",
   LoadingSubtitle = "by Assistant",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Создаём вкладки
local MainTab = Window:CreateTab("Bypass Features", 4483362458)
local LocalTab = Window:CreateTab("Movement", 4483362458)

-- Переменные и сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local CFrameFlyEnabled = false
local FlySpeed = 1.5
local NoclipEnabled = false
local AutoProximity = false

-- ===== 1. CFrame Fly (Обход детектора WalkSpeed) =====
RunService.RenderStepped:Connect(function()
    if CFrameFlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local camera = workspace.CurrentCamera
        local moveDir = Vector3.new()

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end

        if moveDir.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (moveDir.Unit * FlySpeed)
            hrp.Velocity = Vector3.new(0, 0, 0) -- Обнуляем физическую скорость, чтобы античит не флагал
        end
    end
end)

-- ===== 2. Noclip (Безопасный проход сквозь стены) =====
RunService.Stepped:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ===== 3. Auto Collect Eggs (Автовзаимодействие с ProximityPrompt) =====
task.spawn(function()
    while task.wait(0.2) do
        if AutoProximity then
            for _, prompt in pairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    -- Изменяем параметры так, чтобы забирать яйцо мгновенно
                    prompt.HoldDuration = 0
                    fireproximityprompt(prompt)
                end
            end
        end
    end
end)

-- ===== ЭЛЕМЕНТЫ GUI =====

-- Полёт CFrame
MainTab:CreateToggle({
   Name = "Bypass Fly (CFrame)",
   CurrentValue = false,
   Callback = function(Value)
      CFrameFlyEnabled = Value
   end,
})

-- Скорость полета
MainTab:CreateSlider({
   Name = "Fly Speed (Безопасная скорость)",
   Range = {0.5, 5},
   Increment = 0.1,
   Suffix = "Speed",
   CurrentValue = 1.5,
   Callback = function(Value)
      FlySpeed = Value
   end,
})

-- Noclip
LocalTab:CreateToggle({
   Name = "Noclip (Сквозь стены)",
   CurrentValue = false,
   Callback = function(Value)
      NoclipEnabled = Value
   end,
})

-- Авто-сбор яиц
MainTab:CreateToggle({
   Name = "Instant Steal Eggs (Быстрый забор)",
   CurrentValue = false,
   Callback = function(Value)
      AutoProximity = Value
   end,
})

-- Уведомление
Rayfield:Notify({
   Title = "Anti-Cheat Bypass Active",
   Content = "Скрипт готов к работе в Delta!",
   Duration = 4,
   Image = 4483362458,
})

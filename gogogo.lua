local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
---323232

local Window = Rayfield:CreateWindow({
   Name = "Steal the Egg | Hard Bypass",
   LoadingTitle = "Bypassing Anti-Cheat...",
   LoadingSubtitle = "by Assistant",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("Anti-Cheat Bypass", 4483362458)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local BypassVelocityFly = false
local FlySpeed = 25
local AntiVoid = false

-- ===== 1. BYPASS MOVEMENT (Через AssemblyLinearVelocity) =====
-- Этот метод обходит проверки CFrame, так как двигает физическое тело
RunService.Heartbeat:Connect(function()
    if BypassVelocityFly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local cam = workspace.CurrentCamera
        local moveVector = Vector3.new()

        local uis = game:GetService("UserInputService")
        if uis:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + cam.CFrame.RightVector end

        if moveVector.Magnitude > 0 then
            hrp.AssemblyLinearVelocity = moveVector.Unit * FlySpeed
        else
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0.01, 0) -- Легкая микро-гравитация, чтобы не кикало за зависание
        end
    end
end)

-- ===== 2. TWEEN TELEPORT (Плавный телепорт к яйцу) =====
-- Вставь сюда координаты яйца или выбери объект
local function safeTeleport(targetCFrame)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local timeToTravel = distance / 20 -- Скорость 20 студ/сек безопасна для античита

        local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
    end
end

-- ===== 3. GODMODE / ANTI-KILL (Блокировка урона) =====
local function applyAntiKill()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        -- Отключаем сработку состояния смерти на клиенте
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end
end

-- ===== GUI ЭЛЕМЕНТЫ =====

MainTab:CreateToggle({
   Name = "Velocity Fly Bypass (Полёт)",
   CurrentValue = false,
   Callback = function(Value)
      BypassVelocityFly = Value
      applyAntiKill()
   end,
})

MainTab:CreateSlider({
   Name = "Bypass Speed (Не ставь больше 30!)",
   Range = {10, 500},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 25,
   Callback = function(Value)
      FlySpeed = Value
   end,
})

MainTab:CreateButton({
   Name = "Instant Grab Egg (Мгновенный забор)",
   Callback = function()
      for _, prompt in pairs(workspace:GetDescendants()) do
          if prompt:IsA("ProximityPrompt") then
              fireproximityprompt(prompt)
          end
      end
   end,
})

Rayfield:Notify({
   Title = "Bypass Ready",
   Content = "Используй Velocity Fly и не завышай скорость!",
   Duration = 4,
})

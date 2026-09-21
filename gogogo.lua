-- Загрузка библиотеки интерфейса Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Rivals Script | Delta Hub",
   LoadingTitle = "Rivals Menu",
   LoadingSubtitle = "by Assistant",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Создаём вкладки
local MainTab = Window:CreateTab("Main (Combat)", 4483362458)
local LocalTab = Window:CreateTab("Player Settings", 4483362458)

-- Сервисы и переменные
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

local AimbotEnabled = false
local AimKeyHeld = false
local ESPEnabled = false
local InfJumpEnabled = false
local CustomSpeed = 16

-- ===== 1. AIMBOT LOGIC =====
local function getClosestEnemy()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            -- Проверка на команду (если есть тимы)
            if player.Team == nil or player.Team ~= LocalPlayer.Team then
                local head = player.Character.Head
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closestPlayer
end

game:GetService("RunService").RenderStepped:Connect(function()
    if AimbotEnabled and AimKeyHeld then
        local target = getClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
        AimKeyHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
        AimKeyHeld = false
    end
end)

-- ===== 2. ESP LOGIC =====
local function applyESP(player)
    if player == LocalPlayer then return end
    
    local function highlightCharacter(character)
        if not character then return end
        
        -- Ждем появление ключевых частей
        character:WaitForChild("HumanoidRootPart", 5)
        
        if not character:FindFirstChild("ESPHighlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            highlight.Adornee = character
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.Enabled = ESPEnabled
            highlight.Parent = character
        end
    end

    if player.Character then highlightCharacter(player.Character) end
    player.CharacterAdded:Connect(highlightCharacter)
end

for _, p in pairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

-- ===== 3. INFINITE JUMP =====
UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)


-- ===== ЭЛЕМЕНТЫ ИНТЕРФЕЙСА (GUI) =====

-- Переключатель Аимбота
MainTab:CreateToggle({
   Name = "Enable Aimbot (Зажми ПКМ / Экран)",
   CurrentValue = false,
   Callback = function(Value)
      AimbotEnabled = Value
   end,
})

-- Переключатель ESP (ВХ)
MainTab:CreateToggle({
   Name = "Enable Wallhack (ESP)",
   CurrentValue = false,
   Callback = function(Value)
      ESPEnabled = Value
      for _, player in pairs(Players:GetPlayers()) do
          if player.Character and player.Character:FindFirstChild("ESPHighlight") then
              player.Character.ESPHighlight.Enabled = ESPEnabled
          end
      end
   end,
})

-- Ползунок Скорости
LocalTab:CreateSlider({
   Name = "WalkSpeed (Скорость)",
   Range = {16, 120},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Callback = function(Value)
      CustomSpeed = Value
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
          LocalPlayer.Character.Humanoid.WalkSpeed = CustomSpeed
      end
   end,
})

-- Переключатель Бесконечного Прыжка
LocalTab:CreateToggle({
   Name = "Infinite Jump (Бесконечный прыжок)",
   CurrentValue = false,
   Callback = function(Value)
      InfJumpEnabled = Value
   end,
})

-- Уведомление о загрузке
Rayfield:Notify({
   Title = "Rivals Script Loaded!",
   Content = "Скрипт успешно активирован в Delta.",
   Duration = 5,
   Image = 4483362458,
})

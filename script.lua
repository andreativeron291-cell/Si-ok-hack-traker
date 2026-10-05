--[[
    Script: Advanced Troll Attacher GUI (Fixed & Enhanced)
    Branding: gg_script26
    Features: Stable Target Follower, Instant Teleport, Modern UI
]]--

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Rimuovi GUI precedenti per evitare duplicati
if CoreGui:FindFirstChild("GG_TrollAttacher_Hub") then
    CoreGui.GG_TrollAttacher_Hub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GG_TrollAttacher_Hub"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

--------------------------------------------------------------------------------
-- INTERFACCIA GRAFICA (GUI)
--------------------------------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -130)
MainFrame.Size = UDim2.new(0, 380, 0, 260)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 69, 0)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

local Header = Instance.new("TextLabel")
Header.Parent = MainFrame
Header.BackgroundTransparency = 1
Header.Position = UDim2.new(0, 15, 0, 12)
Header.Size = UDim2.new(0, 350, 0, 25)
Header.Font = Enum.Font.GothamBold
Header.Text = "Troll Attacher (Fix) — gg_script26"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.TextSize = 14

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
CloseBtn.Position = UDim2.new(1, -32, 0, 12)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 11

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Casella per il nome del bersaglio
local TargetBox = Instance.new("TextBox")
TargetBox.Parent = MainFrame
TargetBox.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
TargetBox.Position = UDim2.new(0, 15, 0, 50)
TargetBox.Size = UDim2.new(0, 350, 0, 45)
TargetBox.Font = Enum.Font.Gotham
TargetBox.PlaceholderText = "Scrivi il nome del bersaglio (es. utente)..."
TargetBox.Text = ""
TargetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 160)
TargetBox.TextSize = 13
TargetBox.ClearTextOnFocus = false

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 8)
BoxCorner.Parent = TargetBox

local BoxStroke = Instance.new("UIStroke")
BoxStroke.Color = Color3.fromRGB(70, 70, 95)
BoxStroke.Thickness = 1.5
BoxStroke.Parent = TargetBox

-- Pulsante Attiva/Disattiva Aggancio Stabile
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = MainFrame
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 69, 0)
ToggleBtn.Position = UDim2.new(0, 15, 0, 110)
ToggleBtn.Size = UDim2.new(0, 350, 0, 45)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "ATTIVA AGGANCIO (OFF)"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 13

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleBtn

-- Pulsante Teletrasporto Rapido
local TpBtn = Instance.new("TextButton")
TpBtn.Parent = MainFrame
TpBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
TpBtn.Position = UDim2.new(0, 15, 0, 165)
TpBtn.Size = UDim2.new(0, 350, 0, 35)
TpBtn.Font = Enum.Font.GothamBold
TpBtn.Text = "TELETRASPORTATI SUL BERSAGLIO"
TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpBtn.TextSize = 12

local TpCorner = Instance.new("UICorner")
TpCorner.CornerRadius = UDim.new(0, 8)
TpCorner.Parent = TpBtn

-- Crediti firmati
local Credits = Instance.new("TextLabel")
Credits.Parent = MainFrame
Credits.BackgroundTransparency = 1
Credits.Position = UDim2.new(0, 15, 0, 215)
Credits.Size = UDim2.new(0, 350, 0, 20)
Credits.Font = Enum.Font.GothamSemibold
Credits.Text = "Creato da gg_script26"
Credits.TextColor3 = Color3.fromRGB(140, 140, 160)
Credits.TextSize = 11
Credits.TextXAlignment = Enum.TextXAlignment.Center

--------------------------------------------------------------------------------
-- LOGICA DI AGGANCIO CORRETTA
--------------------------------------------------------------------------------
local isAttached = false
local connection = nil

local function GetTarget(nameFragment)
    if nameFragment == "" then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Name:lower():sub(1, #nameFragment) == nameFragment:lower() or 
               player.DisplayName:lower():sub(1, #nameFragment) == nameFragment:lower() then
                return player
            end
        end
    end
    return nil
end

-- Teletrasporto istantaneo sicuro
TpBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local target = GetTarget(TargetBox.Text)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                myChar.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end)
end)

-- Sistema di aggancio continuo potenziato
ToggleBtn.MouseButton1Click:Connect(function()
    isAttached = not isAttached
    
    if isAttached then
        ToggleBtn.Text = "ATTIVA AGGANCIO (ON)"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
        
        connection = RunService.Stepped:Connect(function()
            pcall(function()
                local target = GetTarget(TargetBox.Text)
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local myChar = LocalPlayer.Character
                    if myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar:FindFirstChildOfClass("Humanoid") then
                        -- Disattiva temporaneamente la gravità/velocità nativa per evitare contrasti
                        myChar.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                        myChar.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.5)
                    end
                end
            end)
        end)
    else
        ToggleBtn.Text = "ATTIVA AGGANCIO (OFF)"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 69, 0)
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
end)

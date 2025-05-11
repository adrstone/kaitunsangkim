-- Tối ưu đồ họa
local decalsyeeted = true
local g = game
local w = g.Workspace
local l = g.Lighting
local t = w.Terrain
local Players = g:GetService("Players")
local RunService = g:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Tối ưu nước
t.WaterWaveSize = 0
t.WaterWaveSpeed = 0
t.WaterReflectance = 0
t.WaterTransparency = 0

-- Ánh sáng & môi trường
l.GlobalShadows = false
l.FogEnd = 9e9
l.Brightness = 0

-- Chất lượng thấp
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

-- Tối ưu từng object
local function optimizePart(v)
    if (v:IsA("BasePart") or v:IsA("Part")) and not v:IsA("MeshPart") then
        v.Material = Enum.Material.Plastic
        v.Reflectance = 0
    elseif (v:IsA("Decal") or v:IsA("Texture")) and decalsyeeted then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0)
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1
        v.BlastRadius = 1
    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
        v.Enabled = false
    elseif v:IsA("MeshPart") and decalsyeeted then
        v.Material = Enum.Material.Plastic
        v.Reflectance = 0
        v.TextureID = "rbxassetid://0"
        v.Color = Color3.fromRGB(0, 0, 0)
    elseif v:IsA("SpecialMesh") and decalsyeeted then
        v.TextureId = ""
    elseif v:IsA("ShirtGraphic") and decalsyeeted then
        v.Graphic = ""
    elseif (v:IsA("Shirt") or v:IsA("Pants")) and decalsyeeted then
        local prop = v.ClassName .. "Template"
        if v[prop] ~= nil then
            v[prop] = ""
        end
    end
end

for _, v in pairs(w:GetDescendants()) do
    optimizePart(v)
end

local function optimizeLightingEffect(effect)
    if effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") or effect:IsA("DepthOfFieldEffect") then
        effect.Enabled = false
    end
end

for _, effect in pairs(l:GetChildren()) do
    optimizeLightingEffect(effect)
end

l.ChildAdded:Connect(optimizeLightingEffect)
w.DescendantAdded:Connect(function(v)
    task.wait()
    optimizePart(v)
end)

-- GUI FPS
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FPSGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 100
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local textLabel = Instance.new("TextLabel")
textLabel.Parent = screenGui
textLabel.Size = UDim2.new(0, 300, 0, 50)
textLabel.Position = UDim2.new(0, 10, 0, 10)
textLabel.Font = Enum.Font.FredokaOne
textLabel.TextScaled = true
textLabel.BackgroundTransparency = 1
textLabel.TextStrokeTransparency = 0

local hue = 0
local frameCount = 0
local lastUpdate = tick()

RunService.RenderStepped:Connect(function()
    hue = hue + 0.005
    if hue > 1 then hue = 0 end
    textLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)

    frameCount = frameCount + 1
    local now = tick()
    if now - lastUpdate >= 1 then
        local fps = frameCount / (now - lastUpdate)
        frameCount = 0
        lastUpdate = now

        textLabel.Text = string.format("%s | FPS: %d", LocalPlayer.Name, math.floor(fps))
    end
end)

-- Auto Enter & Spin
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Replicator = ReplicatedStorage:WaitForChild("Replicator")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local spinButton = nil

while not spinButton do
    local success, result = pcall(function()
        return gui:WaitForChild("UI")
            :WaitForChild("MainMenu")
            :WaitForChild("Buttons")
            :FindFirstChild("Spin")
    end)
    if success and result and result:IsA("GuiButton") and result.Visible then
        spinButton = result
    end
    task.wait(0.2)
end

spinButton.Selectable = true
GuiService.SelectedObject = spinButton
task.wait(0.5)

for i = 1, 3 do
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    task.wait(0.5)
end

task.wait(10)

local rareFruits = {
    "DarkXQuake", "DragonV2", "DoughV2", "Nika", "LeopardV2",
    "Ope", "Okuchi", "Soul", "Lightning"
}

local function isRare(fruitName)
    for _, v in pairs(rareFruits) do
        if string.lower(v) == string.lower(fruitName) then
            return true
        end
    end
    return false
end

local currentSlot = 1
local maxSlot = 4
local autoSpin = true

local function getEquippedFruit()
    local slotValue = player:FindFirstChild("MAIN_DATA") and player.MAIN_DATA.Slots[tostring(currentSlot)]
    return slotValue and slotValue.Value or nil
end

while autoSpin do
    local equipped = getEquippedFruit()
    if equipped and isRare(equipped) then
        if currentSlot < maxSlot then
            currentSlot += 1
            Replicator:InvokeServer("FruitsHandler", "SwitchSlot", {Slot = currentSlot})
            task.wait(1.5)
        else
            autoSpin = false
            break
        end
    else
        Replicator:InvokeServer("FruitsHandler", "Spin", {})
        task.wait(2.5)
    end
    task.wait(1)
end

-- Auto redeem code
local codes = {
    "WOW850", "860KHYPEE", "870OMG!", "LOLX880K!", "IAMLEOPARD",
    "BIGUPDATE20", "ANTICIPATION", "BIGDAY", "MAGNIFICENT890K!!",
    "OMG9HUNDRED!", "WOWZER910", "HYPEE920K!", "930KINS4NITY"
}

task.delay(5, function()
    for _, code in ipairs(codes) do
        local args = {
            [1] = "Codes",
            [2] = "Redeem",
            [3] = {
                ["Code"] = code
            }
        }

        local result
        local success, errorMsg = pcall(function()
            result = Replicator:InvokeServer(unpack(args))
        end)

        if success then
            print("Đã thử code:", code, "=> Kết quả:", result)
        else
            print("Lỗi khi thử code:", code, "=> Lỗi:", errorMsg)
        end
        task.wait(1)
    end
end)
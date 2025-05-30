--// AUTO REDEEM CODE TRƯỚC
local codes = {
    "WOW850", "860KHYPEE", "870OMG!", "LOLX880K!", "IAMLEOPARD",
    "BIGUPDATE20", "ANTICIPATION", "BIGDAY", "MAGNIFICENT890K!!",
    "OMG9HUNDRED!", "WOWZER910", "HYPEE920K!", "930KINS4NITY"
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Replicator = ReplicatedStorage:WaitForChild("Replicator")

for _, code in ipairs(codes) do
    local args = {"Codes", "Redeem", {["Code"] = code}}
    local success, result = pcall(function()
        return Replicator:InvokeServer(unpack(args))
    end)
    if success then
        print("Đã thử code:", code, "=>", result)
    else
        print("Lỗi code:", code)
    end
    task.wait(1)
end

--// AUTO NHẤN NÚT SPIN + ENTER
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local spinButton = nil

while not spinButton do
    local success, result = pcall(function()
        return gui:WaitForChild("UI"):WaitForChild("MainMenu")
            :WaitForChild("Buttons"):FindFirstChild("Spin")
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

--// AUTO SPIN TÌM TRÁI HIẾM
local rareFruits = {
    "DarkXQuake", "DragonV2", "DoughV2", "Nika", "LeopardV2",
    "Ope", "Okuchi", "Soul", "Lightning"
}

local function isRare(fruitName)
    for _, v in ipairs(rareFruits) do
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
    local slot = player:FindFirstChild("MAIN_DATA") and player.MAIN_DATA.Slots[tostring(currentSlot)]
    return slot and slot.Value or nil
end

while autoSpin do
    local equipped = getEquippedFruit()
    print("Slot", currentSlot, "cầm:", equipped)
    if equipped and isRare(equipped) then
        print("Gặp trái hiếm:", equipped)
        if currentSlot < maxSlot then
            currentSlot += 1
            Replicator:InvokeServer("FruitsHandler", "SwitchSlot", {Slot = currentSlot})
            task.wait(1.5)
        else
            print("Dừng spin, hết slot")
            autoSpin = false
            break
        end
    else
        print("Spin tiếp...")
        Replicator:InvokeServer("FruitsHandler", "Spin", {})
        task.wait(2.5)
    end
    task.wait(1)
end

--// TỐI ƯU ĐỒ HỌA + HIỆN FPS
local decalsyeeted = true
local g = game
local w = g.Workspace
local l = g.Lighting
local t = w.Terrain
local Players = g:GetService("Players")
local RunService = g:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

t.WaterWaveSize, t.WaterWaveSpeed, t.WaterReflectance, t.WaterTransparency = 0, 0, 0, 0
l.GlobalShadows, l.FogEnd, l.Brightness = false, 9e9, 0
pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)

local function optimizePart(v)
    if (v:IsA("BasePart") or v:IsA("Part")) and not v:IsA("MeshPart") then
        v.Material = Enum.Material.Plastic
        v.Reflectance = 0
    elseif (v:IsA("Decal") or v:IsA("Texture")) and decalsyeeted then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0)
    elseif v:IsA("Explosion") then
        v.BlastPressure, v.BlastRadius = 1, 1
    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
        v.Enabled = false
    elseif v:IsA("MeshPart") and decalsyeeted then
        v.Material, v.Reflectance, v.TextureID, v.Color =
            Enum.Material.Plastic, 0, "rbxassetid://0", Color3.fromRGB(0, 0, 0)
    elseif v:IsA("SpecialMesh") and decalsyeeted then
        v.TextureId = ""
    elseif v:IsA("ShirtGraphic") and decalsyeeted then
        v.Graphic = ""
    elseif (v:IsA("Shirt") or v:IsA("Pants")) and decalsyeeted then
        local prop = v.ClassName .. "Template"
        if v[prop] then v[prop] = "" end
    end
end

for _, v in pairs(w:GetDescendants()) do optimizePart(v) end
for _, effect in pairs(l:GetChildren()) do
    if effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or
       effect:IsA("BloomEffect") or effect:IsA("DepthOfFieldEffect") then
        effect.Enabled = false
    end
end

l.ChildAdded:Connect(function(e)
    if e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or
       e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
        e.Enabled = false
    end
end)

w.DescendantAdded:Connect(function(v)
    task.wait()
    optimizePart(v)
end)

-- Hiển thị FPS cầu vồng + tên
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name, screenGui.ResetOnSpawn, screenGui.DisplayOrder = "FPSGui", false, 100

local textLabel = Instance.new("TextLabel", screenGui)
textLabel.Size, textLabel.Position = UDim2.new(0, 300, 0, 50), UDim2.new(0, 10, 0, 10)
textLabel.Font, textLabel.TextScaled = Enum.Font.FredokaOne, true
textLabel.BackgroundTransparency, textLabel.TextStrokeTransparency = 1, 0

local hue, frameCount, lastUpdate = 0, 0, tick()
RunService.RenderStepped:Connect(function()
    hue = (hue + 0.005) % 1
    textLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
    frameCount += 1
    if tick() - lastUpdate >= 1 then
        textLabel.Text = string.format("%s | FPS: %d", LocalPlayer.Name, math.floor(frameCount / (tick() - lastUpdate)))
        frameCount, lastUpdate = 0, tick()
    end
end)

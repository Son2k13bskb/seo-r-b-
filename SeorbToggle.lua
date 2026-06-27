local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local fluentGUI = playerGui.FluentUI

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SeorbToggleGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local button = Instance.new("ImageButton")
button.Size = UDim2.new(0, 60,0, 60)
button.Position = UDim2.new(0.012, 0,0.888, 0)
button.BorderSizePixel = 0
button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
button.Image = "rbxassetid://90860550018720"
button.ZIndex = 10
button.Parent = screenGui

local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(0, 40)
uicorner.Parent = button

local uistroke = Instance.new("UIStroke")
uistroke.Color = Color3.fromRGB(255,0,0)
uistroke.Thickness = 2.4
uistroke.Parent = button

local isOn = false

button.MouseButton1Click:Connect(function()
	fluentGUI.Enabled = not fluentGUI.Enabled
end)

-- Load Script Main từ GitHub
print("Đang load Seorb Main Script...")
local success, err = pcall(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Son2k13bskb/seo-r-b-/refs/heads/main/Main.lua"))()
end)

if success then
	print("Seorb main script đã được tải")
else
	warn("❌ Load thất bại: " .. tostring(err))
end

-- Thông báo
game.StarterGui:SetCore("SendNotification", {
	Title = "Seorb Hub",
	Text = "Nút toggle đã xuất hiện!\nNhấn để bật/tắt auto farm.",
	Duration = 8
})

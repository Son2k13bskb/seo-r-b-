-- BƯỚC 1: TẠO NÚT ĐÓNG MỞ (MOBILE/PC)
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- Đặt tên và chọn vị trí hiển thị an toàn
ScreenGui.Name = "SeorbHubToggle"
ScreenGui.Parent = game.CoreGui or game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Cấu hình nút (Có thể kéo thả)
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleButton.Position = UDim2.new(0.1, 0, 0.1, 0)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "S"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 22
ToggleButton.Active = true
ToggleButton.Draggable = true 

-- Bo tròn nút
UICorner.CornerRadius = UDim.new(0.5, 0)
UICorner.Parent = ToggleButton

-- Tạo hiệu ứng mô phỏng phím RightControl để đóng mở Menu Fluent
local VirtualInputManager = game:GetService("VirtualInputManager")
ToggleButton.MouseButton1Click:Connect(function()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
end)

-- BƯỚC 2: GỌI SCRIPT CHÍNH TỪ GITHUB
local MainScriptURL = "LINK_RAW_GITHUB_CUA_BAN_THAY_VAO_DAY"
pcall(function()
    loadstring(game:HttpGet(MainScriptURL))()
end)

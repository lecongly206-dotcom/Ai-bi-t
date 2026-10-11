-- Language: Luau | File: Khanh_Hub_UI_Delta.lua
-- UI-only Khanh Hub mockup for Delta-style mobile screens.
-- Buttons and toggles update the interface; they do not automate or modify Blox Fruits gameplay.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("KhanhHubUI")
if old then old:Destroy() end

local C = {
    bg = Color3.fromRGB(3, 10, 15),
    panel = Color3.fromRGB(7, 17, 23),
    panel2 = Color3.fromRGB(10, 25, 33),
    cyan = Color3.fromRGB(0, 225, 240),
    cyan2 = Color3.fromRGB(0, 150, 170),
    text = Color3.fromRGB(235, 245, 250),
    muted = Color3.fromRGB(150, 173, 185),
    green = Color3.fromRGB(0, 230, 105),
    yellow = Color3.fromRGB(255, 220, 0),
    red = Color3.fromRGB(255, 80, 90),
}
local state = { farm = false, quest = true, travel = true, skip = true, buy = false, lowLag = true, minimized = false }
local currentTab = "Home"

local gui = Instance.new("ScreenGui")
gui.Name = "KhanhHubUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = playerGui

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function corner(obj, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, obj)
end
local function stroke(obj, color, thickness)
    make("UIStroke", {Color = color or C.cyan, Thickness = thickness or 1, Transparency = 0.15}, obj)
end
local function label(parent, text, pos, size, fontSize, color, bold)
    return make("TextLabel", {
        BackgroundTransparency = 1, Text = text, Position = pos, Size = size,
        Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextSize = fontSize, TextColor3 = color or C.text,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
    }, parent)
end

local panel = make("Frame", {
    Name = "MainPanel", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.51), Size = UDim2.new(0.94, 0, 0.82, 0),
    BackgroundColor3 = C.bg, BorderSizePixel = 0,
}, gui)
panel.Size = UDim2.new(0.94, 0, 0.82, 0)
panel.ClipsDescendants = true
corner(panel, 20); stroke(panel, C.cyan, 2)
make("UISizeConstraint", {MinSize = Vector2.new(320, 300), MaxSize = Vector2.new(1100, 760)}, panel)

-- Small moving star particles, clipped inside the main panel.
local stars = make("Frame", {Name="Stars", BackgroundTransparency=1, Size=UDim2.fromScale(1,1), ZIndex=1}, panel)
for i = 1, 34 do
    local dot = make("Frame", {
        Size = UDim2.fromOffset(i % 5 == 0 and 3 or 2, i % 5 == 0 and 3 or 2),
        Position = UDim2.fromScale(((i * 37) % 97) / 100, ((i * 61) % 91) / 100),
        BackgroundColor3 = C.cyan, BackgroundTransparency = 0.25 + ((i % 4) * 0.14),
        BorderSizePixel = 0, ZIndex = 1,
    }, stars)
    corner(dot, 5)
    task.spawn(function()
        while dot.Parent do
            local x = math.clamp(dot.Position.X.Scale + ((i % 2 == 0) and 0.07 or -0.07), 0.01, 0.96)
            local y = math.clamp(dot.Position.Y.Scale + ((i % 3 == 0) and -0.05 or 0.05), 0.01, 0.95)
            local tw = TweenService:Create(dot, TweenInfo.new(2.4 + (i % 5) * 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position=UDim2.fromScale(x,y)})
            tw:Play(); tw.Completed:Wait()
        end
    end)
end

local header = make("Frame", {
    BackgroundColor3 = C.panel, BackgroundTransparency = 0.06,
    Size = UDim2.new(1, 0, 0, 76), ZIndex = 3,
}, panel)
local title = label(header, "♛  Khanh Hub – Blox Fruits", UDim2.fromOffset(20, 7), UDim2.new(0.60, 0, 0, 31), 22, C.cyan, true)
label(header, "Farm faster. Level up easier.", UDim2.fromOffset(61, 39), UDim2.new(0.54, 0, 0, 22), 14, C.text, false)
label(header, "User: Guest", UDim2.new(0.73, 0, 0, 13), UDim2.new(0.16, 0, 0, 22), 14, C.green, true)
label(header, "v1.1.0 • UI Demo", UDim2.new(0.75, 0, 0, 39), UDim2.new(0.16, 0, 0, 20), 12, C.muted, false)

local function topButton(text, xScale, width)
    local b = make("TextButton", {
        Text = text, Position = UDim2.new(xScale, 0, 0, 17), Size = UDim2.fromOffset(width, 38),
        BackgroundColor3 = C.panel2, TextColor3 = C.cyan, Font = Enum.Font.GothamBold,
        TextSize = 18, BorderSizePixel = 0, ZIndex = 4,
    }, header)
    corner(b, 9); stroke(b, C.cyan2, 1)
    return b
end
local minBtn = topButton("−", 0.88, 38)
local closeBtn = topButton("×", 0.93, 38)

local body = make("Frame", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 88),
    Size = UDim2.new(1, -24, 1, -100), ZIndex = 2,
}, panel)

local sidebar = make("Frame", {
    BackgroundColor3 = C.panel, BackgroundTransparency = 0.06,
    Size = UDim2.new(0.19, 0, 1, -66), BorderSizePixel = 0,
}, body)
corner(sidebar, 13); stroke(sidebar, Color3.fromRGB(26, 62, 73), 1)
local tabNames = {
    {"⌂", "Home"}, {"⚔", "Auto Farm"}, {"▣", "Quest"}, {"♧", "Teleports"},
    {"▥", "Stats"}, {"◇", "Items"}, {"⚙", "Settings"},
}
local tabButtons = {}
local content = make("ScrollingFrame", {
    Name = "Content", BackgroundTransparency = 1,
    Position = UDim2.new(0.205, 0, 0, 0), Size = UDim2.new(0.795, 0, 1, 0),
    BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = C.cyan,
    CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, body)
make("UIListLayout", {Padding=UDim.new(0,10), SortOrder=Enum.SortOrder.LayoutOrder}, content)
make("UIPadding", {PaddingBottom=UDim.new(0,8), PaddingRight=UDim.new(0,4)}, content)

local statusText
local function setStatus(s)
    if statusText and statusText.Parent then statusText.Text = "Trạng thái: " .. s end
end

local function clearContent()
    for _, child in ipairs(content:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then child:Destroy() end
    end
end

local function card(titleText, height)
    local f = make("Frame", {
        BackgroundColor3 = C.panel, BackgroundTransparency = 0.02,
        Size = UDim2.new(1, -3, 0, height), BorderSizePixel = 0,
    }, content)
    corner(f, 13); stroke(f, Color3.fromRGB(0, 120, 140), 1)
    label(f, titleText, UDim2.fromOffset(14, 5), UDim2.new(1, -28, 0, 28), 16, C.cyan, true)
    make("Frame", {Position=UDim2.fromOffset(12, 37), Size=UDim2.new(1,-24,0,1), BackgroundColor3=C.cyan2, BackgroundTransparency=0.35, BorderSizePixel=0}, f)
    return f
end

local function toggleRow(parent, text, key, y)
    label(parent, text, UDim2.fromOffset(14, y), UDim2.new(1, -100, 0, 34), 13, C.text, false)
    local b = make("TextButton", {
        Position=UDim2.new(1,-68,0,y+3), Size=UDim2.fromOffset(52,27),
        Text="", BorderSizePixel=0, BackgroundColor3=state[key] and C.green or Color3.fromRGB(70,80,88),
    }, parent)
    corner(b, 14)
    local knob = make("Frame", {
        Position=state[key] and UDim2.new(1,-23,0,4) or UDim2.fromOffset(4,4),
        Size=UDim2.fromOffset(19,19), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0,
    }, b)
    corner(knob, 12)
    b.Activated:Connect(function()
        state[key] = not state[key]
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3=state[key] and C.green or Color3.fromRGB(70,80,88)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.12), {Position=state[key] and UDim2.new(1,-23,0,4) or UDim2.fromOffset(4,4)}):Play()
        if key == "farm" then setStatus(state.farm and "Demo bật (không tự đánh)" or "Đã dừng") end
    end)
end

local function actionButton(parent, text, y, callback)
    local b = make("TextButton", {
        Position=UDim2.fromOffset(14,y), Size=UDim2.new(1,-28,0,35),
        Text=text, Font=Enum.Font.GothamSemibold, TextSize=13, TextColor3=C.text,
        BackgroundColor3=C.panel2, BorderSizePixel=0,
    }, parent)
    corner(b, 8); stroke(b, C.cyan2, 1)
    b.Activated:Connect(callback)
    return b
end

local function renderTab(tab)
    currentTab = tab
    clearContent()
    if tab == "Home" or tab == "Auto Farm" then
        local f = card("ϟ  Auto Farm Level", 250)
        toggleRow(f, "Bật Auto Farm (giao diện demo)", "farm", 48)
        label(f, "Kiểu farm: Farm quái gần nhất", UDim2.fromOffset(14,91), UDim2.new(1,-28,0,28), 13, C.text, false)
        label(f, "Chọn quái: Auto theo cấp hiện tại", UDim2.fromOffset(14,123), UDim2.new(1,-28,0,28), 13, C.text, false)
        toggleRow(f, "Tự động nhận quest (demo)", "quest", 157)
        toggleRow(f, "Tự động chuyển khu vực (demo)", "travel", 197)

        local q = card("★  Quest hiện tại", 150)
        label(q, "Tên nhiệm vụ: Defeat enemies", UDim2.fromOffset(14,47), UDim2.new(1,-28,0,24), 13, C.text, false)
        label(q, "Mục tiêu: UI preview", UDim2.fromOffset(14,75), UDim2.new(1,-28,0,24), 13, C.green, true)
        label(q, "Phần thưởng phụ thuộc game", UDim2.fromOffset(14,103), UDim2.new(1,-28,0,24), 12, C.yellow, true)

        local s = card("◎  Trạng thái", 130)
        statusText = label(s, "Trạng thái: Sẵn sàng", UDim2.fromOffset(14,47), UDim2.new(1,-28,0,23), 13, C.green, true)
        label(s, "Cấp hiện tại: " .. tostring((player:FindFirstChild("Data") and player.Data:FindFirstChild("Level") and player.Data.Level.Value) or "—"),
            UDim2.fromOffset(14,75), UDim2.new(1,-28,0,23), 13, C.text, false)
    elseif tab == "Quest" then
        local f = card("▣  Quest Tools", 180)
        label(f, "Hiển thị thông tin quest của nhân vật nếu game cung cấp.", UDim2.fromOffset(14,48), UDim2.new(1,-28,0,48), 13, C.text, false)
        actionButton(f, "Làm mới thông tin", 105, function() setStatus("Đã làm mới giao diện quest") end)
    elseif tab == "Teleports" then
        local f = card("♧  Teleports", 150)
        label(f, "Các nút dịch chuyển là bản xem trước, chưa thực hiện dịch chuyển.", UDim2.fromOffset(14,48), UDim2.new(1,-28,0,45), 13, C.text, false)
        actionButton(f, "Đảo gần nhất (demo)", 98, function() setStatus("Teleport chỉ là demo") end)
    elseif tab == "Stats" then
        local f = card("▥  Player Stats", 150)
        local data = player:FindFirstChild("Data")
        for i, name in ipairs({"Level","Beli","Fragments"}) do
            local v = data and data:FindFirstChild(name)
            label(f, name .. ": " .. tostring(v and v.Value or "N/A"), UDim2.fromOffset(14,45+(i-1)*29), UDim2.new(1,-28,0,25), 13, C.text, false)
        end
    elseif tab == "Items" then
        local f = card("◇  Items", 160)
        label(f, "Danh sách item phụ thuộc dữ liệu mà game hiển thị cho client.", UDim2.fromOffset(14,48), UDim2.new(1,-28,0,48), 13, C.text, false)
        toggleRow(f, "Tự mua đồ (demo)", "buy", 105)
    else
        local f = card("⚙  Tùy chọn nâng cao", 220)
        toggleRow(f, "Bỏ qua cutscene (demo)", "skip", 48)
        toggleRow(f, "Tự động mua đồ (demo)", "buy", 88)
        toggleRow(f, "Chế độ giảm lag (demo)", "lowLag", 128)
        actionButton(f, "Đặt lại trạng thái demo", 172, function()
            for k in pairs(state) do if typeof(state[k]) == "boolean" then state[k] = false end end
            state.quest, state.travel, state.skip, state.lowLag = true, true, true, true
            setStatus("Đã đặt lại; mở lại tab để cập nhật công tắc")
        end)
    end
end

for i, info in ipairs(tabNames) do
    local b = make("TextButton", {
        Name=info[2], Position=UDim2.fromOffset(7, 8+(i-1)*47), Size=UDim2.new(1,-14,0,41),
        Text=info[1] .. "   " .. info[2], TextXAlignment=Enum.TextXAlignment.Left,
        Font=Enum.Font.GothamSemibold, TextSize=13, TextColor3=C.text,
        BackgroundColor3=C.panel2, BackgroundTransparency=1, BorderSizePixel=0,
    }, sidebar)
    corner(b, 9)
    tabButtons[info[2]] = b
    b.Activated:Connect(function()
        for _, other in pairs(tabButtons) do other.BackgroundTransparency = 1; other.TextColor3 = C.text end
        b.BackgroundTransparency = 0; b.BackgroundColor3 = Color3.fromRGB(0,70,82); b.TextColor3 = C.cyan
        renderTab(info[2])
    end)
end
tabButtons.Home.BackgroundTransparency = 0
tabButtons.Home.BackgroundColor3 = Color3.fromRGB(0,70,82)
tabButtons.Home.TextColor3 = C.cyan
renderTab("Home")

local footer = make("Frame", {
    Position=UDim2.new(0,0,1,-56), Size=UDim2.new(0.19,0,0,48),
    BackgroundColor3=C.panel2, BorderSizePixel=0,
}, body)
corner(footer, 10); stroke(footer, C.cyan2, 1)
label(footer, "KHANH HUB", UDim2.fromOffset(8,2), UDim2.new(1,-16,0,20), 12, C.cyan, true)
label(footer, "UI preview", UDim2.fromOffset(8,22), UDim2.new(1,-16,0,18), 11, C.muted, false)

local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
    end
end)

minBtn.Activated:Connect(function()
    state.minimized = not state.minimized
    body.Visible = not state.minimized
    panel.Size = state.minimized and UDim2.new(0.75,0,0,76) or UDim2.new(0.94,0,0.82,0)
    minBtn.Text = state.minimized and "+" or "−"
end)
closeBtn.Activated:Connect(function() gui:Destroy() end)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightControl and gui.Parent then
        panel.Visible = not panel.Visible
    end
end)

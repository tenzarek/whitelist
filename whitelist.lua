-- ============================================
-- НОВЫЙ ВОДЯНОЙ ЗНАК (исправленный)
-- ============================================
local WatermarkGui = nil
local WatermarkFrame = nil
local NameLabel = nil
local FPSLabel = nil
local PingLabel = nil
local TimeLabel = nil

local FrameCount = 0
local LastFPSUpdate = 0
local FPS = 0
local LastPingUpdate = 0
local Ping = 0

local function UpdateFPS()
    FrameCount = FrameCount + 1
    local now = tick()
    if now - LastFPSUpdate >= 1 then
        FPS = math.floor(FrameCount / (now - LastFPSUpdate))
        FrameCount = 0
        LastFPSUpdate = now
    end
end

local function UpdatePing()
    local now = tick()
    if now - LastPingUpdate >= 1 then
        local stats = game:GetService("Stats")
        local pingStat = stats.Network.ServerStatsItem["Data Ping"]
        Ping = math.floor(pingStat:GetValue())
        LastPingUpdate = now
    end
end

local function UpdateMSKTime()
    local serverTime = os.time()
    local timeTable = os.date("*t", serverTime)
    local hours = timeTable.hour < 10 and "0" .. timeTable.hour or tostring(timeTable.hour)
    local minutes = timeTable.min < 10 and "0" .. timeTable.min or tostring(timeTable.min)
    return hours .. ":" .. minutes
end

local function UpdateLayout()
    if not WatermarkFrame then return end
    
    local totalWidth = 0
    local elements = {}
    
    -- Логотип (фиксированная ширина)
    local logoWidth = 24
    totalWidth = totalWidth + logoWidth + 4
    
    -- Имя пользователя
    if NameLabel and NameLabel.Text then
        local temp = Instance.new("TextLabel")
        temp.Font = NameLabel.Font
        temp.TextSize = NameLabel.TextSize
        temp.Text = NameLabel.Text
        temp.Parent = game.CoreGui
        local w = temp.TextBounds.X
        temp:Destroy()
        NameLabel.Size = UDim2.new(0, w, 1, 0)
        totalWidth = totalWidth + w + 8
    end
    
    -- FPS
    if FPSLabel and FPSLabel.Text then
        local temp = Instance.new("TextLabel")
        temp.Font = FPSLabel.Font
        temp.TextSize = FPSLabel.TextSize
        temp.Text = FPSLabel.Text
        temp.Parent = game.CoreGui
        local w = temp.TextBounds.X
        temp:Destroy()
        FPSLabel.Size = UDim2.new(0, w, 1, 0)
        totalWidth = totalWidth + w + 8
    end
    
    -- Ping
    if PingLabel and PingLabel.Text then
        local temp = Instance.new("TextLabel")
        temp.Font = PingLabel.Font
        temp.TextSize = PingLabel.TextSize
        temp.Text = PingLabel.Text
        temp.Parent = game.CoreGui
        local w = temp.TextBounds.X
        temp:Destroy()
        PingLabel.Size = UDim2.new(0, w, 1, 0)
        totalWidth = totalWidth + w + 8
    end
    
    -- Время
    if TimeLabel and TimeLabel.Text then
        local temp = Instance.new("TextLabel")
        temp.Font = TimeLabel.Font
        temp.TextSize = TimeLabel.TextSize
        temp.Text = TimeLabel.Text
        temp.Parent = game.CoreGui
        local w = temp.TextBounds.X
        temp:Destroy()
        TimeLabel.Size = UDim2.new(0, w, 1, 0)
        totalWidth = totalWidth + w
    end
    
    WatermarkFrame.Size = UDim2.new(0, totalWidth + 10, 0, 32)
    
    -- Позиционируем элементы
    local currentX = 4
    
    -- Логотип
    local logo = WatermarkFrame:FindFirstChild("LogoLabel")
    if logo then
        logo.Position = UDim2.new(0, currentX, 0.5, -12)
        currentX = currentX + 24 + 4
    end
    
    -- Имя
    if NameLabel then
        NameLabel.Position = UDim2.new(0, currentX, 0, 0)
        currentX = currentX + NameLabel.Size.X.Offset + 8
    end
    
    -- FPS
    if FPSLabel then
        FPSLabel.Position = UDim2.new(0, currentX, 0, 0)
        currentX = currentX + FPSLabel.Size.X.Offset + 8
    end
    
    -- Ping
    if PingLabel then
        PingLabel.Position = UDim2.new(0, currentX, 0, 0)
        currentX = currentX + PingLabel.Size.X.Offset + 8
    end
    
    -- Время
    if TimeLabel then
        TimeLabel.Position = UDim2.new(0, currentX, 0, 0)
    end
end

local function CreateWatermark()
    if WatermarkGui then
        WatermarkGui:Destroy()
        WatermarkGui = nil
    end
    
    WatermarkGui = Instance.new("ScreenGui")
    WatermarkGui.Name = "TenzoSenseWatermark"
    WatermarkGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    WatermarkGui.IgnoreGuiInset = true
    WatermarkGui.Parent = game.CoreGui
    
    WatermarkFrame = Instance.new("Frame")
    WatermarkFrame.Name = "WatermarkFrame"
    WatermarkFrame.Size = UDim2.new(0, 200, 0, 32)
    WatermarkFrame.Position = UDim2.new(0.5, -100, 0.02, 0)
    WatermarkFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    WatermarkFrame.BackgroundTransparency = 0.2
    WatermarkFrame.BorderSizePixel = 0
    WatermarkFrame.Active = true
    WatermarkFrame.Parent = WatermarkGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = WatermarkFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(50, 50, 50)
    UIStroke.Thickness = 1
    UIStroke.Parent = WatermarkFrame
    
    -- Логотип
    local LogoLabel = Instance.new("ImageLabel")
    LogoLabel.Name = "LogoLabel"
    LogoLabel.Size = UDim2.new(0, 24, 0, 24)
    LogoLabel.Position = UDim2.new(0, 4, 0.5, -12)
    LogoLabel.BackgroundTransparency = 1
    LogoLabel.Image = "rbxassetid://102864506971668"
    LogoLabel.Parent = WatermarkFrame
    
    -- Имя пользователя (mainNickname)
    NameLabel = Instance.new("TextLabel")
    NameLabel.Name = "NameLabel"
    NameLabel.Size = UDim2.new(0, 0, 1, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = userData.mainNickname
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 12
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = WatermarkFrame
    
    -- FPS
    FPSLabel = Instance.new("TextLabel")
    FPSLabel.Name = "FPSLabel"
    FPSLabel.Size = UDim2.new(0, 0, 1, 0)
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.Text = "0 FPS"
    FPSLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    FPSLabel.TextSize = 12
    FPSLabel.Font = Enum.Font.Gotham
    FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
    FPSLabel.Parent = WatermarkFrame
    
    -- Ping
    PingLabel = Instance.new("TextLabel")
    PingLabel.Name = "PingLabel"
    PingLabel.Size = UDim2.new(0, 0, 1, 0)
    PingLabel.BackgroundTransparency = 1
    PingLabel.Text = "0 PING"
    PingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    PingLabel.TextSize = 12
    PingLabel.Font = Enum.Font.Gotham
    PingLabel.TextXAlignment = Enum.TextXAlignment.Left
    PingLabel.Parent = WatermarkFrame
    
    -- Время
    TimeLabel = Instance.new("TextLabel")
    TimeLabel.Name = "TimeLabel"
    TimeLabel.Size = UDim2.new(0, 0, 1, 0)
    TimeLabel.BackgroundTransparency = 1
    TimeLabel.Text = "00:00"
    TimeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TimeLabel.TextSize = 12
    TimeLabel.Font = Enum.Font.Gotham
    TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
    TimeLabel.Parent = WatermarkFrame
    
    -- Обновление каждые 0.1 секунды
    task.spawn(function()
        while WatermarkGui and WatermarkFrame do
            UpdateFPS()
            UpdatePing()
            FPSLabel.Text = FPS .. " FPS"
            PingLabel.Text = Ping .. " PING"
            TimeLabel.Text = UpdateMSKTime()
            UpdateLayout()
            task.wait(0.1)
        end
    end)
    
    -- Перетаскивание
    local dragging = false
    local dragStart, frameStart
    
    WatermarkFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = WatermarkFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            WatermarkFrame.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

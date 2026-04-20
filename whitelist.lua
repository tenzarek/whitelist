-- Whitelist System + Watermark (все в одном)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ============================================
-- НАСТРОЙКИ ВАЙТЛИСТА (МЕНЯЙ ЗДЕСЬ)
-- ============================================
local WHITELIST = {
    {
        mainNickname = "tenzarek",
        robloxNicknames = {"durkomaker", "player2", "pidor"},
        expiryDate = "22.04.2026",
        isLifetime = false
    },
    {
        mainNickname = "Админ",
        robloxNicknames = {"admin123", "admin456"},
        expiryDate = "01.01.2030",
        isLifetime = false
    },
    {
        mainNickname = "Тестер",
        robloxNicknames = {"tester1"},
        expiryDate = "",
        isLifetime = true
    }
}

local userData = nil

-- Функция для расчета дней
local function getDaysLeft(dateString)
    if dateString == "" then return -1 end
    
    local day, month, year = dateString:match("(%d+)%.(%d+)%.(%d+)")
    if not day then 
        return nil 
    end
    
    local expiryTime = os.time({
        year = tonumber(year), 
        month = tonumber(month), 
        day = tonumber(day),
        hour = 23,
        min = 59,
        sec = 59
    })
    
    local currentTime = os.time()
    local diff = expiryTime - currentTime
    
    if diff < 0 then 
        return 0 
    end
    
    return math.floor(diff / 86400) + 1
end

-- Проверка вайтлиста
local function checkWhitelist()
    local currentName = LocalPlayer.Name
    
    for _, user in ipairs(WHITELIST) do
        for _, nick in ipairs(user.robloxNicknames) do
            if string.lower(nick) == string.lower(currentName) then
                userData = {
                    mainNickname = user.mainNickname,
                    robloxNickname = currentName,
                    expiryDate = user.expiryDate,
                    isLifetime = user.isLifetime
                }
                
                if user.isLifetime then
                    return true, "Lifetime"
                end
                
                local days = getDaysLeft(user.expiryDate)
                if days and days > 0 then
                    return true, days
                else
                    return false, "Срок действия подписки истек"
                end
            end
        end
    end
    
    return false, "Вас нет в вайтлисте"
end

-- Кик
local function kick(reason)
    LocalPlayer:Kick(reason)
end

-- ============================================
-- НОВЫЙ ВОДЯНОЙ ЗНАК (показывает mainNickname)
-- ============================================
local WatermarkGui = nil
local WatermarkFrame = nil
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

local function CalculateTextWidth(textLabel)
    local temp = Instance.new("TextLabel")
    temp.Text = textLabel.Text
    temp.Font = textLabel.Font
    temp.TextSize = textLabel.TextSize
    temp.Size = UDim2.new(0, 10000, 0, 10000)
    temp.Parent = game.CoreGui
    local width = temp.TextBounds.X
    temp:Destroy()
    return width
end

local function UpdateLayout()
    if not WatermarkFrame then return end
    
    local totalWidth = 0
    local spacing = 8
    local currentX = 4
    
    -- Логотип
    local logoLabel = WatermarkFrame:FindFirstChild("LogoLabel")
    if logoLabel then
        local logoWidth = 24
        logoLabel.Position = UDim2.new(0, currentX, 0.5, -12)
        logoLabel.Size = UDim2.new(0, 24, 0, 24)
        currentX = currentX + logoWidth + 4
    end
    
    -- Никнейм (mainNickname)
    local nameLabel = WatermarkFrame:FindFirstChild("NameLabel")
    if nameLabel then
        local nameWidth = CalculateTextWidth(nameLabel)
        nameLabel.Position = UDim2.new(0, currentX, 0, 0)
        nameLabel.Size = UDim2.new(0, nameWidth, 1, 0)
        currentX = currentX + nameWidth + spacing
    end
    
    -- FPS
    if FPSLabel then
        local fpsWidth = CalculateTextWidth(FPSLabel)
        FPSLabel.Position = UDim2.new(0, currentX, 0, 0)
        FPSLabel.Size = UDim2.new(0, fpsWidth, 1, 0)
        currentX = currentX + fpsWidth + spacing
    end
    
    -- Ping
    if PingLabel then
        local pingWidth = CalculateTextWidth(PingLabel)
        PingLabel.Position = UDim2.new(0, currentX, 0, 0)
        PingLabel.Size = UDim2.new(0, pingWidth, 1, 0)
        currentX = currentX + pingWidth + spacing
    end
    
    -- Время
    if TimeLabel then
        local timeWidth = CalculateTextWidth(TimeLabel)
        TimeLabel.Position = UDim2.new(0, currentX, 0, 0)
        TimeLabel.Size = UDim2.new(0, timeWidth, 1, 0)
        currentX = currentX + timeWidth
    end
    
    totalWidth = currentX + 8
    WatermarkFrame.Size = UDim2.new(0, totalWidth, 0, 32)
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
    WatermarkFrame.Draggable = true
    WatermarkFrame.Parent = WatermarkGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = WatermarkFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(50, 50, 50)
    UIStroke.Thickness = 1
    UIStroke.Parent = WatermarkFrame
    
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, -8, 1, -6)
    Container.Position = UDim2.new(0, 4, 0, 3)
    Container.BackgroundTransparency = 1
    Container.Parent = WatermarkFrame
    
    -- Логотип (иконка)
    local LogoLabel = Instance.new("ImageLabel")
    LogoLabel.Name = "LogoLabel"
    LogoLabel.Size = UDim2.new(0, 24, 0, 24)
    LogoLabel.Position = UDim2.new(0, 0, 0.5, -12)
    LogoLabel.BackgroundTransparency = 1
    LogoLabel.Image = "rbxassetid://102864506971668"
    LogoLabel.Parent = Container
    
    -- Имя пользователя (mainNickname)
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Name = "NameLabel"
    NameLabel.Size = UDim2.new(0, 0, 1, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = userData.mainNickname
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 12
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = Container
    
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
    FPSLabel.Parent = Container
    
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
    PingLabel.Parent = Container
    
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
    TimeLabel.Parent = Container
    
    UpdateLayout()
    
    RunService.RenderStepped:Connect(function()
        UpdateFPS()
        UpdatePing()
        
        FPSLabel.Text = FPS .. " FPS"
        PingLabel.Text = Ping .. " PING"
        TimeLabel.Text = UpdateMSKTime()
        
        UpdateLayout()
    end)
    
    -- Перетаскивание
    local dragging = false
    local dragInput, mousePos, framePos
    
    WatermarkFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = WatermarkFrame.Position
        end
    end)
    
    WatermarkFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            WatermarkFrame.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Информационное окно (правый верхний угол)
local function showInfo()
    local gui = Instance.new("ScreenGui")
    gui.Name = "UserInfo"
    gui.Parent = game.CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 60)
    frame.Position = UDim2.new(1, -210, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 170, 0)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    title.BackgroundTransparency = 0.3
    title.Text = "TENZOSENSE"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 10
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local nickLabel = Instance.new("TextLabel")
    nickLabel.Size = UDim2.new(1, -10, 0, 20)
    nickLabel.Position = UDim2.new(0, 5, 0, 22)
    nickLabel.BackgroundTransparency = 1
    nickLabel.Text = userData.mainNickname
    nickLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nickLabel.TextSize = 12
    nickLabel.Font = Enum.Font.GothamBold
    nickLabel.TextXAlignment = Enum.TextXAlignment.Left
    nickLabel.Parent = frame
    
    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, -10, 0, 16)
    subLabel.Position = UDim2.new(0, 5, 0, 42)
    subLabel.BackgroundTransparency = 1
    subLabel.TextSize = 10
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.Parent = frame
    
    if userData.isLifetime then
        subLabel.Text = "LIFETIME"
        subLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        local days = getDaysLeft(userData.expiryDate)
        subLabel.Text = days .. " days left"
        if days <= 7 then
            subLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        else
            subLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        end
    end
    
    -- Перетаскивание
    local drag = false
    local dragStart, frameStart
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            dragStart = input.Position
            frameStart = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = false
        end
    end)
    
    return gui
end

-- ============================================
-- ЗАПУСК ПРОВЕРКИ
-- ============================================
local status, result = checkWhitelist()

if not status then
    local errGui = Instance.new("ScreenGui")
    errGui.Parent = game.CoreGui
    
    local errFrame = Instance.new("Frame")
    errFrame.Size = UDim2.new(0, 250, 0, 80)
    errFrame.Position = UDim2.new(0.5, -125, 0.5, -40)
    errFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    errFrame.BackgroundTransparency = 0.1
    errFrame.BorderSizePixel = 0
    errFrame.Parent = errGui
    
    local errCorner = Instance.new("UICorner")
    errCorner.CornerRadius = UDim.new(0, 10)
    errCorner.Parent = errFrame
    
    local errText = Instance.new("TextLabel")
    errText.Size = UDim2.new(1, -20, 1, -20)
    errText.Position = UDim2.new(0, 10, 0, 10)
    errText.BackgroundTransparency = 1
    errText.Text = result
    errText.TextColor3 = Color3.fromRGB(255, 100, 100)
    errText.TextSize = 14
    errText.Font = Enum.Font.GothamBold
    errText.TextWrapped = true
    errText.Parent = errFrame
    
    task.wait(2)
    kick(result)
    return
end

-- Успех - показываем водяной знак и информационное окно
CreateWatermark()
showInfo()

-- Уведомление
task.wait(0.5)
if Rayfield then
    local msg = userData.isLifetime and "LIFETIME" or (getDaysLeft(userData.expiryDate) .. " days left")
    Rayfield:Notify({
        Title = "Welcome " .. userData.mainNickname,
        Content = msg,
        Duration = 3
    })
end

print("Whitelist OK - " .. userData.mainNickname .. " | Expires: " .. (userData.expiryDate or "Lifetime"))

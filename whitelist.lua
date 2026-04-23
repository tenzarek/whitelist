-- TENZOSENSE
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- ============================================
-- ВАЙТЛИСТ (МЕНЯЙ ЗДЕСЬ)
-- ============================================
local WHITELIST = {
    {
        mainNickname = "tenzarek",
        userIds = {8919667598},  -- ID пользователя
        robloxNicknames = {"durkomaker"}, -- доп. проверка
        expiryDate = "25.04.2026",
        isLifetime = false
    },
    -- ДОБАВЛЯЙ НОВЫХ:
    -- {
    --     mainNickname = "Имя",
    --     userIds = {123456789, 987654321}, -- можно несколько ID
    --     robloxNicknames = {"ник1", "ник2"},
    --     expiryDate = "31.12.2026",
    --     isLifetime = false
    -- },
}

local userData = nil

-- РАСЧЕТ ДНЕЙ
local function getDaysLeft(dateString)
    if dateString == "" then return -1 end
    local day, month, year = dateString:match("(%d+)%.(%d+)%.(%d+)")
    if not day then return nil end
    local expiryTime = os.time({year=tonumber(year), month=tonumber(month), day=tonumber(day), hour=23, min=59, sec=59})
    local currentTime = os.time()
    local diff = expiryTime - currentTime
    if diff < 0 then return 0 end
    return math.floor(diff / 86400) + 1
end

-- ТРУДНООБХОДИМАЯ ПРОВЕРКА (через UserId)
local function checkWhitelistSecure()
    local currentUserId = LocalPlayer.UserId
    local currentName = LocalPlayer.Name
    
    for _, user in ipairs(WHITELIST) do
        -- ПРОВЕРКА ПО ID (САМОЕ НАДЕЖНОЕ)
        for _, id in ipairs(user.userIds or {}) do
            if currentUserId == id then
                userData = {
                    mainNickname = user.mainNickname,
                    robloxNickname = currentName,
                    expiryDate = user.expiryDate,
                    isLifetime = user.isLifetime
                }
                if user.isLifetime then return true, "Lifetime" end
                local days = getDaysLeft(user.expiryDate)
                if days and days > 0 then return true, days
                else return false, "Срок действия подписки истек"
                end
            end
        end
        
        -- ДОПОЛНИТЕЛЬНАЯ ПРОВЕРКА ПО ИМЕНИ (на случай если ID не указан)
        for _, nick in ipairs(user.robloxNicknames) do
            if string.lower(nick) == string.lower(currentName) then
                userData = {
                    mainNickname = user.mainNickname,
                    robloxNickname = currentName,
                    expiryDate = user.expiryDate,
                    isLifetime = user.isLifetime
                }
                if user.isLifetime then return true, "Lifetime" end
                local days = getDaysLeft(user.expiryDate)
                if days and days > 0 then return true, days
                else return false, "Срок действия подписки истек"
                end
            end
        end
    end
    return false, "Вас нет в вайтлисте"
end

-- ============================================
-- ЗАЩИТА ОТ ПОДМЕНЫ МЕТОДОВ (анти-эксплойт)
-- ============================================
local function antiExploit()
    -- Проверяем каждые 0.5 секунды, не подменили ли данные
    local originalUserId = LocalPlayer.UserId
    local originalName = LocalPlayer.Name
    
    task.spawn(function()
        while true do
            task.wait(0.5)
            
            -- Если ID изменился или имя изменилось на то, которого нет в вайтлисте
            if LocalPlayer.UserId ~= originalUserId and LocalPlayer.UserId ~= 0 then
                LocalPlayer:Kick("Anti-cheat: UserID mismatch")
                return
            end
            
            -- Доп. проверка на подмену имени
            if LocalPlayer.Name ~= originalName then
                LocalPlayer:Kick("Anti-cheat: Name spoofing detected")
                return
            end
        end
    end)
end

-- ============================================
-- ПРОВЕРКА С ПЕРЕЗАПУСКОМ (если пытаются обойти через loadstring)
-- ============================================
local status, result = checkWhitelistSecure()

if not status then
    local errGui = Instance.new("ScreenGui")
    errGui.Parent = game.CoreGui
    local errFrame = Instance.new("Frame")
    errFrame.Size = UDim2.new(0, 300, 0, 100)
    errFrame.Position = UDim2.new(0.5, -150, 0.5, -50)
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
    LocalPlayer:Kick(result)
    return
end

-- ЗАПУСК ЗАЩИТЫ
antiExploit()

-- ============================================
-- ВОДЯНОЙ ЗНАК (С МЕЙН НИКОМ)
-- ============================================
local WatermarkGui = nil
local WatermarkFrame = nil
local TenzoLabel = nil
local SenseLabel = nil
local UsernameLabel = nil
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
    WatermarkFrame.Size = UDim2.new(0, 450, 0, 32)
    WatermarkFrame.Position = UDim2.new(0.5, -225, 0.02, 0)
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
    Container.Size = UDim2.new(1, -10, 1, -6)
    Container.Position = UDim2.new(0, 5, 0, 3)
    Container.BackgroundTransparency = 1
    Container.Parent = WatermarkFrame
    
    local LeftContainer = Instance.new("Frame")
    LeftContainer.Name = "LeftContainer"
    LeftContainer.Size = UDim2.new(0, 0, 1, 0)
    LeftContainer.BackgroundTransparency = 1
    LeftContainer.Parent = Container
    
    TenzoLabel = Instance.new("TextLabel")
    TenzoLabel.Name = "TenzoLabel"
    TenzoLabel.Size = UDim2.new(0, 0, 1, 0)
    TenzoLabel.BackgroundTransparency = 1
    TenzoLabel.Text = "tenzo"
    TenzoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TenzoLabel.TextSize = 14
    TenzoLabel.Font = Enum.Font.GothamBold
    TenzoLabel.TextXAlignment = Enum.TextXAlignment.Left
    TenzoLabel.Parent = LeftContainer
    
    SenseLabel = Instance.new("TextLabel")
    SenseLabel.Name = "SenseLabel"
    SenseLabel.Size = UDim2.new(0, 0, 1, 0)
    SenseLabel.Position = UDim2.new(0, 0, 0, 0)
    SenseLabel.BackgroundTransparency = 1
    SenseLabel.Text = "sense"
    SenseLabel.TextColor3 = Color3.new(0, 255, 0)
    SenseLabel.TextSize = 14
    SenseLabel.Font = Enum.Font.GothamBold
    SenseLabel.TextXAlignment = Enum.TextXAlignment.Left
    SenseLabel.Parent = LeftContainer
    
    local Separator1 = Instance.new("TextLabel")
    Separator1.Name = "Separator1"
    Separator1.Size = UDim2.new(0, 10, 1, 0)
    Separator1.Position = UDim2.new(0, 0, 0, 0)
    Separator1.BackgroundTransparency = 1
    Separator1.Text = "•"
    Separator1.TextColor3 = Color3.fromRGB(150, 150, 150)
    Separator1.TextSize = 14
    Separator1.Font = Enum.Font.Gotham
    Separator1.TextXAlignment = Enum.TextXAlignment.Center
    Separator1.Parent = Container
    
    UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Name = "UsernameLabel"
    UsernameLabel.Size = UDim2.new(0, 0, 1, 0)
    UsernameLabel.Position = UDim2.new(0, 0, 0, 0)
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Text = userData.mainNickname
    UsernameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    UsernameLabel.TextSize = 12
    UsernameLabel.Font = Enum.Font.Gotham
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.Parent = Container
    
    local Separator2 = Instance.new("TextLabel")
    Separator2.Name = "Separator2"
    Separator2.Size = UDim2.new(0, 10, 1, 0)
    Separator2.Position = UDim2.new(0, 0, 0, 0)
    Separator2.BackgroundTransparency = 1
    Separator2.Text = "•"
    Separator2.TextColor3 = Color3.fromRGB(150, 150, 150)
    Separator2.TextSize = 14
    Separator2.Font = Enum.Font.Gotham
    Separator2.TextXAlignment = Enum.TextXAlignment.Center
    Separator2.Parent = Container
    
    FPSLabel = Instance.new("TextLabel")
    FPSLabel.Name = "FPSLabel"
    FPSLabel.Size = UDim2.new(0, 0, 1, 0)
    FPSLabel.Position = UDim2.new(0, 0, 0, 0)
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.Text = "1488 FPS"
    FPSLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    FPSLabel.TextSize = 12
    FPSLabel.Font = Enum.Font.Gotham
    FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
    FPSLabel.Parent = Container
    
    local Separator3 = Instance.new("TextLabel")
    Separator3.Name = "Separator3"
    Separator3.Size = UDim2.new(0, 10, 1, 0)
    Separator3.Position = UDim2.new(0, 0, 0, 0)
    Separator3.BackgroundTransparency = 1
    Separator3.Text = "•"
    Separator3.TextColor3 = Color3.fromRGB(150, 150, 150)
    Separator3.TextSize = 14
    Separator3.Font = Enum.Font.Gotham
    Separator3.TextXAlignment = Enum.TextXAlignment.Center
    Separator3.Parent = Container
    
    PingLabel = Instance.new("TextLabel")
    PingLabel.Name = "PingLabel"
    PingLabel.Size = UDim2.new(0, 0, 1, 0)
    PingLabel.Position = UDim2.new(0, 0, 0, 0)
    PingLabel.BackgroundTransparency = 1
    PingLabel.Text = "1488 PING"
    PingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    PingLabel.TextSize = 12
    PingLabel.Font = Enum.Font.Gotham
    PingLabel.TextXAlignment = Enum.TextXAlignment.Left
    PingLabel.Parent = Container
    
    local Separator4 = Instance.new("TextLabel")
    Separator4.Name = "Separator4"
    Separator4.Size = UDim2.new(0, 10, 1, 0)
    Separator4.Position = UDim2.new(0, 0, 0, 0)
    Separator4.BackgroundTransparency = 1
    Separator4.Text = "•"
    Separator4.TextColor3 = Color3.fromRGB(150, 150, 150)
    Separator4.TextSize = 14
    Separator4.Font = Enum.Font.Gotham
    Separator4.TextXAlignment = Enum.TextXAlignment.Center
    Separator4.Parent = Container
    
    TimeLabel = Instance.new("TextLabel")
    TimeLabel.Name = "TimeLabel"
    TimeLabel.Size = UDim2.new(0, 0, 1, 0)
    TimeLabel.Position = UDim2.new(0, 0, 0, 0)
    TimeLabel.BackgroundTransparency = 1
    TimeLabel.Text = "14:88"
    TimeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TimeLabel.TextSize = 12
    TimeLabel.Font = Enum.Font.Gotham
    TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
    TimeLabel.Parent = Container
    
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
        local totalWidth = 0
        local elements = {
            {label = TenzoLabel, width = CalculateTextWidth(TenzoLabel)},
            {label = SenseLabel, width = CalculateTextWidth(SenseLabel)},
            {separator = Separator1, width = 10},
            {label = UsernameLabel, width = CalculateTextWidth(UsernameLabel)},
            {separator = Separator2, width = 10},
            {label = FPSLabel, width = CalculateTextWidth(FPSLabel)},
            {separator = Separator3, width = 10},
            {label = PingLabel, width = CalculateTextWidth(PingLabel)},
            {separator = Separator4, width = 10},
            {label = TimeLabel, width = CalculateTextWidth(TimeLabel)}
        }
        
        for i, element in ipairs(elements) do
            totalWidth = totalWidth + element.width + (i < #elements and 4 or 0)
        end
        
        local currentX = 0
        for i, element in ipairs(elements) do
            if element.label then
                element.label.Position = UDim2.new(0, currentX, 0, 0)
                element.label.Size = UDim2.new(0, element.width, 1, 0)
                currentX = currentX + element.width + 4
            elseif element.separator then
                element.separator.Position = UDim2.new(0, currentX, 0, 0)
                element.separator.Size = UDim2.new(0, element.width, 1, 0)
                currentX = currentX + element.width + 4
            end
        end
        
        WatermarkFrame.Size = UDim2.new(0, totalWidth + 20, 0, 32)
    end
    
    UpdateLayout()
    
    RunService.RenderStepped:Connect(function()
        UpdateFPS()
        UpdatePing()
        
        FPSLabel.Text = FPS .. " FPS"
        PingLabel.Text = Ping .. " PING"
        TimeLabel.Text = UpdateMSKTime() .. ""
        
        UpdateLayout()
    end)
    
    WatermarkFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local dragStart = input.Position
            local frameStart = WatermarkFrame.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                else
                    local delta = input.Position - dragStart
                    WatermarkFrame.Position = UDim2.new(
                        frameStart.X.Scale, frameStart.X.Offset + delta.X,
                        frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
                    )
                end
            end)
        end
    end)
end

-- ============================================
-- ИНФОРМАЦИОННОЕ ОКНО
-- ============================================
local function showInfo()
    local gui = Instance.new("ScreenGui")
    gui.Name = "UserInfo"
    gui.Parent = game.CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 70)
    frame.Position = UDim2.new(1, -230, 0, 50)
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
    title.Size = UDim2.new(1, 0, 0, 22)
    title.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    title.BackgroundTransparency = 0.3
    title.Text = "TENZOSENSE"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 10
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local nickLabel = Instance.new("TextLabel")
    nickLabel.Size = UDim2.new(1, -10, 0, 22)
    nickLabel.Position = UDim2.new(0, 5, 0, 24)
    nickLabel.BackgroundTransparency = 1
    nickLabel.Text = userData.mainNickname
    nickLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nickLabel.TextSize = 12
    nickLabel.Font = Enum.Font.GothamBold
    nickLabel.TextXAlignment = Enum.TextXAlignment.Left
    nickLabel.Parent = frame
    
    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, -10, 0, 18)
    subLabel.Position = UDim2.new(0, 5, 0, 48)
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
end

-- ============================================
-- ЗАПУСК
-- ============================================
CreateWatermark()
showInfo()

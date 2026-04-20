-- Whitelist System
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- НАСТРОЙКИ - ИЗМЕНИ ПОД СЕБЯ
local WHITELIST_URL = "https://raw.githubusercontent.com/ТВОЙ_АКК/ТВОЙ_РЕПО/main/whitelist.json"
-- ИЛИ pastebin: local WHITELIST_URL = "https://pastebin.com/raw/ТВОЙ_КОД"

local userData = nil
local isWhitelisted = false

-- Функция для парсинга даты
local function parseDate(dateString)
    if dateString == "" then return nil end
    local day, month, year = dateString:match("(%d+)%.(%d+)%.(%d+)")
    if day and month and year then
        return os.time({year=tonumber(year), month=tonumber(month), day=tonumber(day)})
    end
    return nil
end

-- Функция для расчета оставшихся дней
local function getDaysRemaining(expiryDate, isLifetime)
    if isLifetime then return -1 end
    local expiryTime = parseDate(expiryDate)
    if not expiryTime then return nil end
    local currentTime = os.time()
    local diff = expiryTime - currentTime
    return math.max(0, math.floor(diff / 86400))
end

-- Проверка вайтлиста
local function checkWhitelist()
    local success, response = pcall(function()
        return game:HttpGet(WHITELIST_URL)
    end)
    
    if not success then
        return false, "Ошибка загрузки вайтлиста"
    end
    
    local data = HttpService:JSONDecode(response)
    local currentRobloxName = LocalPlayer.Name
    
    for _, user in ipairs(data.users) do
        for _, nick in ipairs(user.robloxNicknames) do
            if string.lower(nick) == string.lower(currentRobloxName) then
                userData = {
                    mainNickname = user.mainNickname,
                    robloxNickname = currentRobloxName,
                    expiryDate = user.expiryDate,
                    isLifetime = user.isLifetime
                }
                
                if user.isLifetime then
                    return true, "Lifetime"
                end
                
                local daysLeft = getDaysRemaining(user.expiryDate, false)
                if daysLeft and daysLeft > 0 then
                    return true, daysLeft
                elseif daysLeft == 0 then
                    return false, "Срок действия подписки истек"
                else
                    return false, "Ошибка даты"
                end
            end
        end
    end
    
    return false, "Вас нет в вайтлисте"
end

-- Функция кика
local function kickPlayer(reason)
    LocalPlayer:Kick(reason)
end

-- Запуск проверки
local whitelistStatus, whitelistResult = checkWhitelist()

if not whitelistStatus then
    kickPlayer(whitelistResult)
    return
end

-- Если прошел вайтлист - показываем уведомление
local daysLeftText = ""
if whitelistResult == "Lifetime" then
    daysLeftText = "Lifetime"
elseif type(whitelistResult) == "number" then
    daysLeftText = whitelistResult .. " days left"
end

-- Уведомление через Rayfield (если Rayfield уже загружен)
task.wait(1)
if Rayfield then
    Rayfield:Notify({
        Title = "Whitelist",
        Content = "Welcome " .. userData.mainNickname .. "! " .. daysLeftText,
        Duration = 3
    })
end

-- Изменяем Watermark, чтобы показывал Main Nickname
local function updateWatermarkWithMainNick()
    -- Ждем пока создастся Watermark
    task.wait(0.5)
    local watermarkFrame = game.CoreGui:FindFirstChild("TenzoSenseWatermark")
    if watermarkFrame then
        local usernameLabel = watermarkFrame:FindFirstChild("Container"):FindFirstChild("UsernameLabel")
        if usernameLabel and userData then
            usernameLabel.Text = userData.mainNickname
        end
    end
end

-- Создаем вкладку My Account
local AccTab = Window:CreateTab("My Account", "game")

-- Функция создания окна профиля
local function openProfileWindow()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "ProfileWindow"
    gui.Parent = playerGui
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300, 0, 250)
    main.Position = UDim2.new(0.5, -150, 0.5, -125)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    main.BackgroundTransparency = 0.1
    main.BorderSizePixel = 0
    main.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = main
    
    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, 35)
    top.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    top.BackgroundTransparency = 0.3
    top.BorderSizePixel = 0
    top.Parent = main
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 10)
    topCorner.Parent = top
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "My Profile"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = top
    
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -35, 0, 2)
    close.BackgroundTransparency = 1
    close.Text = "✕"
    close.TextColor3 = Color3.fromRGB(200, 200, 200)
    close.TextSize = 18
    close.Font = Enum.Font.GothamBold
    close.Parent = top
    
    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    close.MouseEnter:Connect(function()
        close.TextColor3 = Color3.fromRGB(255, 100, 100)
    end)
    close.MouseLeave:Connect(function()
        close.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 1, -50)
    container.Position = UDim2.new(0, 10, 0, 45)
    container.BackgroundTransparency = 1
    container.Parent = main
    
    -- Main Nickname
    local mainNickLabel = Instance.new("TextLabel")
    mainNickLabel.Size = UDim2.new(1, 0, 0, 25)
    mainNickLabel.Position = UDim2.new(0, 0, 0, 10)
    mainNickLabel.BackgroundTransparency = 1
    mainNickLabel.Text = "Main Nickname: " .. (userData and userData.mainNickname or "Unknown")
    mainNickLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainNickLabel.TextSize = 13
    mainNickLabel.Font = Enum.Font.GothamBold
    mainNickLabel.TextXAlignment = Enum.TextXAlignment.Left
    mainNickLabel.Parent = container
    
    -- Roblox Nickname
    local robloxNickLabel = Instance.new("TextLabel")
    robloxNickLabel.Size = UDim2.new(1, 0, 0, 25)
    robloxNickLabel.Position = UDim2.new(0, 0, 0, 40)
    robloxNickLabel.BackgroundTransparency = 1
    robloxNickLabel.Text = "Roblox Nickname: @" .. (userData and userData.robloxNickname or "Unknown")
    robloxNickLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    robloxNickLabel.TextSize = 12
    robloxNickLabel.Font = Enum.Font.Gotham
    robloxNickLabel.TextXAlignment = Enum.TextXAlignment.Left
    robloxNickLabel.Parent = container
    
    -- Subscription
    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, 0, 0, 25)
    subLabel.Position = UDim2.new(0, 0, 0, 70)
    subLabel.BackgroundTransparency = 1
    
    local subText = ""
    if userData and userData.isLifetime then
        subText = "Subscription: Lifetime"
    elseif userData then
        local days = getDaysRemaining(userData.expiryDate, false)
        if days then
            subText = "Subscription: " .. days .. " days left"
            if days <= 7 then
                subLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            else
                subLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            end
        else
            subText = "Subscription: Expired"
            subLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    else
        subText = "Subscription: Unknown"
    end
    
    subLabel.Text = subText
    subLabel.TextSize = 12
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.Parent = container
    
    -- Разделитель
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 0, 105)
    divider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    divider.BorderSizePixel = 0
    divider.Parent = container
    
    -- Статус
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 25)
    statusLabel.Position = UDim2.new(0, 0, 0, 115)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Active"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = container
    
    -- Перетаскивание окна
    local dragging = false
    local dragStart, frameStart
    
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = main.Position
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
        end
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Кнопка My Profile
AccTab:CreateButton({
    Name = "My Profile",
    Callback = function()
        if userData then
            openProfileWindow()
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Failed to load profile data",
                Duration = 2
            })
        end
    end
})

-- Кнопка для проверки вайтлиста (на случай если нужно обновить)
AccTab:CreateButton({
    Name = "Refresh Whitelist",
    Callback = function()
        local status, result = checkWhitelist()
        if status then
            if result == "Lifetime" then
                Rayfield:Notify({Title = "Whitelist", Content = "Lifetime access confirmed", Duration = 2})
            else
                Rayfield:Notify({Title = "Whitelist", Content = "Access confirmed. " .. result .. " days left", Duration = 2})
            end
        else
            Rayfield:Notify({Title = "Whitelist", Content = result, Duration = 2})
        end
    end
})

-- Обновляем Watermark
updateWatermarkWithMainNick()

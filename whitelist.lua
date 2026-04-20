-- Whitelist System with Info Display (No Buttons)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- НАСТРОЙКИ - ИЗМЕНИ ПОД СЕБЯ
local WHITELIST_URL = "https://raw.githubusercontent.com/ТВОЙ_АКК/ТВОЙ_РЕПО/main/whitelist.json"

local userData = nil

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

-- СОЗДАНИЕ ИНФОРМАЦИОННОГО ОКНА В ПРАВОМ ВЕРХНЕМ УГЛУ
local function createInfoDisplay()
    local infoGui = Instance.new("ScreenGui")
    infoGui.Name = "UserInfoDisplay"
    infoGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    infoGui.IgnoreGuiInset = true
    infoGui.Parent = game.CoreGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 220, 0, 70)
    mainFrame.Position = UDim2.new(1, -230, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = infoGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 190, 40)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = mainFrame
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 22)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(255, 190, 40)
    title.BackgroundTransparency = 0.2
    title.Text = "USER INFO"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 10
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title
    
    -- Main Nickname
    local mainNickLabel = Instance.new("TextLabel")
    mainNickLabel.Name = "MainNick"
    mainNickLabel.Size = UDim2.new(1, -10, 0, 20)
    mainNickLabel.Position = UDim2.new(0, 5, 0, 24)
    mainNickLabel.BackgroundTransparency = 1
    mainNickLabel.Text = "Nick: " .. (userData and userData.mainNickname or "Loading...")
    mainNickLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainNickLabel.TextSize = 11
    mainNickLabel.Font = Enum.Font.GothamBold
    mainNickLabel.TextXAlignment = Enum.TextXAlignment.Left
    mainNickLabel.Parent = mainFrame
    
    -- Subscription
    local subLabel = Instance.new("TextLabel")
    subLabel.Name = "SubLabel"
    subLabel.Size = UDim2.new(1, -10, 0, 18)
    subLabel.Position = UDim2.new(0, 5, 0, 44)
    subLabel.BackgroundTransparency = 1
    subLabel.TextSize = 10
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.Parent = mainFrame
    
    -- Обновление информации
    local function updateDisplay()
        if not userData then return end
        
        mainNickLabel.Text = "Nick: " .. userData.mainNickname
        
        if userData.isLifetime then
            subLabel.Text = "Sub: Lifetime"
            subLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            local days = getDaysRemaining(userData.expiryDate, false)
            if days then
                subLabel.Text = "Sub: " .. days .. " days left"
                if days <= 7 then
                    subLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                else
                    subLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                end
            else
                subLabel.Text = "Sub: Expired"
                subLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            end
        end
    end
    
    updateDisplay()
    
    -- Обновляем каждую минуту
    task.spawn(function()
        while infoGui and userData do
            task.wait(60)
            updateDisplay()
        end
    end)
    
    -- Перетаскивание окна
    local dragging = false
    local dragStart, frameStart
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newX = frameStart.X.Offset + delta.X
            local newY = frameStart.Y.Offset + delta.Y
            mainFrame.Position = UDim2.new(frameStart.X.Scale, newX, frameStart.Y.Scale, newY)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return infoGui
end

-- ЗАПУСК ПРОВЕРКИ
local whitelistStatus, whitelistResult = checkWhitelist()

if not whitelistStatus then
    -- Показываем сообщение об ошибке и кикаем
    local errorGui = Instance.new("ScreenGui")
    errorGui.Parent = game.CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 100)
    frame.Position = UDim2.new(0.5, -150, 0.5, -50)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = errorGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -20, 1, -20)
    text.Position = UDim2.new(0, 10, 0, 10)
    text.BackgroundTransparency = 1
    text.Text = whitelistResult
    text.TextColor3 = Color3.fromRGB(255, 100, 100)
    text.TextSize = 14
    text.Font = Enum.Font.GothamBold
    text.TextWrapped = true
    text.Parent = frame
    
    task.wait(2)
    kickPlayer(whitelistResult)
    return
end

-- Если прошел вайтлист - создаем информационное окно
createInfoDisplay()

-- Меняем Watermark на Main Nickname
local function updateWatermark()
    task.wait(0.5)
    local watermarkFrame = game.CoreGui:FindFirstChild("TenzoSenseWatermark")
    if watermarkFrame then
        local container = watermarkFrame:FindFirstChild("Container")
        if container then
            local usernameLabel = container:FindFirstChild("UsernameLabel")
            if usernameLabel and userData then
                usernameLabel.Text = userData.mainNickname
            end
        end
    end
end

updateWatermark()

-- Уведомление (если Rayfield загружен)
task.wait(1)
if Rayfield then
    local daysText = ""
    if whitelistResult == "Lifetime" then
        daysText = "Lifetime"
    elseif type(whitelistResult) == "number" then
        daysText = whitelistResult .. " days left"
    end
    Rayfield:Notify({
        Title = "Welcome",
        Content = userData.mainNickname .. " | " .. daysText,
        Duration = 3,
        Image = "user-check"
    })
end

print("Whitelist: Access granted for " .. userData.mainNickname)

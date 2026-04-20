-- Whitelist System - Исправленный
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- ССЫЛКА НА ТВОЙ ФАЙЛ НА GITHUB
local WHITELIST_URL = "https://raw.githubusercontent.com/tenzarek/whitelist/refs/heads/main/whitelist.json"

local userData = nil

-- ИСПРАВЛЕННАЯ функция для расчета дней
local function getDaysLeft(dateString)
    if dateString == "" then return -1 end
    
    local day, month, year = dateString:match("(%d+)%.(%d+)%.(%d+)")
    if not day then 
        return nil 
    end
    
    -- Устанавливаем время окончания на конец дня (23:59:59)
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
    
    -- +1 чтобы показывало оставшиеся дни включая сегодня
    return math.floor(diff / 86400) + 1
end

-- Проверка вайтлиста
local function checkWhitelist()
    local success, data = pcall(function()
        return loadstring(game:HttpGet(WHITELIST_URL))()
    end)
    
    if not success then
        return false, "Ошибка загрузки"
    end
    
    local currentName = LocalPlayer.Name
    
    for _, user in ipairs(data) do
        for _, nick in ipairs(user.robloxNicknames) do
            if string.lower(nick) == string.lower(currentName) then
                userData = user
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

-- Информационное окно
local function showInfo()
    local gui = Instance.new("ScreenGui")
    gui.Name = "UserInfo"
    gui.Parent = game.CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 60)
    frame.Position = UDim2.new(1, -210, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
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

-- ЗАПУСК
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

-- Успех - показываем информацию
local infoGui = showInfo()

-- Меняем Watermark
task.wait(0.5)
local wm = game.CoreGui:FindFirstChild("TenzoSenseWatermark")
if wm and wm:FindFirstChild("Container") then
    local uname = wm.Container:FindFirstChild("UsernameLabel")
    if uname then
        uname.Text = userData.mainNickname
    end
end

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

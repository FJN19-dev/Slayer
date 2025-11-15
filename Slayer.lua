-- ======= Checa se entrou no jogo e define time =======
if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Main (minimal)") then
    repeat wait()
        local l_Remotes_0 = game.ReplicatedStorage:WaitForChild("Remotes")
        l_Remotes_0.CommF_:InvokeServer("SetTeam", getgenv().team or "Marines")
        task.wait(3)
    until not game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Main (minimal)")
end

-- ======= Dependências =======
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

-- ======= Config =======
local Config = {
    AutoFarmFruit = true,
    AutoStoreFruits = true,
    WebhookSpawnEnabled = false,
    WebhookStoreEnabled = false,
    WebhookSpawnURL = "",
    WebhookStoreURL = ""
}

-- ======= Raridades =======
local Rarities = {
    ["Mythical"] = {"Gravity", "Mamute", "T-Rex", "Massa", "Shadow","Venom","Gas","Control","Spirit","Leopard","Yeti","Kitsune","Dragão"},
    ["Legendary"] = {"Quake","Buddha","Love","Creation","Spider","Sound","Phoenix","Portal","Lightning","Pain","Nevasca"},
    ["Epic"] = {"Luz","Rubber","Ghost","Magma"},
    ["Rare"] = {"Flame","Ice","Areia","Dark","Eagle","Diamante"},
    ["Common"] = {"Rocket","Spin","Blade","Spring","Bomb","Smoke","Spike"}
}

local function GetRarity(fruitName)
    fruitName = string.lower(fruitName)
    for rarity, fruits in pairs(Rarities) do
        for _, v in ipairs(fruits) do
            if string.find(fruitName, string.lower(v)) then
                return rarity
            end
        end
    end
    return "Unknown"
end

-- ======= Tween =======
local function TweenToFruit(fruit)
    if fruit and fruit:IsDescendantOf(workspace) and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Player.Character.HumanoidRootPart
        local distance = (hrp.Position - fruit.Position).Magnitude
        local speed = 100
        local tweenTime = math.clamp(distance / speed, 0.1, 5)
        local tween = TweenService:Create(hrp, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = fruit.CFrame + Vector3.new(0,5,0)})
        tween:Play()
        tween.Completed:Wait()
    end
end

-- ======= Webhook =======
local function SendWebhookEmbed(url, fruitName, eventType)
    if url == "" then return end
    pcall(function()
        local rarity = GetRarity(fruitName)
        local mention = ""
        if rarity=="Legendary" or rarity=="Mythical" then mention="<@1162529172460154942>" end
        local data = {
            content = mention,
            embeds = {{
                title = "⚡ Slayer Hub Notification",
                description = "**"..eventType.."**",
                color = 0x9b59b6,
                fields = {
                    {name="👤 Username", value=Player.Name, inline=true},
                    {name="🍏 Fruit", value="```"..fruitName.."```", inline=true},
                    {name="⭐ Rarity", value=rarity, inline=true},
                    {name="⏰ Time", value=os.date("%Y-%m-%d %H:%M:%S"), inline=true},
                    {name="🌍 PlaceId", value=tostring(game.PlaceId), inline=true}
                },
                thumbnail={url="https://cdn.discordapp.com/attachments/1345800682330132540/1414000702786899988/IMG_20250906_183313.jpg"},
                footer={text="Slayer Hub • Hoje às "..os.date("%H:%M")}
            }}
        }
        local req = syn and syn.request or http_request or request
        req({Url=url, Method="POST", Headers={["Content-Type"]="application/json"}, Body=HttpService:JSONEncode(data)})
    end)
end

-- ======= AutoStore =======
local function AutoStore()
    pcall(function()
        local plrBag = Player.Backpack
        local plrChar = Player.Character
        for _, Fruit in pairs(plrChar:GetChildren()) do
            if Fruit:IsA("Tool") and Fruit:FindFirstChild("Fruit") then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", Fruit.Name, Fruit)
                if Config.WebhookStoreEnabled then SendWebhookEmbed(Config.WebhookStoreURL, Fruit.Name, "🍇 Fruta Armazenada!") end
            end
        end
        for _, Fruit in pairs(plrBag:GetChildren()) do
            if Fruit:IsA("Tool") and Fruit:FindFirstChild("Fruit") then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", Fruit.Name, Fruit)
                if Config.WebhookStoreEnabled then SendWebhookEmbed(Config.WebhookStoreURL, Fruit.Name, "🍇 Fruta Armazenada!") end
            end
        end
    end)
end

-- ======= ServerHop =======
local function ServerHop()
    local servers = {}
    local req = syn and syn.request or http_request or request
    local response = req({Url=string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)})
    local data = HttpService:JSONDecode(response.Body)
    for _, v in pairs(data.data) do
        if v.playing < v.maxPlayers then table.insert(servers,v.id) end
    end
    if #servers>0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1,#servers)], Player)
    end
end

-- ======= GUI e HUD =======
local BgGui = Instance.new("ScreenGui")
BgGui.Parent = Player:WaitForChild("PlayerGui")
BgGui.IgnoreGuiInset = true
BgGui.ResetOnSpawn = false

local BgImage = Instance.new("ImageLabel")
BgImage.Parent = BgGui
BgImage.Size = UDim2.new(0,420,0,260)
BgImage.Position = UDim2.new(0.5,0,0.5,0)
BgImage.AnchorPoint = Vector2.new(0.5,0.5)
BgImage.Image = "rbxassetid://87012011222284"
BgImage.BackgroundTransparency = 0.7
BgImage.ZIndex = 0
BgImage.ScaleType = Enum.ScaleType.Crop
local UICorner = Instance.new("UICorner", BgImage)
UICorner.CornerRadius = UDim.new(0,25)

local FruitCountLabel = Instance.new("TextLabel")
FruitCountLabel.Parent = BgGui
FruitCountLabel.Size = UDim2.new(0,200,0,30)
FruitCountLabel.Position = UDim2.new(1,-10,1,-10)
FruitCountLabel.AnchorPoint = Vector2.new(1,1)
FruitCountLabel.BackgroundTransparency = 1
FruitCountLabel.TextColor3 = Color3.fromRGB(255,0,0)
FruitCountLabel.Font = Enum.Font.GothamBold
FruitCountLabel.TextScaled = true
FruitCountLabel.Text = "Fruta Spawn: 0"
FruitCountLabel.ZIndex = 2
FruitCountLabel.TextStrokeTransparency = 0.5

-- ======= Loop Principal =======
task.spawn(function()
    local trackedFruits = {}
    local fruitCount = 0
    while task.wait(1) do
        if Config.AutoFarmFruit then
            local fruitsFound = false
            pcall(function()
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj:IsA("Tool") and obj:FindFirstChild("Handle") and string.find(obj.Name,"Fruit") then
                        fruitsFound = true
                        if not trackedFruits[obj] then
                            fruitCount += 1
                            trackedFruits[obj] = true
                            FruitCountLabel.Text = "Fruta Spawn: "..fruitCount
                            if Config.WebhookSpawnEnabled then SendWebhookEmbed(Config.WebhookSpawnURL,obj.Name,"🍉 Fruta Spawnou!") end
                        end
                        TweenToFruit(obj.Handle)
                        task.wait(0.5)
                        firetouchinterest(Player.Character.HumanoidRootPart,obj.Handle,0)
                        firetouchinterest(Player.Character.HumanoidRootPart,obj.Handle,1)
                        task.wait(1)
                        if Config.AutoStoreFruits then AutoStore() end
                    end
                end
            end)
            if not fruitsFound then ServerHop() end
        end
    end
end)

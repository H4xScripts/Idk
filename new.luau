repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

local Window = Library:CreateWindow{
    Title = `H4xScript | Grow A Garden 4.1.0`,
    SubTitle = " discord.gg/H4xScript",
    TabWidth = 150,
    Size = UDim2.fromOffset(580, 413),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
}
--minimzie button
UIS = game:GetService("UserInputService")
local screenGui
repeat
    task.wait()
    for _, v in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if v:IsA("ScreenGui") and v:FindFirstChildWhichIsA("Frame") then
            screenGui = v
            break
        end
    end
until screenGui

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 40, 0, 40)
minimizeButton.Position = UDim2.new(0.5, -20, 0.5, -20)
minimizeButton.AnchorPoint = Vector2.new(0.5, 0.5)
minimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
minimizeButton.BorderSizePixel = 0
minimizeButton.Text = ""
minimizeButton.AutoButtonColor = false
minimizeButton.ZIndex = 999
minimizeButton.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = minimizeButton

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 100, 100)
stroke.Thickness = 1
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = minimizeButton

local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0.8, 0, 0.8, 0)
icon.Position = UDim2.new(0.5, 0, 0.5, 0)
icon.AnchorPoint = Vector2.new(0.5, 0.5)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://108875627240308"
icon.ZIndex = 1000
icon.Parent = minimizeButton

local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 4, 1, 4)
shadow.Position = UDim2.new(0.5, 2, 0.5, 2)
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxasset://textures/ui/Shadow.png"
shadow.ImageTransparency = 0.5
shadow.ZIndex = 998
shadow.Parent = minimizeButton

minimizeButton.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

local UiDragging = false
local UiDragStart, UiStartPos

minimizeButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        UiDragging = true
        UiDragStart = input.Position
        UiStartPos = minimizeButton.Position
    end
end)

minimizeButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        UiDragging = true
        UiDragStart = input.Position
        UiStartPos = minimizeButton.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if UiDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - UiDragStart
        minimizeButton.Position = UDim2.new(UiStartPos.X.Scale, UiStartPos.X.Offset + delta.X, UiStartPos.Y.Scale, UiStartPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        UiDragging = false
    end
end)

local TweenService = game:GetService("TweenService")
local hoverTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
minimizeButton.MouseEnter:Connect(function()
    TweenService:Create(minimizeButton, hoverTweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
    TweenService:Create(stroke, hoverTweenInfo, {Color = Color3.fromRGB(150, 150, 150)}):Play()
end)

minimizeButton.MouseLeave:Connect(function()
    TweenService:Create(minimizeButton, hoverTweenInfo, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
    TweenService:Create(stroke, hoverTweenInfo, {Color = Color3.fromRGB(100, 100, 100)}):Play()
end)

MainTab = Window:CreateTab{
	Title = "Main",
	Icon = "code"
}
EventTab = Window:CreateTab{
	Title = "Events",
	Icon = "calendar-check"
}
ShopTab = Window:CreateTab{
	Title = "Shop",
	Icon = "shopping-cart"
}
MiscTab = Window:CreateTab{
	Title = "Misc",
	Icon = "align-left"
}
InventoryTab = Window:CreateTab{
	Title = "Inventory",
	Icon = "archive"
}
VisualsTab = Window:CreateTab{
	Title = "Visuals",
	Icon = "eye"
}
SettingTab = Window:CreateTab{
	Title = "Settings",
	Icon = "settings"
}
UpdateTab = Window:CreateTab{
	Title = "Updates",
	Icon = "scroll"
}
Window:SelectTab(1)

local Service = {
	ws = game:GetService("Workspace"),
	Players = game:GetService("Players"),
	CoreGui = game:GetService("CoreGui"),
	RunService = game:GetService("RunService"),
	GuiService = game:GetService("GuiService"),
	StarterGui = game:GetService("StarterGui"),
	VirtualUser = game:GetService("VirtualUser"),
	HttpService = game:GetService("HttpService"),
	TweenService = game:GetService("TweenService"),
	TeleportService = game:GetService("TeleportService"),
	UserInputService = game:GetService("UserInputService"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	VirtualInputManager = game:GetService("VirtualInputManager"),
}
local RemoteEvents = {
	ActivePetService = Service.ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("ActivePetService"),
	SubmitEvent = Service.ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("HoneyMachineService_RE"),
	BuyBananaEvent = Service.ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuySeedStock"),
	BuyPetEgg = Service.ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyPetEgg"),
	favoriteEvent = Service.ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Favorite_Item"),
	SellEvent = Service.ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Inventory"),
	SellHandEvent = Service.ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Item"),
	seedRemote = Service.ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuySeedStock"),
	honeyRemote = Service.ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyEventShopStock"),
	gearRemote = Service.ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyGearStock"),
	RemoveItem = Service.ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Remove_Item"),
	plantRemote = Service.ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Plant_RE"),
	HoneyCrafterRemoteEvent = Service.ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("HoneyCrafterRemoteEvent"),
	SummerHarvestRemoteEvent = Service.ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("SummerHarvestRemoteEvent")
}

local lp = Service.Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local oldCFrame = hrp.CFrame
local leaderstats = lp:FindFirstChild("leaderstats")
local shecklesStat = leaderstats and leaderstats:FindFirstChild("Sheckles")
local backpack = lp:WaitForChild("Backpack")
local humanoid = char:FindFirstChildOfClass("Humanoid")
local GameGui = {
	seedPath = lp.PlayerGui.Seed_Shop.Frame.ScrollingFrame,
	gearPath = lp.PlayerGui.Gear_Shop.Frame.ScrollingFrame,
	gearicon = lp.PlayerGui.Teleport_UI.Frame.Gear,
	peticon = lp.PlayerGui.Teleport_UI.Frame.Pets,
	honeyUI = lp.PlayerGui.Honey_UI.Frame.TextLabel1,
	gardenPath = lp.PlayerGui.Teleport_UI.Frame.Garden,
}

local TeleportUiParent = GameGui.gardenPath.Parent

if not TeleportUiParent:FindFirstChild("TeleportUi") then
	local TeleportUi = GameGui.gardenPath:Clone()
	TeleportUi.Name = "TeleportUi"
	local txtLabel = TeleportUi:WaitForChild("Txt")
	txtLabel.Text = "EVENT"
	TeleportUi.Parent = TeleportUiParent
	TeleportUi.MouseButton1Click:Connect(function()
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = CFrame.new(-84, 5, -2)
		end
	end)
end

local AutoSubmitSummerThread
local summerFruits = {
	"Carrot","Strawberry","Blueberry","Tomato","Cauliflower", "Watermelon", "Green Apple",
	"Avocado", "Banana", "Pineapple","Kiwi", "Bell Pepper", "Prickly Pear", "Loquat", "Feijaoa"
}
local seedItems =           {
	"Carrot","Strawberry","Blueberry","Tomato","Cauliflower","Watermelon","Green Apple","Avacado","Banana","Pineapple","Kiwi","Bell Pepper",
	"Prickly Pear","Loquat","Feijoa","Sugar Apple"
}
local gearItems =           {
	"Watering Can","Trowel","Recall Wrench","Basic Sprinkler","Advanced Sprinkler",
	"Godly Sprinkler","Tanning Mirror","Master Sprinkler","Cleaning Spray","Favorite Tool", "Harvest Tool", "Friendship Pot"
}
local honeyItems =          {
	"Flower Seed Pack","Lavender","Nectarshade","Nectarine", "Hive Fruit","Pollen Radar","Nectar Staff","Honey Sprinkler", "Bee Egg", "Bee Crate", "Honey Comb", "Bee Chair", "Honey Torch", "Honey Walkway"
}
local mutationOptions = {
	"Dawnbound", "Voidtouched", "Disco", "Meteoric", "Celestial", "Galactic", "Alienlike", 
	"Shocked", "Sundried", "Zombified", "Molten", "Paradisal", "Cooked", "Frozen", "Plasma", 
	"Twisted", "HoneyGlazed", "Heavenly", "Bloodlit", "Burnt", "Verdant", "Pollinated", 
	"Chilled", "Moonlit", "Windstruck"
}

local selectedMutations =   {}
local seedNames = {
	"Apple", "Avocado", "Bamboo", "Banana", "Beanstalk", "Bee Balm", "Bell Pepper", "Blood Banana",
	"Blueberry", "Cactus", "Candy Blossom", "Candy Sunflower", "Cantaloupe", "Carrot", "Cauliflower",
	"Celestiberry", "Cherry Blossom", "Chocolate Carrot", "Cocovine", "Coconut", "Corn", "Cranberry",
	"Crimson Vine", "Crocus", "Cursed Fruit", "Daffodil", "Dandelion", "Dragon Fruit", "Dragon Pepper",
	"Durian", "Easter Egg", "Eggplant", "Elephant Ears", "Ember Lily", "Feijoa", "Foxglove",
	"Glowshroom", "Grape", "Green Apple", "Hive Fruit", "Honeysuckle", "Ice Cream Bean", "Kiwi",
	"Lavender", "Lemon", "Lilac", "Lime", "Loquat", "Lotus", "Lumira", "Mango", "Manuka Flower",
	"Mint", "Moon Blossom", "Moon Mango", "Moon Melon", "Moonflower", "Moonglow", "Mushroom",
	"Nectar Thorn", "Nectarine", "Nectarshade", "Nightshade", "Noble Flower", "Orange Tulip",
	"Papaya", "Parasol Flower", "Passionfruit", "Peach", "Pear", "Pepper", "Pineapple", "Pink Lily",
	"Prickly Pear", "Pumpkin", "Raspberry", "Red Lollipop", "Rose", "Rosy Delight", "Soul Fruit",
	"Starfruit", "Strawberry", "Succulent", "Sugar Apple", "Suncoil", "Sunflower", "Tomato",
	"Traveler's Fruit", "Venus Fly Trap", "Violet Corn", "Wild Carrot"
}

local fruitNames = {
	"Apple", "Avocado", "Bamboo", "Banana", "Beanstalk", "Bee Balm", "Bell Pepper", "Blood Banana",
	"Blue Lollipop", "Blueberry", "Cactus", "Candy Blossom", "Candy Sunflower", "Cantaloupe", 
	"Carrot", "Cauliflower", "Celestiberry", "Cherry Blossom", "Chocolate Carrot", "Cocovine", 
	"Coconut", "Corn", "Cranberry", "Crimson Vine", "Crocus", "Cucumber", "Cursed Fruit", 
	"Daffodil", "Dandelion", "Dragon Fruit", "Dragon Pepper", "Durian", "Easter Egg", "Eggplant", 
	"Elephant Ears", "Ember Lily", "Feijoa", "Foxglove", "Glowshroom", "Grape", "Green Apple", 
	"Hive Fruit", "Honeysuckle", "Ice Cream Bean", "Kiwi", "Lavender", "Lemon", "Lilac", "Lime", 
	"Loquat", "Lotus", "Lumira", "Mango", "Manuka Flower", "Mint", "Moon Blossom", "Moon Mango", 
	"Moon Melon", "Moonflower", "Moonglow", "Mushroom", "Nectar Thorn", "Nectarine", 
	"Nectarshade", "Nightshade", "Noble Flower", "Orange Tulip", "Papaya", "Parasol Flower", 
	"Passionfruit", "Peach", "Pear", "Pepper", "Pineapple", "Pink Lily", "Pink Tulip", 
	"Prickly Pear", "Pumpkin", "Purple Cabbage", "Purple Dahlia", "Raspberry", "Red Lollipop", 
	"Rose", "Rosy Delight", "Soul Fruit", "Starfruit", "Strawberry", "Succulent", "Sugar Apple", 
	"Suncoil", "Sunflower", "Tomato", "Traveler's Fruit", "Venus Fly Trap", "Violet Corn", 
	"Watermelon", "Wild Carrot"
}
local ToggleE = {
	AutoFeedPetLoaded = true,
	autoBuyEnabled = false,
	AF_feedingEnabled = false,
	autoFarmEnabled = false,
	fastClickEnabled = false,
	autoSellEnabled = false,
	EventFarmEnabled = false,
	flyEnabled = false,
	noclip = false,
	AutoPlanting = false,
	CurrentlyPlanting = false,
	EventGiveEnabled = false,
	autoFavoriteEnabled = false,
	infJump = false,
	Ftoggle = false,
	autoBlood = false,
	CollectHoneyEnabled = false,
	autoBuyCosmeticsEnabled = false,
	autoBuyAllCosmeticsEnabled = false,
	autoBuySeedsEnabled = false,
	autoBuyGearsEnabled = false,
	autoBuyHoneyItemsEnabled = false,
	autoBuyEggsEnabled = false,
	AutoSubmitHoneyEnabled = false,
	AutoSubmitFruitEnabled = false, 
	AutoCraftEnabled = false, 
	AutoSubmitSummerFruitsEnabled = false
}


local selectedSeeds, selectedGears, selectedHoneyItems, AF_feedingPets, farms, plants = {}, {}, {}, {}, {}, {}

local Npc =                {
	Steven = Service.ws.NPCS:FindFirstChild("Steven")
}

GameGui.gearicon.Active = true
GameGui.gearicon.Visible = true
GameGui.gearicon.ImageColor3 = Color3.fromRGB(255, 255, 255)
GameGui.peticon.Active = true
GameGui.peticon.Visible = true


-- auto sumbit Summer frutis
local function AutoSubmitSummerFruits(state)
	ToggleE.AutoSubmitSummerFruitsEnabled = state
	if AutoSubmitSummerThread then
		task.cancel(AutoSubmitSummerThread)
		AutoSubmitSummerThread = nil
	end
	if state then
		AutoSubmitSummerThread = task.spawn(function()
			while ToggleE.AutoSubmitSummerFruitsEnabled do
				if workspace:GetAttribute("SummerHarvest") == true then
					if backpack and char and humanoid then
						game:GetService("ReplicatedStorage").GameEvents.SummerHarvestRemoteEvent:FireServer("SubmitAllPlants")
					end
				end
				task.wait(3)
			end
		end)
	end
end

-- auto feed modules 
local AF_selectedFruit = "Carrot"
local AF_petsFolder = workspace:WaitForChild("PetsPhysical")
local function safeRequire(path)
	local s, r = pcall(require, path)
	if not s then
		ToggleE.AutoFeedPetLoaded = false
	end
	return (s and r) or nil
end
local AF_petService = safeRequire(game:GetService("ReplicatedStorage").Modules.PetServices.ActivePetsService)
local AF_petRegistry = safeRequire(game:GetService("ReplicatedStorage").Data.PetRegistry)

--Money Prase
local function parseMoney(moneyStr)
	if not moneyStr then
		return 0
	end
	moneyStr = tostring(moneyStr):gsub("Â¢", ""):gsub("¢", ""):gsub(",", ""):gsub(" ", ""):gsub("%$", "")
	local multiplier = 1
	if moneyStr:lower():find("k") then
		multiplier = 1000
		moneyStr = moneyStr:lower():gsub("k", "")
	elseif moneyStr:lower():find("m") then
		multiplier = 1000000
		moneyStr = moneyStr:lower():gsub("m", "")
	end
	local number = tonumber(moneyStr) or 0
	return (number * multiplier) / 100
end
local function getPlayerMoney()
	return parseMoney((shecklesStat and shecklesStat.Value) or 0)
end

local function isInventoryFull()
local count = 0
for _, item in pairs(backpack:GetChildren()) do
	if item:IsA("Tool") and item:GetAttribute("b") == "j" then
		count += 1
	end
end
return count >= 200
end



-- Global exclusion arrays
local excludedVariants = {}
local excludedMutations = {}
local excludeFruits = {}
local excludeWeight = nil

-- Consolidated exclusion check function
local function hasExcludedMutationOrVariant(model)
    for _, mutation in pairs(excludedMutations) do
        if model:GetAttribute(mutation) == true then
            return true
        end
    end
    local variant = model:FindFirstChild("Variant")
    if variant and variant:IsA("StringValue") and table.find(excludedVariants, variant.Value) then
        return true
    end
    for _, fruit in pairs(excludeFruits) do
        if model.Name:lower():find(fruit:lower()) then
            return true
        end
    end
    if excludeWeight then
        local weight = model:FindFirstChild("Weight")
        if weight and weight:IsA("NumberValue") and weight.Value >= excludeWeight then
            return true
        end
    end
    return false
end



--auto farm
local function updateFarmData()
    farms = {}
    plants = {}
    local farmFolder = workspace:FindFirstChild("Farm")
    if not farmFolder then
        return
    end
    for _, farm in pairs(farmFolder:GetChildren()) do
        local important = farm:FindFirstChild("Important")
        local data = important and important:FindFirstChild("Data")
        if (data and data:FindFirstChild("Owner") and (data.Owner.Value == lp.Name)) then
            table.insert(farms, farm)
            local plantsFolder = important:FindFirstChild("Plants_Physical")
            if plantsFolder then
                for _, plantModel in pairs(plantsFolder:GetChildren()) do
                    if not hasExcludedMutationOrVariant(plantModel) then
                        local fruits = plantModel:FindFirstChild("Fruits")
                        if fruits then
                            for _, fruit in pairs(fruits:GetChildren()) do
                                if not hasExcludedMutationOrVariant(fruit) then
                                    table.insert(plants, fruit)
                                end
                            end
                        else
                            table.insert(plants, plantModel)
                        end
                    end
                end
            end
        end
    end
end


local function instantFarm()
    if farmThread then
        task.cancel(farmThread)
    end
    farmThread = task.spawn(function()
        local Event = Service.ReplicatedStorage.ByteNetReliable
        while ToggleE.autoFarmEnabled do
            while isInventoryFull() do
                if not ToggleE.autoFarmEnabled then
                    return
                end
                local soundService = game:GetService("SoundService")
                local notificationSound = soundService:FindFirstChild("Notification")
                if notificationSound then
                    notificationSound:Play()
                end
                
                game.StarterGui:SetCore("SendNotification", {
                    Title = "H4xScript",
                    Text = "Inventory Full",
                    Duration = 4,
                    Icon = "rbxassetid://108875627240308"
                })
                
                task.wait(1)
            end
            if not ToggleE.autoFarmEnabled then
                return
            end
            updateFarmData()
            for _, fruit in pairs(plants) do
                if (not ToggleE.autoFarmEnabled or isInventoryFull()) then
                    break
                end
                if (fruit and fruit.Parent and not hasExcludedMutationOrVariant(fruit)) then
                    Event:FireServer(table.unpack({
                        (function(bytes)
                            local b = buffer.create(#bytes)
                            for i = 1, #bytes do
                                buffer.writeu8(b, i - 1, bytes[i])
                            end
                            return b
                        end)({ 1, 1, 0, 1 }),
                        { fruit }
                    }))
                    task.wait()
                end
            end
            if ToggleE.autoFarmEnabled then
                task.wait()
            end
        end
    end)
end

-- auto collect
local fastClickThread
local CLICK_DELAY = 0.01
local MAX_DISTANCE = 20

local function isValidPrompt(prompt)
    local parent = prompt.Parent
    if not parent then
        return false
    end
    local model = parent:FindFirstAncestorOfClass("Model")
    if not model then
        return false
    end
    if hasExcludedMutationOrVariant(model) then
        return false
    end
    local name = parent.Name:lower()
    return not (name:find("sign") or name:find("core"))
end

local function getNearbyPrompts()
    local nearby = {}
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return nearby
    end
    local farmFolder = workspace:FindFirstChild("Farm")
    if not farmFolder then
        return nearby
    end
    for _, farm in pairs(farmFolder:GetChildren()) do
        local important = farm:FindFirstChild("Important")
        local data = important and important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value == lp.Name then
            local plantsFolder = important:FindFirstChild("Plants_Physical")
            if plantsFolder then
                for _, plant in pairs(plantsFolder:GetChildren()) do
                    if not hasExcludedMutationOrVariant(plant) then
                        local fruits = plant:FindFirstChild("Fruits")
                        if fruits then
                            for _, fruit in pairs(fruits:GetChildren()) do
                                for _, part in pairs(fruit:GetChildren()) do
                                    if part:IsA("BasePart") then
                                        local prompt = part:FindFirstChildOfClass("ProximityPrompt")
                                        if prompt and isValidPrompt(prompt) then
                                            local dist = (hrp.Position - part.Position).Magnitude
                                            if dist <= MAX_DISTANCE then
                                                table.insert(nearby, prompt)
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            for _, part in pairs(plant:GetChildren()) do
                                if part:IsA("BasePart") then
                                    local prompt = part:FindFirstChildOfClass("ProximityPrompt")
                                    if prompt and isValidPrompt(prompt) then
                                        local dist = (hrp.Position - part.Position).Magnitude
                                        if dist <= MAX_DISTANCE then
                                            table.insert(nearby, prompt)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return nearby
end

local function fastClickFarm()
    if fastClickThread then
        task.cancel(fastClickThread)
    end
    fastClickThread = task.spawn(function()
        while ToggleE.fastClickEnabled do
            if isInventoryFull() then
                local soundService = game:GetService("SoundService")
                local notificationSound = soundService:FindFirstChild("Notification")
                if notificationSound then
                    notificationSound:Play()
                end
                
                Service.StarterGui:SetCore("SendNotification", {
                    Title = "H4xScript - Auto Farm",
                    Text = "Inventory Full",
                    Duration = 3
                })
                task.wait(1)

                continue
            end
            local prompts = getNearbyPrompts()
            for _, prompt in pairs(prompts) do
                if not ToggleE.fastClickEnabled then
                    return
                end
                if isInventoryFull() then
                    break
                end
                fireproximityprompt(prompt, 1)
                task.wait(CLICK_DELAY)
            end
            task.wait(0.1)
        end
    end)
end


--auto sell 
local autoSellThread
local function sellItems()
	if not Npc.Steven then
		return false
	end
	if not char then
		return false
	end
	if not hrp then
		return false
	end
	if not backpack then
		return false
	end
	local originalPosition = hrp.CFrame
	hrp.CFrame = Npc.Steven.HumanoidRootPart.CFrame * CFrame.new(0, 3, 3)
	task.wait()
	for _ = 1, 5 do
		pcall(function()
			RemoteEvents.SellEvent:FireServer()
		end)
		task.wait(0.15)
	end
	local startTime = tick()
	while backpack and isInventoryFull() and ((tick() - startTime) < 5) do
		task.wait(0.1)
		backpack = lp:FindFirstChildOfClass("Backpack")
	end
	hrp.CFrame = originalPosition
	return true
end


-- Fly
local flySpeed = 48
local bodyVelocity, bodyGyro
local flightConnection
local function Fly(state)
	ToggleE.flyEnabled = state
	if ToggleE.flyEnabled then
		if (not char or not char:FindFirstChild("HumanoidRootPart")) then
			return
		end
		if not humanoid then
			return
		end
		bodyGyro = Instance.new("BodyGyro")
		bodyVelocity = Instance.new("BodyVelocity")
		bodyGyro.P = 9000
		bodyGyro.maxTorque = Vector3.new(8999999488, 8999999488, 8999999488)
		bodyGyro.cframe = char.HumanoidRootPart.CFrame
		bodyGyro.Parent = char.HumanoidRootPart
		bodyVelocity.velocity = Vector3.new(0, 0, 0)
		bodyVelocity.maxForce = Vector3.new(8999999488, 8999999488, 8999999488)
		bodyVelocity.Parent = char.HumanoidRootPart
		humanoid.PlatformStand = true
		flightConnection = Service.RunService.Heartbeat:Connect(function()
			if (not ToggleE.flyEnabled or not char:FindFirstChild("HumanoidRootPart")) then
				if flightConnection then
					flightConnection:Disconnect()
				end
				return
			end
			local cam = workspace.CurrentCamera.CFrame
			local moveVec = Vector3.new()
			if Service.UserInputService:IsKeyDown(Enum.KeyCode.W) then
				moveVec = moveVec + cam.LookVector
			end
			if Service.UserInputService:IsKeyDown(Enum.KeyCode.S) then
				moveVec = moveVec - cam.LookVector
			end
			if Service.UserInputService:IsKeyDown(Enum.KeyCode.A) then
				moveVec = moveVec - cam.RightVector
			end
			if Service.UserInputService:IsKeyDown(Enum.KeyCode.D) then
				moveVec = moveVec + cam.RightVector
			end
			if (moveVec.Magnitude > 0) then
				moveVec = moveVec.Unit * flySpeed
			end
			if Service.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				moveVec = moveVec + Vector3.new(0, flySpeed, 0)
			end
			if Service.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				moveVec = moveVec + Vector3.new(0, -flySpeed, 0)
			end
			bodyVelocity.velocity = moveVec
			bodyGyro.cframe = cam
		end)
	else
		if bodyVelocity then
			bodyVelocity:Destroy()
		end
		if bodyGyro then
			bodyGyro:Destroy()
		end
		if char then
			if humanoid then
				humanoid.PlatformStand = false
			end
		end
		if flightConnection then
			flightConnection:Disconnect()
			flightConnection = nil
		end
	end
end


-- no clip
Service.RunService.Stepped:Connect(function()
	if ToggleE.noclip then
		for _, part in ipairs(char:GetDescendants()) do
			if (part:IsA("BasePart") and (part.CanCollide == true)) then
				part.CanCollide = false
			end
		end
	end
end)
local function ToggleNoclip(state)
	ToggleE.noclip = state
end

-- inf jump
Service.UserInputService.JumpRequest:Connect(function()
	if (ToggleE.infJump and char and char:FindFirstChildOfClass("Humanoid")) then
		char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)
local function ToggleInfJump(state)
	ToggleE.infJump = state
end

-- menus 
local function OpenShop()
	local shop = lp.PlayerGui.Seed_Shop
	shop.Enabled = not shop.Enabled
end
local function OpenGearShop()
	local gear = lp.PlayerGui.Gear_Shop
	gear.Enabled = not gear.Enabled
end
local function OpenQuest()
	local quest = lp.PlayerGui.DailyQuests_UI
	quest.Enabled = not quest.Enabled
end
local function OpenHoneyShop()
	local honeyshop = lp.PlayerGui.HoneyEventShop_UI
	honeyshop.Enabled = not honeyshop.Enabled
end
local function OpenCosmeticshop()
	local cosmeticui = lp.PlayerGui.CosmeticShop_UI
	cosmeticui.Enabled = not cosmeticui.Enabled
end

-- sell all
local function SellAll()
	if Npc.Steven then
		hrp.CFrame = Npc.Steven.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
		wait(0.2)
		RemoteEvents.SellEvent:FireServer()
		local farms = workspace:WaitForChild("Farm"):GetChildren()
		for _, farm in pairs(farms) do
			local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
			if (data and data:FindFirstChild("Owner") and (data.Owner.Value == lp.Name)) then
				local spawn = farm:FindFirstChild("Spawn_Point")
				if spawn then
					hrp.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
					break
				end
			end
		end
	end
end

--sell hand
local function HSell()
	if Npc.Steven then
		hrp.CFrame = Npc.Steven.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
		wait(0.2)
		RemoteEvents.SellHandEvent:FireServer()
		local farms = workspace:WaitForChild("Farm"):GetChildren()
		for _, farm in pairs(farms) do
			local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
			if (data and data:FindFirstChild("Owner") and (data.Owner.Value == lp.Name)) then
				local spawn = farm:FindFirstChild("Spawn_Point")
				if spawn then
					hrp.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
					break
				end
			end
		end
	end
end

-- banana dupe
local BananaDupe
local BAnanaDupeE = false
local function DupeBanana()
	if BananaDupe then
		task.cancel(BananaDupe)
	end
	BananaDupe = task.spawn(function()
		while BAnanaDupeE do
			RemoteEvents.BuyBananaEvent:FireServer("Banana")
			task.wait(15)
		end
	end)
end


-- one click remove
local mouse = lp:GetMouse()
local enabled = false
local function OneClickRemove(state)
	enabled = state
	local gui = lp:FindFirstChild("PlayerGui")
	if gui then
		local prompt = gui:FindFirstChild("ShovelPrompt")
		if (prompt and prompt:FindFirstChild("ConfirmFrame")) then
			prompt.ConfirmFrame.Visible = not state
		end
	end
	if enabled then
		mouse.Button1Down:Connect(function()
			local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
			if (not tool or not string.find(tool.Name, "Shovel")) then
				return
			end
			local target = mouse.Target
			if (target and target:IsDescendantOf(workspace) and target:IsA("BasePart")) then
				pcall(function()
					RemoteEvents.RemoveItem:FireServer(target)
				end)
			end
		end)
	end
end

--anti afk
local function AntiAfk()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))();
end


-- anti popup
local function DestroySign()
	for _, farm in pairs(workspace.Farm:GetChildren()) do
		local sign = farm:FindFirstChild("Sign")
		if sign then
			local core = sign:FindFirstChild("Core_Part")
			if core then
				for _, obj in pairs(core:GetDescendants()) do
					if obj:IsA("ProximityPrompt") then
						obj:Destroy()
					end
				end
			end
		end
		local growSign = farm:FindFirstChild("Grow_Sign")
		if growSign then
			for _, obj in pairs(growSign:GetDescendants()) do
				if obj:IsA("ProximityPrompt") then
					obj:Destroy()
				end
			end
		end
	end
end

-- auto fav
local connection = nil
local selectedMutations = {}
local function toolMatchesMutation(toolName)
	if typeof(selectedMutations) ~= "table" then
		selectedMutations = {selectedMutations}
	end
	for _, mutation in pairs(selectedMutations) do
		if string.find(toolName:lower(), mutation:lower()) then
			return true
		end
	end
	return false
end

local function isToolFavorited(tool)
	return tool:GetAttribute("d") or (tool:FindFirstChild("d") and tool.Favorite.Value)
end

local function getFruitTool()
	for _, tool in ipairs(lp.Backpack:GetChildren()) do
		if tool:IsA("Tool") and string.find(tool.Name:lower(), selectedFruit:lower()) and not string.find(tool.Name:lower(), "seed") and not isToolFavorited(tool) then
			return tool
		end
	end
	return nil
end

local function favoriteToolIfMatches(tool)
	if toolMatchesMutation(tool.Name) and not isToolFavorited(tool) then
		local favoriteEvent = game:GetService("ReplicatedStorage").GameEvents.Favorite_Item
		favoriteEvent:FireServer(tool)
		task.wait()
	end
end

local function processBackpack()
	for _, tool in ipairs(lp.Backpack:GetChildren()) do
		favoriteToolIfMatches(tool)
	end
end

local function setupAutoFavorite()
	if connection then
		connection:Disconnect()
	end
	connection = lp.Backpack.ChildAdded:Connect(function(tool)
		task.wait()
		favoriteToolIfMatches(tool)
	end)
	processBackpack()
end

-- Unfav all
local function Unfavall()
for _, tool in ipairs(lp.Backpack:GetChildren()) do
	local isFavorited = tool:GetAttribute("d") or (tool:FindFirstChild("d") and tool.Favorite.Value)
	if isFavorited then
		local favoriteEvent = game:GetService("ReplicatedStorage").GameEvents.Favorite_Item
		favoriteEvent:FireServer(tool)
		task.wait()
	end
end
end

-- auto plant
local SelectedPlantSeeds = {}
local function getPlayerPosition()
	return (hrp and hrp.Position) or Vector3.zero
end
local function getCurrentSeedsInBackpack()
	local result = {}
	for _, tool in ipairs(lp.Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			local base = tool.Name:match("^(.-) Seed")
			if (base and table.find(SelectedPlantSeeds, base)) then
				result[#result + 1] = {BaseName=base,Tool=tool}
			end
		end
	end
	return result
end
local function plantEquippedSeed(seedName)
	local pos = getPlayerPosition()
	RemoteEvents.plantRemote:FireServer(pos, seedName)
end
local function equipTool(tool)
	if (not tool or not tool:IsDescendantOf(lp.Backpack)) then
		return
	end
	pcall(function()
		lp.Character.Humanoid:UnequipTools()
		task.wait(0.1)
		tool.Parent = lp.Character
		while not lp.Character:FindFirstChild(tool.Name) do
			task.wait(0.1)
		end
	end)
end
local function startAutoPlanting()
	if ToggleE.CurrentlyPlanting then
		return
	end
	ToggleE.CurrentlyPlanting = true
	task.spawn(function()
		while ToggleE.AutoPlanting do
			for _, tool in ipairs(lp.Backpack:GetChildren()) do
				if tool:IsA("Tool") then
					local base = tool.Name:match("^(.-) Seed")
					if base and table.find(SelectedPlantSeeds, base) then
						-- Equip and plant this seed
						equipTool(tool)
						task.wait(0.1)
						while ToggleE.AutoPlanting and lp.Character:FindFirstChild(tool.Name) do
							plantEquippedSeed(base)
							task.wait(0.05)
						end
					end
				end
			end
			task.wait(0.05)
		end
		ToggleE.CurrentlyPlanting = false
	end)
end

-- destroy others farm
local function DestoryOthersFarm()
	local farms = workspace:FindFirstChild("Farm")
	if not farms then
		return
	end
	for _, farm in pairs(farms:GetChildren()) do
		local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
		if (data and data:FindFirstChild("Owner") and (data.Owner.Value ~= lp.Name)) then
			local plants = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Plants_Physical")
			if plants then
				for _, obj in pairs(plants:GetChildren()) do
					obj:Destroy()
				end
			end
		end
	end
end

-- boost fps
local function BoostFpsv1()
	local decalsyeeted = true
	local g = game
	local w = g.Workspace
	local l = g.Lighting
	local t = w.Terrain
	pcall(function()
		sethiddenproperty(l, "Technology", 2)
	end)
	pcall(function()
		sethiddenproperty(t, "Decoration", false)
	end)
	pcall(function()
		t.WaterWaveSize = 0
	end)
	pcall(function()
		t.WaterWaveSpeed = 0
	end)
	pcall(function()
		t.WaterReflectance = 0
	end)
	pcall(function()
		t.WaterTransparency = 0
	end)
	pcall(function()
		l.GlobalShadows = false
	end)
	pcall(function()
		l.FogEnd = 8999999488
	end)
	pcall(function()
		l.Brightness = 0
	end)
	pcall(function()
		settings().Rendering.QualityLevel = "Level01"
	end)
	for _, v in pairs(w:GetDescendants()) do
		pcall(function()
			if (v:IsA("BasePart") and not v:IsA("MeshPart")) then
				v.Material = Enum.Material.Plastic
				v.Reflectance = 0
			elseif ((v:IsA("Decal") or v:IsA("Texture")) and decalsyeeted) then
				v.Transparency = 1
			elseif (v:IsA("ParticleEmitter") or v:IsA("Trail")) then
				v.Lifetime = NumberRange.new(0)
			elseif v:IsA("Explosion") then
				v.BlastPressure = 1
				v.BlastRadius = 1
			elseif (v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles")) then
				v.Enabled = false
			elseif (v:IsA("MeshPart") and decalsyeeted) then
				v.Material = Enum.Material.Plastic
				v.Reflectance = 0
				v.TextureID = "10385902758728957"
			elseif (v:IsA("SpecialMesh") and decalsyeeted) then
				v.TextureId = ""
			elseif (v:IsA("ShirtGraphic") and decalsyeeted) then
				v.Graphic = ""
			elseif ((v:IsA("Shirt") or v:IsA("Pants")) and decalsyeeted) then
				v[v.ClassName .. "Template"] = ""
			end
		end)
	end
	for _, e in pairs(l:GetChildren()) do
		pcall(function()
			if (e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect")) then
				e.Enabled = false
			end
		end)
	end
	w.DescendantAdded:Connect(function(v)
		task.wait()
		pcall(function()
			if (v:IsA("BasePart") and not v:IsA("MeshPart")) then
				v.Material = Enum.Material.Plastic
				v.Reflectance = 0
			elseif ((v:IsA("Decal") or v:IsA("Texture")) and decalsyeeted) then
				v.Transparency = 1
			elseif (v:IsA("ParticleEmitter") or v:IsA("Trail")) then
				v.Lifetime = NumberRange.new(0)
			elseif v:IsA("Explosion") then
				v.BlastPressure = 1
				v.BlastRadius = 1
			elseif (v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles")) then
				v.Enabled = false
			elseif (v:IsA("MeshPart") and decalsyeeted) then
				v.Material = Enum.Material.Plastic
				v.Reflectance = 0
				v.TextureID = "10385902758728957"
			elseif (v:IsA("SpecialMesh") and decalsyeeted) then
				v.TextureId = ""
			elseif (v:IsA("ShirtGraphic") and decalsyeeted) then
				v.Graphic = ""
			elseif ((v:IsA("Shirt") or v:IsA("Pants")) and decalsyeeted) then
				v[v.ClassName .. "Template"] = ""
			end
		end)
	end)
end

-- black screen
local blackScreenGui = nil
local function BlackScreen(state)
	if state then
		if not blackScreenGui then
			blackScreenGui = Instance.new("ScreenGui")
			blackScreenGui.Name = "Blackout"
			blackScreenGui.IgnoreGuiInset = true
			blackScreenGui.ResetOnSpawn = false
			blackScreenGui.DisplayOrder = 999
			pcall(function()
				blackScreenGui.Parent = Service.CoreGui
			end)
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.BackgroundColor3 = Color3.new(0, 0, 0)
			frame.BorderSizePixel = 0
			frame.ZIndex = 9999999
			frame.Parent = blackScreenGui
		end
	elseif blackScreenGui then
		blackScreenGui:Destroy()
		blackScreenGui = nil
	end
end

-- pet freeze
local function PetFreeze()
	local petsFolder = workspace:FindFirstChild("PetsPhysical")
	if petsFolder then
		for _, part in ipairs(petsFolder:GetChildren()) do
			if part:IsA("BasePart") then
				for _, maybeModel in ipairs(part:GetChildren()) do
					if maybeModel:IsA("Model") then
						local root = maybeModel:FindFirstChild("RootPart")
						if (root and root:IsA("BasePart")) then
							root.Anchored = true
						end
					end
				end
			end
		end
	end
end

-- Auto give event fruit
local AutoGiveThread

local function AutoGiveEventFruit(State)
	ToggleE.EventGiveEnabled = State
	if AutoGiveThread then
		task.cancel(AutoGiveThread)
		AutoGiveThread = nil
	end
	if ToggleE.EventGiveEnabled then
		AutoGiveThread = task.spawn(function()
			while ToggleE.EventGiveEnabled do
				local label = workspace.HoneyCombpressor.Sign.SurfaceGui.TextLabel
				if not string.find(label.Text, "KG") then
					task.wait(1)
					continue
				end
				if (backpack and char and humanoid) then
					for _, tool in pairs(backpack:GetChildren()) do
						if (tool:IsA("Tool") and string.find(tool.Name, "Pollinated")) then
							if (tool:GetAttribute("d") == true) then
								continue
							end
							humanoid:EquipTool(tool)
							task.wait(0.2)
							for i = 1, 10 do
								RemoteEvents.SubmitEvent:FireServer("MachineInteract")
							end
							task.wait(0.2)
						end
					end
				end
				task.wait(0.2)
			end
		end)
	end
end




local function FindGarden()
	local farm = workspace:FindFirstChild("Farm")
	if not farm then return nil end
	for _, plot in ipairs(farm:GetChildren()) do
		local data = plot:FindFirstChild("Important") and plot.Important:FindFirstChild("Data")
		local owner = data and data:FindFirstChild("Owner")
		if owner and owner.Value == lp.Name then
			return plot
		end
	end
	return nil
end

-- Event harvest
local EventFarmThread

local function updateEventFruits()
	local garden = FindGarden()
	if not garden then
		print("Debug: No garden found")
		return {}
	end

	local fruitsList = {}
	local plants = garden:FindFirstChild("Important") and garden.Important:FindFirstChild("Plants_Physical")
	if not plants then
		print("Debug: No Plants_Physical found in garden")
		return {}
	end

	for _, plant in pairs(plants:GetChildren()) do
		local fruits = plant:FindFirstChild("Fruits")
		if fruits then
			for _, fruit in pairs(fruits:GetChildren()) do
				if fruit:GetAttribute("Pollinated") == true then
					local isExcluded = hasExcludedMutationOrVariant(fruit)
					print("Debug: Fruit:", fruit.Name, "Pollinated:", fruit:GetAttribute("Pollinated"), "Moonlit:", fruit:GetAttribute("Moonlit"), "Excluded:", isExcluded)
					if not isExcluded then
						table.insert(fruitsList, fruit)
					end
				end
			end
		end
		if plant:GetAttribute("Pollinated") == true then
			local isExcluded = hasExcludedMutationOrVariant(plant)
			print("Debug: Plant:", plant.Name, "Pollinated:", plant:GetAttribute("Pollinated"), "Moonlit:", plant:GetAttribute("Moonlit"), "Excluded:", isExcluded)
			if not isExcluded then
				table.insert(fruitsList, plant)
			end
		end
	end

	if #fruitsList == 0 then
		print("Debug: No valid pollinated fruits/plants found after exclusion check")
	end
	return fruitsList
end

local function FireEventForFruit(fruit)
	local Event = game:GetService("ReplicatedStorage").ByteNetReliable
	print("Debug: Firing event for:", fruit.Name)
	Event:FireServer(table.unpack({
		(function(bytes)
			local b = buffer.create(#bytes)
			for i = 1, #bytes do
				buffer.writeu8(b, i - 1, bytes[i])
			end
			return b
		end)({ 1, 25, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 1, 25, 0, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50 }),
		{ fruit }
	}))
end

local function RunEventFruitFarm()
	if EventFarmThread then
		task.cancel(EventFarmThread)
	end
	EventFarmThread = task.spawn(function()
		while ToggleE.EventFarmEnabled do
			if isInventoryFull() then
				print("Debug: Inventory full, pausing")
				task.wait(0.5)
				continue
			end

			local fruitParts = updateEventFruits()
			if #fruitParts == 0 then
				task.wait(0.1)
				continue
			end

			for _, fruit in pairs(fruitParts) do
				if not ToggleE.EventFarmEnabled or isInventoryFull() then break end
				if fruit and fruit.Parent then
					FireEventForFruit(fruit)
					task.wait()
				end
			end
			task.wait(0.1)
		end
	end)
end

local function ToggleEventFarm(state)
	if EventFarmThread then
		task.cancel(EventFarmThread)
		EventFarmThread = nil
	end
	ToggleE.EventFarmEnabled = state
	if state then
		RunEventFruitFarm()
	end
end




-- Honey Collect
local function CollectHoney(State)
ToggleE.CollectHoneyEnabled = State
if ToggleE.CollectHoneyEnabled then
	task.spawn(function()
		while ToggleE.CollectHoneyEnabled do
			local label = workspace.HoneyCombpressor.Sign.SurfaceGui.TextLabel
			if label and label.Text == "READY" then
				game:GetService("ReplicatedStorage").GameEvents.HoneyMachineService_RE:FireServer("MachineInteract")
			end
			task.wait(0.1)
		end
	end)
end
end







local FV_cleanupConnections = {}
local function cleanUpPlantModel(plant)
	for _, obj in pairs(plant:GetChildren()) do
		if (obj:IsA("Part") or obj:IsA("MeshPart")) then
			obj:Destroy()
		end
	end
end
local function cleanUpPlantsInMyFarm()
	for _, conn in pairs(FV_cleanupConnections) do
		conn:Disconnect()
	end
	table.clear(FV_cleanupConnections)
	for _, farm in pairs(workspace.Farm:GetChildren()) do
		local important = farm:FindFirstChild("Important")
		local data = important and important:FindFirstChild("Data")
		if (data and data:FindFirstChild("Owner") and (data.Owner.Value == lp.Name)) then
			local plantsPhysical = important:FindFirstChild("Plants_Physical")
			if plantsPhysical then
				for _, plant in pairs(plantsPhysical:GetChildren()) do
					cleanUpPlantModel(plant)
				end
				local conn = plantsPhysical.ChildAdded:Connect(function(newPlant)
					task.wait(0.1)
					cleanUpPlantModel(newPlant)
				end)
				table.insert(FV_cleanupConnections, conn)
			end
		end
	end
end


-- ESP Configuration
local FruitVariantESP = {
	Enabled = true,
	Highlighted = {},
	Connections = {},
	ESPAllFarms = false
}

-- Color definitions for variants
local VariantColors = {
	Alienlike = Color3.fromRGB(0, 255, 127),    -- Spring Green
	Bloodlit = Color3.fromRGB(139, 0, 0),       -- Dark Red
	Burnt = Color3.fromRGB(60, 60, 60),         -- Dark Gray
	Celestial = Color3.fromRGB(47, 0, 89),      -- Dark Purple
	Chilled = Color3.fromRGB(0, 127, 255),      -- Blue
	Choc = Color3.fromRGB(59, 29, 0),           -- Dark Brown
	Cooked = Color3.fromRGB(139, 69, 19),       -- Saddle Brown
	Dawnbound = Color3.fromRGB(255, 255, 255),  -- White
	Disco = Color3.fromRGB(255, 0, 255),        -- Magenta
	Frozen = Color3.fromRGB(173, 216, 230),     -- Light Blue
	Galactic = Color3.fromRGB(50, 50, 200),     -- Deep Blue
	Heavenly = Color3.fromRGB(255, 255, 255),   -- White
	HoneyGlazed = Color3.fromRGB(255, 165, 0),  -- Orange
	Meteoric = Color3.fromRGB(255, 69, 0),      -- Red-Orange
	Molten = Color3.fromRGB(255, 140, 0),       -- Dark Orange
	Moonlit = Color3.fromRGB(177, 156, 217),    -- Light Purple
	Paradisal = Color3.fromRGB(255, 105, 180),  -- Hot Pink
	Plasma = Color3.fromRGB(255, 192, 203),     -- Pink
	Pollinated = Color3.fromRGB(255, 255, 0),   -- Yellow
	Shocked = Color3.fromRGB(255, 255, 255),    -- White
	Sundried = Color3.fromRGB(255, 99, 71),     -- Tomato
	Twisted = Color3.fromRGB(255, 85, 0),       -- Orange
	Verdant = Color3.fromRGB(34, 139, 34),      -- Forest Green
	Voidtouched = Color3.fromRGB(0, 0, 0),      -- Black
	Windstruck = Color3.fromRGB(135, 206, 235), -- Sky Blue
	Zombified = Color3.fromRGB(34, 139, 34)     -- Forest Green
}

local EnabledVariants = {}

local EnabledMutations = {"Moonlit"}

local mutationPriority = {
	"Dawnbound", "Voidtouched", "Disco", "Meteoric", "Celestial", "Galactic", "Alienlike", 
	"Shocked", "Sundried", "Zombified", "Molten", "Paradisal", "Cooked", "Frozen", "Plasma", 
	"Twisted", "HoneyGlazed", "Heavenly", "Bloodlit", "Burnt", "Verdant", "Pollinated", 
	"Chilled", "Moonlit", "Windstruck", "Choc"
}
-- ESP Functions
local function createHighlight(model, color, labelText)
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = model
	highlight.Adornee = model
	highlight.Name = "FruitESP"
	highlight.FillColor = color

	local gui = Instance.new("BillboardGui")
	gui.Name = "ESP_Label"
	gui.Size = UDim2.new(0, 100, 0, 20)
	gui.AlwaysOnTop = true
	gui.StudsOffset = Vector3.new(0, 0.5, 0)
	gui.Parent = model

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = color
	label.TextStrokeTransparency = 0
	label.TextScaled = true
	label.Font = Enum.Font.Gotham
	label.Parent = gui

	table.insert(FruitVariantESP.Highlighted, highlight)
	table.insert(FruitVariantESP.Highlighted, gui)
end

local function clearESP()
	for _, hl in pairs(FruitVariantESP.Highlighted) do
		if (hl and hl.Parent) then
			hl:Destroy()
		end
	end
	FruitVariantESP.Highlighted = {}
	
	for _, conn in pairs(FruitVariantESP.Connections) do
		conn:Disconnect()
	end
	FruitVariantESP.Connections = {}
end

local function getHighestPriorityMutation(model)
	for _, mutation in ipairs(mutationPriority) do
		if ((model:GetAttribute(mutation) == true) and table.find(EnabledMutations, mutation)) then
			return mutation
		end
	end
	return nil
end

local function processModel(model)
	if not FruitVariantESP.Enabled then
		return
	end

	local function refreshESP()
		local color, labelText
		local mutation = getHighestPriorityMutation(model)
		
		if mutation then
			color = VariantColors[mutation] or Color3.new(1, 1, 1)
			labelText = mutation
		else
			local variantVal = model:FindFirstChild("Variant")
			if (variantVal and table.find(EnabledVariants, variantVal.Value)) then
				color = VariantColors[variantVal.Value] or Color3.new(1, 1, 1)
				labelText = variantVal.Value
			end
		end

		if (color and labelText) then
			createHighlight(model, color, labelText)
		end
	end

	refreshESP()

	local attrChangedConn = model.AttributeChanged:Connect(function(attrName)
		if (table.find(mutationPriority, attrName) and table.find(EnabledMutations, attrName)) then
			clearESP()
			scanAndHighlight()
		end
	end)
	table.insert(FruitVariantESP.Connections, attrChangedConn)
end

local function connectFruitEvents(fruits)
	local fruitAddedConn = fruits.ChildAdded:Connect(function(newFruit)
		if not FruitVariantESP.Enabled then
			return
		end
		processModel(newFruit)
	end)
	table.insert(FruitVariantESP.Connections, fruitAddedConn)

	for _, fruit in pairs(fruits:GetChildren()) do
		processModel(fruit)
	end
end

local function connectPlantEvents(plants)
	local plantAddedConn = plants.ChildAdded:Connect(function(newPlant)
		if not FruitVariantESP.Enabled then
			return
		end
		local fruits = newPlant:FindFirstChild("Fruits")
		if fruits then
			connectFruitEvents(fruits)
		else
			processModel(newPlant)
		end
	end)
	table.insert(FruitVariantESP.Connections, plantAddedConn)

	for _, plant in pairs(plants:GetChildren()) do
		local fruits = plant:FindFirstChild("Fruits")
		if fruits then
			connectFruitEvents(fruits)
		else
			processModel(plant)
		end
	end
end

function scanAndHighlight()
	if not FruitVariantESP.Enabled then
		return
	end

	clearESP()
	local farms = {}

	if FruitVariantESP.ESPAllFarms then
		for _, farm in pairs(Service.ws:GetChildren()) do
			if (farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")) then
				table.insert(farms, farm)
			end
		end
	else
		local farm = Service.ws:FindFirstChild("Farm")
		if farm then
			table.insert(farms, farm)
		end
	end

	local playerName = lp.Name
	for _, farm in pairs(farms) do
		for _, plot in pairs(farm:GetChildren()) do
			local important = plot:FindFirstChild("Important")
			local data = important and important:FindFirstChild("Data")
			if (data and data:FindFirstChild("Owner") and (FruitVariantESP.ESPAllFarms or (data.Owner.Value == playerName))) then
				local plants = important:FindFirstChild("Plants_Physical")
				if plants then
					connectPlantEvents(plants)
				end
			end
		end
	end
end

-- hold all
local function HoldAllLoL()
	if (char and backpack) then
		for _, tool in pairs(backpack:GetChildren()) do
			if tool:IsA("Tool") then
				tool.Parent = char
			end
		end
	end
end

-- hold most heavy fruit
local function HoldMostHeavyFruit()
	local heaviestTool = nil
	local maxWeight = -1
	if (char and backpack) then
		for _, tool in pairs(backpack:GetChildren()) do
			if tool:IsA("Tool") then
				local weightStr = string.match(tool.Name, "(%d+%.?%d*kg)")
				if weightStr then
					local weight = tonumber(string.match(weightStr, "(%d+%.?%d*)"))
					if (weight and (weight > maxWeight)) then
						maxWeight = weight
						heaviestTool = tool
					end
				end
			end
		end
		if heaviestTool then
			heaviestTool.Parent = char
		end
	end
end

--remove frozen shells
local Fconnections = {}
local function FdeleteFrozenShell(Fpart)
	if Fpart.Name == "FrozenShell" then
		Fpart:Destroy()
	end
end
function RemoveFrozenShells(Fstate)
	ToggleE.Ftoggle = Fstate
	if ToggleE.Ftoggle then
		for _, Fconn in pairs(Fconnections) do
			Fconn:Disconnect()
		end
		Fconnections = {}
		local FfarmFolder = Service.ws:FindFirstChild("Farm")
		if not FfarmFolder then
			return
		end
		for _, Ffarm in pairs(FfarmFolder:GetChildren()) do
			local Fimportant = Ffarm:FindFirstChild("Important")
			local Fplants = Fimportant and Fimportant:FindFirstChild("Plants_Physical")
			if Fplants then
				for _, Fplant in pairs(Fplants:GetChildren()) do
					for _, Fpart in pairs(Fplant:GetDescendants()) do
						FdeleteFrozenShell(Fpart)
					end
					table.insert(Fconnections, Fplant.DescendantAdded:Connect(FdeleteFrozenShell))
				end
			end
		end
	else
		for _, Fconn in pairs(Fconnections) do
			Fconn:Disconnect()
		end
		Fconnections = {}
	end
end
Service.Players.PlayerRemoving:Connect(function(Fplayer)
	if Fplayer == lp then
		for _, Fconn in pairs(Fconnections) do
			Fconn:Disconnect()
		end
		Fconnections = {}
	end
end)



-- Auto feed pet
local function AF_getFruitTool()
	for _, tool in ipairs(lp.Backpack:GetChildren()) do
		if (tool:IsA("Tool")
			and string.find(tool.Name:lower(), AF_selectedFruit:lower())
			and not string.find(tool.Name:lower(), "seed")
			and not tool:GetAttribute("d")) then
			return tool
		end
	end
	return nil
end

local function isToolFavorited(tool)
	return tool:GetAttribute("d") or (tool:FindFirstChild("d") and tool.Favorite.Value)
end

local AF_currentTool = nil
local AF_feedingCooldown = 0.1
local AF_lastFeedTime = 0

Service.RunService.Heartbeat:Connect(function(dt)
	if not ToggleE.AF_feedingEnabled then
		return
	end

	local now = tick()
	if ((now - AF_lastFeedTime) < AF_feedingCooldown) then
		return
	end
	AF_lastFeedTime = now

	for _, pet in ipairs(AF_petsFolder:GetChildren()) do
		if (pet:GetAttribute("OWNER") == lp.Name) then
			local data = AF_petService:GetPetDataFromPetObject(pet)
			if (data and data.PetData and data.PetData.Hunger) then
				local hunger = data.PetData.Hunger
				local petType = data.PetType
				local maxHunger = (AF_petRegistry.PetList[petType] and AF_petRegistry.PetList[petType].DefaultHunger) or 1000
				local petUUID = pet:GetAttribute("UUID")
				local hungerPercent = (hunger / maxHunger) * 100

				if (hungerPercent < 80) then
					AF_feedingPets[petUUID] = true
				end

				if AF_feedingPets[petUUID] then
					if (hungerPercent >= 100) then
						AF_feedingPets[petUUID] = nil
					else
						if (not AF_currentTool or not AF_currentTool.Parent or (AF_currentTool.Parent ~= lp.Character)) then
							AF_currentTool = AF_getFruitTool()
							if AF_currentTool then
								AF_currentTool.Parent = lp.Character
							else
								AF_feedingPets = {}
								return
							end
						end
						RemoteEvents.ActivePetService:FireServer("Feed", petUUID)
						if (not AF_currentTool.Parent or (AF_currentTool.Parent ~= lp.Character)) then
							AF_currentTool = nil
						end
					end
				end
			end
		end
	end
end)






local function RSPTP()
	while true do
		local farmContainer = workspace:FindFirstChild("Farm")
		if not farmContainer then
			break
		end
		local myFarm = nil
		for _, farm in pairs(farmContainer:GetChildren()) do
			if (farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data") and farm.Important.Data:FindFirstChild("Owner") and (farm.Important.Data.Owner.Value == lp.Name)) then
				myFarm = farm
				break
			end
		end
		if not myFarm then
			break
		end
		local objectsPhysical = myFarm.Important:FindFirstChild("Objects_Physical")
		if not objectsPhysical then
			break
		end
		for _, folder in pairs(objectsPhysical:GetChildren()) do
			for _, egg in pairs(folder:GetChildren()) do
				local skipPrompt = egg:FindFirstChild("SkipPrompt")
				if skipPrompt then
					skipPrompt:Destroy()
				end
			end
		end
		wait(2)
	end
end



-- value calculation
local IC_fruitData = {
	["Carrot"] = { referenceWeight = 0.275, baseValue = 20, maxAmount = 100 },
	["Strawberry"] = { referenceWeight = 0.3, baseValue = 15, maxAmount = 100 },
	["Blueberry"] = { referenceWeight = 0.2, baseValue = 20, maxAmount = 100 },
	["Orange Tulip"] = { referenceWeight = 0.05, baseValue = 850, maxAmount = 55 },
	["Tomato"] = { referenceWeight = 0.5, baseValue = 30, maxAmount = 100 },
	["Corn"] = { referenceWeight = 2, baseValue = 40, maxAmount = 100 },
	["Daffodil"] = { referenceWeight = 0.2, baseValue = 1000, maxAmount = 45 },
	["Watermelon"] = { referenceWeight = 7, baseValue = 3000, maxAmount = 70 },
	["Pumpkin"] = { referenceWeight = 8, baseValue = 3400, maxAmount = 80 },
	["Apple"] = { referenceWeight = 3, baseValue = 275, maxAmount = 50 },
	["Bamboo"] = { referenceWeight = 4, baseValue = 4000, maxAmount = 35 },
	["Coconut"] = { referenceWeight = 14, baseValue = 400, maxAmount = 70 },
	["Cactus"] = { referenceWeight = 7, baseValue = 3400, maxAmount = 100 },
	["Dragon Fruit"] = { referenceWeight = 12, baseValue = 4750, maxAmount = 100 },
	["Mango"] = { referenceWeight = 15, baseValue = 6500, maxAmount = 200 },
	["Grape"] = { referenceWeight = 3, baseValue = 7850, maxAmount = 200 },
	["Mushroom"] = { referenceWeight = 25, baseValue = 151000, maxAmount = 220 },
	["Pepper"] = { referenceWeight = 5, baseValue = 8000, maxAmount = 200 },
	["Cacao"] = { referenceWeight = 8, baseValue = 12000, maxAmount = 250 },
	["Beanstalk"] = { referenceWeight = 10, baseValue = 28000, maxAmount = 300 },
	["Ember Lily"] = { referenceWeight = 12, baseValue = 66666, maxAmount = 450 },
	["Sugar Apple"] = { referenceWeight = 9, baseValue = 48000, maxAmount = 200 },
	["Pineapple"] = { referenceWeight = 3, baseValue = 2000, maxAmount = 70 },
	["Cauliflower"] = { referenceWeight = 5, baseValue = 40, maxAmount = 150 },
	["Green Apple"] = { referenceWeight = 3, baseValue = 300, maxAmount = 200 },
	["Banana"] = { referenceWeight = 1.5, baseValue = 2000, maxAmount = 100 },
	["Avocado"] = { referenceWeight = 6.5, baseValue = 350, maxAmount = 300 },
	["Kiwi"] = { referenceWeight = 5, baseValue = 2750, maxAmount = 300 },
	["Bell Pepper"] = { referenceWeight = 8, baseValue = 5500, maxAmount = 325 },
	["Prickly Pear"] = { referenceWeight = 7, baseValue = 7000, maxAmount = 375 },
	["Feijoa"] = { referenceWeight = 10, baseValue = 13000, maxAmount = 400 },
	["Loquat"] = { referenceWeight = 6.5, baseValue = 8000, maxAmount = 200 },
	["Wild Carrot"] = { referenceWeight = 0.3, baseValue = 25000, maxAmount = 100 },
	["Pear"] = { referenceWeight = 3, baseValue = 20000, maxAmount = 120 },
	["Cantaloupe"] = { referenceWeight = 5.5, baseValue = 34000, maxAmount = 250 },
	["Parasol Flower"] = { referenceWeight = 6, baseValue = 200000, maxAmount = 350 },
	["Rosy Delight"] = { referenceWeight = 10, baseValue = 69000, maxAmount = 450 },
	["Elephant Ears"] = { referenceWeight = 18, baseValue = 77000, maxAmount = 500 },
	["Chocolate Carrot"] = { referenceWeight = 0.275, baseValue = 11000, maxAmount = 100 },
	["Red Lollipop"] = { referenceWeight = 4, baseValue = 50000, maxAmount = 65 },
	["Blue Lollipop"] = { referenceWeight = 1, baseValue = 50000, maxAmount = 65 },
	["Candy Sunflower"] = { referenceWeight = 1.5, baseValue = 80000, maxAmount = 85 },
	["Easter Egg"] = { referenceWeight = 3, baseValue = 2500, maxAmount = 20 },
	["Candy Blossom"] = { referenceWeight = 3, baseValue = 100000, maxAmount = 40 },
	["Peach"] = { referenceWeight = 2, baseValue = 300, maxAmount = 70 },
	["Raspberry"] = { referenceWeight = 0.75, baseValue = 100, maxAmount = 70 },
	["Papaya"] = { referenceWeight = 3, baseValue = 1000, maxAmount = 60 },
	["Passionfruit"] = { referenceWeight = 3, baseValue = 3550, maxAmount = 40 },
	["Soul Fruit"] = { referenceWeight = 25, baseValue = 7750, maxAmount = 200 },
	["Cursed Fruit"] = { referenceWeight = 30, baseValue = 25750, maxAmount = 200 },
	["Mega Mushroom"] = { referenceWeight = 70, baseValue = 500, maxAmount = 2000000 },
	["Cherry Blossom"] = { referenceWeight = 3, baseValue = 500, maxAmount = 400 },
	["Purple Cabbage"] = { referenceWeight = 5, baseValue = 500, maxAmount = 70 },
	["Lemon"] = { referenceWeight = 1, baseValue = 350, maxAmount = 50 },
	["Pink Tulip"] = { referenceWeight = 0.05, baseValue = 850, maxAmount = 55 },
	["Cranberry"] = { referenceWeight = 1, baseValue = 3500, maxAmount = 50 },
	["Durian"] = { referenceWeight = 8, baseValue = 7500, maxAmount = 200 },
	["Eggplant"] = { referenceWeight = 5, baseValue = 12000, maxAmount = 220 },
	["Lotus"] = { referenceWeight = 20, baseValue = 35000, maxAmount = 650 },
	["Venus Fly Trap"] = { referenceWeight = 10, baseValue = 85000, maxAmount = 650 },
	["Nightshade"] = { referenceWeight = 0.5, baseValue = 3500, maxAmount = 100 },
	["Glowshroom"] = { referenceWeight = 0.75, baseValue = 300, maxAmount = 100 },
	["Mint"] = { referenceWeight = 1, baseValue = 5250, maxAmount = 150 },
	["Moonflower"] = { referenceWeight = 2, baseValue = 9500, maxAmount = 200 },
	["Starfruit"] = { referenceWeight = 3, baseValue = 15000, maxAmount = 250 },
	["Moonglow"] = { referenceWeight = 7, baseValue = 25000, maxAmount = 400 },
	["Moon Blossom"] = { referenceWeight = 3, baseValue = 66666, maxAmount = 400 },
	["Crimson Vine"] = { referenceWeight = 1, baseValue = 1250, maxAmount = 100 },
	["Moon Melon"] = { referenceWeight = 8, baseValue = 18000, maxAmount = 300 },
	["Blood Banana"] = { referenceWeight = 1.5, baseValue = 6000, maxAmount = 200 },
	["Celestiberry"] = { referenceWeight = 2, baseValue = 10000, maxAmount = 200 },
	["Moon Mango"] = { referenceWeight = 15, baseValue = 50000, maxAmount = 300 },
	["Rose"] = { referenceWeight = 1, baseValue = 5000, maxAmount = 100 },
	["Foxglove"] = { referenceWeight = 2, baseValue = 20000, maxAmount = 250 },
	["Lilac"] = { referenceWeight = 3, baseValue = 35000, maxAmount = 250 },
	["Pink Lily"] = { referenceWeight = 6, baseValue = 65000, maxAmount = 400 },
	["Purple Dahlia"] = { referenceWeight = 12, baseValue = 75000, maxAmount = 400 },
	["Sunflower"] = { referenceWeight = 16.5, baseValue = 160000, maxAmount = 600 },
	["Lavender"] = { referenceWeight = 0.275, baseValue = 25000, maxAmount = 90 },
	["Nectarshade"] = { referenceWeight = 0.8, baseValue = 50000, maxAmount = 100 },
	["Nectarine"] = { referenceWeight = 3, baseValue = 48000, maxAmount = 200 },
	["Hive Fruit"] = { referenceWeight = 8, baseValue = 62000, maxAmount = 300 },
	["Manuka Flower"] = { referenceWeight = 0.3, baseValue = 25000, maxAmount = 200 },
	["Dandelion"] = { referenceWeight = 4, baseValue = 50000, maxAmount = 300 },
	["Lumira"] = { referenceWeight = 6, baseValue = 85000, maxAmount = 350 },
	["Honeysuckle"] = { referenceWeight = 12, baseValue = 100000, maxAmount = 400 },
	["Crocus"] = { referenceWeight = 0.275, baseValue = 30000, maxAmount = 150 },
	["Succulent"] = { referenceWeight = 5, baseValue = 25000, maxAmount = 175 },
	["Violet Corn"] = { referenceWeight = 3, baseValue = 50000, maxAmount = 250 },
	["Bendboo"] = { referenceWeight = 18, baseValue = 155000, maxAmount = 275 },
	["Cocovine"] = { referenceWeight = 14, baseValue = 66666, maxAmount = 275 },
	["Dragon Pepper"] = { referenceWeight = 6, baseValue = 88888, maxAmount = 300 },
	["Bee Balm"] = { referenceWeight = 1, baseValue = 18000, maxAmount = 200 },
	["Nectar Thorn"] = { referenceWeight = 7, baseValue = 44444, maxAmount = 350 },
	["Suncoil"] = { referenceWeight = 10, baseValue = 80000, maxAmount = 400 },
	["Noble Flower"] = { referenceWeight = 5, baseValue = 20000, maxAmount = 250 },
	["Traveler's Fruit"] = { referenceWeight = 2, baseValue = 20000, maxAmount = 250 },
	["Ice Cream Bean"] = { referenceWeight = 4, baseValue = 4500, maxAmount = 200 },
	["Lime"] = { referenceWeight = 1, baseValue = 1000, maxAmount = 125 },
}
 
local IC_variantMultipliers = {
	Normal = 1,
	Gold = 20,
	Rainbow = 50
}
local IC_mutationMultipliers = {
    Alienlike = 100,
    Bloodlit = 4,
    Burnt = 4,
    Celestial = 120,
    Chilled = 2,
    Choc = 2,
    Cooked = 10,
    Dawnbound = 150,
    Disco = 125,
    Frozen = 10,
    Galactic = 120,
    Heavenly = 5,
    HoneyGlazed = 5,
    Meteoric = 125,
    Molten = 25,
    Moonlit = 2,
    Paradisal = 18,
    Plasma = 5,
    Pollinated = 3,
    Shocked = 100,
    Sundried = 85,
    Twisted = 5,
    Verdant = 4,
    Voidtouched = 135,
    Windstruck = 2,
    Zombified = 25
}
	

local function getFruitItems()
	local items = {}
	for _, item in pairs(char:GetChildren()) do
		if (item:IsA("Tool") and (item:GetAttribute("b") == "j") and not item:GetAttribute("d")) then
			table.insert(items, item)
		end
	end
	for _, item in pairs(backpack:GetChildren()) do
		if (item:IsA("Tool") and (item:GetAttribute("b") == "j") and not item:GetAttribute("d")) then
			table.insert(items, item)
		end
	end
	return items
end
local function calcMutationMulti(tool)
	local multi = 1
	for mutation, valueMulti in pairs(IC_mutationMultipliers) do
		if tool:GetAttribute(mutation) then
			multi = multi + (valueMulti - 1)
		end
	end
	return math.max(1, multi)
end
local function calculateFruitValue(tool)
	if not tool then
		return 0
	end
	local itemString = tool:FindFirstChild("Item_String")
	local variant = tool:FindFirstChild("Variant")
	local weight = tool:FindFirstChild("Weight")
	if not itemString or not variant or not weight then
		return 0
	end
	local itemData = IC_fruitData[itemString.Value]
	if not itemData then
		return 0
	end
	local baseValue = itemData.baseValue
	local referenceWeight = itemData.referenceWeight
	local variantMulti = IC_variantMultipliers[variant.Value] or 0
	if variantMulti == 0 then
		return 0
	end
	local mutationMulti = calcMutationMulti(tool)
	local weightRatio = weight.Value / referenceWeight
	weightRatio = math.clamp(weightRatio, 0.95, 100000000)
	local value = baseValue * mutationMulti * variantMulti * weightRatio * weightRatio
	return math.round(value)
end
local function getHoldingFruitValue()
	local tool = char:FindFirstChildOfClass("Tool")
	if not tool then
		return 0
	end
	return calculateFruitValue(tool)
end

local function calculateTotalFruitValue()
	local totalValue = 0
	local fruits = getFruitItems()
	for _, fruit in pairs(fruits) do
		local val = calculateFruitValue(fruit)
		if (typeof(val) ~= "number") then
			val = 0
		end
		totalValue = totalValue + val
	end
	return totalValue
end


-- hold most valuable fruit
local function HoldMostValuableFruit()
	local mostValuableTool = nil
	local maxValue = -1
	if (char and backpack) then
		for _, tool in pairs(backpack:GetChildren()) do
			if tool and tool:IsA("Tool") and tool:GetAttribute("b") == "j" then
				local value = calculateFruitValue(tool)
				if value and type(value) == "number" and value > maxValue then
					maxValue = value
					mostValuableTool = tool
				end
			end
		end
		if mostValuableTool then
			-- Unequip currently equipped tool if any
			for _, equippedTool in pairs(char:GetChildren()) do
				if equippedTool:IsA("Tool") then
					equippedTool.Parent = backpack
				end
			end
			-- Equip the new tool
			mostValuableTool.Parent = char
		end
	end
end



local function EggPetShower()
	loadstring(game:HttpGet('https://raw.githubusercontent.com/H4xScripts/Scripts/refs/heads/main/autofidner', true))()
end




local function Feedback()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/H4xScripts/Loader/refs/heads/main/feedback.lua", true))()
end



--ui
MainTab:CreateDropdown("ExcludeMutations", {
    Title = "Exclude Mutations",
    Values = mutationOptions,
    Multi = true,
    Default = {},
	Callback = function(Value) 
		excludedMutations = Value
		if ToggleE.autoFarmEnabled then
			updateFarmData()
		end
	end
})
MainTab:CreateDropdown("ExcludeVariants", {
	Title = "Exclude Variants",
	Values = {"Gold", "Rainbow",},
	Value = {},
	Multi = true,
	Callback = function(Value) 
	    excludedVariants = Value
	    if ToggleE.autoFarmEnabled then
		    updateFarmData()
	    end
	end
})
MainTab:CreateDropdown("ExcludeFruits", {
	Title = "Exclude Fruits",
	Values = fruitNames,
	Value = {},
	Multi = true,
	AllowNone = true,
	Callback = function(Value) 
	    excludeFruits = Value
	    if ToggleE.autoFarmEnabled then
	    	updateFarmData()
	    end
	end
})
MainTab:CreateInput("Input", {
    Title = "Input",
    Default = "Default",
    Placeholder = "Placeholder",
    Numeric = true, 
    Finished = false, 
    Callback = function(input)
        local numeric = tostring(input):match("%d+%.?%d*")
        if numeric then
            excludeWeight = tonumber(numeric)
        else
            excludeWeight = nil
        end
    end
})
MainTab:AddSection("AutoFarm")
MainTab:AddToggle("AutoFarm",{
	Title = "Auto Farm",
	Default = false,
	Callback = function(state)
		ToggleE.autoFarmEnabled = state
		if ToggleE.autoFarmEnabled then
			instantFarm()
		elseif farmThread then
			task.cancel(farmThread)
			farmThread = nil
		end
	end
})
MainTab:AddToggle("AutoCollect",{
	Title = "Auto Collect",
	Default = false,
	Callback = function(state)
		ToggleE.fastClickEnabled = state
		if ToggleE.fastClickEnabled then
			fastClickFarm()
		elseif fastClickThread then
			task.cancel(fastClickThread)
			fastClickThread = nil
		end
	end
})

MainTab:AddSection("AutoSell")
MainTab:AddToggle({
	Title = "Auto Sell",
	Default = false,
	Callback = function(Value)
		ToggleE.autoSellEnabled = Value
		if ToggleE.autoSellEnabled then
			if autoSellThread then
				task.cancel(autoSellThread)
			end
			autoSellThread = task.spawn(function()
				while ToggleE.autoSellEnabled and task.wait(0.1) do
					if isInventoryFull() then
						sellItems()
					end
				end
			end)
		elseif autoSellThread then
			task.cancel(autoSellThread)
			autoSellThread = nil
		end
	end
})
MainTab:AddButton({
	Title = "Sell All",
	Callback = SellAll
})
MainTab:AddButton({
	Title = "Sell Hand",
	Callback = HSell
})

MainTab:AddButton({
	Title = "Sell All",
	Callback = SellAll
})


MainTab:AddSection("Others")
MainTab:AddButton({
	Title = "Anti-Afk",
	Callback = AntiAfk
})

MainTab:AddToggle("OCPR",{
	Title = "One Click Plant Remove",
	Default = false,
	Callback = OneClickRemove
})


MainTab:AddSection("Gamespass Pop-Ups")
MainTab:AddButton({
	Title  = "Stops Grow-ALL pop-up",
	Callback = DestroySign
}, "SGP")

MainTab:AddButton({
	Title  = "Remove Skip pet timer pop up",
	Callback = RSPTP
})


SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes{}
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(SettingTab)
SaveManager:BuildConfigSection(SettingTab)

Window:SelectTab(1)

Library:Notify{
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
}

SaveManager:LoadAutoloadConfig()

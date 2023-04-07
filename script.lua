--BROUGHT TO YOU BY ROBLOXSCRIPTS.NET!--

-- Constants

local REMOVE_BANANA_PEELS = true

local REMOVE_JEFFTHEKILLER_HITBOX = true -- makes jeff unable to deal damage

local REMOVE_GREED_RISK = true -- makes you unable to collect gold when you risk taking damage from greed

local REMOVE_AMBIENCE_SOUNDS = true -- not that necessary but if you want to hear better keep it

local REMOVE_EYES_DAMAGE = true -- makes eyes deal no damage

local REMOVE_SCREECH = true

local REMOVE_LIGHT_SHATTER = true -- makes lights not shatter from any entity moving (screech will still appear unless removed)

-- creates a guiding light so you know where to go

local MARK_NEXT_DOOR = true

local MARK_GATE_LEVER = true

local MARK_HINT_BOOKS = true

local SPEED_BOOST_ENABLED = true

local BOOST_EXTRA_WALKSPEED = 6 -- above makes you teleport back by anticheat

local CREATE_ENTITY_HINTS = true -- watch your topbar for hints when entities spawn

--- don't touch below (you can however change light properties, color is (red, green, blue) up to 255)

-- Services

local PlayersService = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Vars

local CurrentRooms = workspace:WaitForChild("CurrentRooms")

local LocalPlayer = PlayersService.LocalPlayer

--

local Hint

local function HandleModels(model)

task.wait(0.1)

local modelIdentifier = model.Name

if modelIdentifier == "BananaPeel" and REMOVE_BANANA_PEELS then

model:Destroy()

elseif modelIdentifier == "JeffTheKiller" and REMOVE_JEFFTHEKILLER_HITBOX then

local knife = model:WaitForChild("Knife", 10)

if not knife then

return

end

for _, descendant in ipairs(model:GetDescendants()) do

if descendant:IsA("BasePart") then

descendant.CanTouch = false

descendant.CanQuery = false

end

end

elseif (modelIdentifier == "RushMoving" or modelIdentifier == "AmbushMoving") and CREATE_ENTITY_HINTS then

if Hint then

return

end

task.wait(0.15)

local primaryPart = model.PrimaryPart

if not primaryPart or primaryPart.Position.Y < -100 then -- don't watch fake ones

return

end

local entityIdentifier = primaryPart.Name

local resultName = entityIdentifier == "RushNew" and string.gsub(model.Name, "Moving", "") or entityIdentifier

Hint = Instance.new("Hint")

Hint.Text = resultName.. " is coming! hide!!!"

Hint.Parent = workspace

-- yield until the entity is destroyed completely

model:GetPropertyChangedSignal("Parent"):Wait()

Hint:Destroy()

Hint = nil

end

end

local function HandleRooms(room)

task.wait(2)

local nextRoomId = tonumber(room.Name) + 1

for _, descendant in ipairs(room:GetDescendants()) do

local guidingLight = Instance.new("PointLight")

if MARK_GATE_LEVER and descendant.Name == "LeverForGate" then

guidingLight.Range = 60

guidingLight.Color = Color3.fromRGB(0, 255, 255)

guidingLight.Shadows = true

guidingLight.Parent = descendant:WaitForChild("Main", 5)

elseif MARK_HINT_BOOKS and descendant.Name == "LiveHintBook" then

guidingLight.Range = 20

guidingLight.Color = Color3.fromRGB(255, 0, 255)

guidingLight.Shadows = false

guidingLight.Parent = descendant:WaitForChild("Base", 5)

elseif MARK_NEXT_DOOR and descendant:GetAttribute("RoomID") == nextRoomId then

guidingLight.Range = 40

guidingLight.Color = Color3.fromRGB(255, 255, 255)

guidingLight.Shadows = false

guidingLight.Parent = descendant:WaitForChild("Door", 5)

end

end

end

local function HandleLoot(prompt)

if not REMOVE_GREED_RISK then

return

end

if prompt.Name ~= "LootPrompt" or prompt.ActionText ~= "Collect" then

return

end

-- if this isn't done script won't be able to use holdbegan signal to prevent collecting

prompt.HoldDuration = 0.025

local holdBeganConnection

local ancestryChangedConnection

holdBeganConnection = prompt.PromptButtonHoldBegan:Connect(function(playerWhoTriggered)

if LocalPlayer ~= playerWhoTriggered or LocalPlayer:GetAttribute("Greed") ~= 6 or prompt.HoldDuration == 999999 then

return

end

prompt.HoldDuration = 999999

-- yield until greed level changes

LocalPlayer:GetAttributeChangedSignal("Greed"):Wait()

prompt.HoldDuration = 0.025

end)

ancestryChangedConnection = game.AncestryChanged:Connect(function()

if prompt:IsDescendantOf(CurrentRooms) then

return

end

-- prompt was removed from workspace; these connections will only take memory

holdBeganConnection:Disconnect()

ancestryChangedConnection:Disconnect()

holdBeganConnection = nil

ancestryChangedConnection = nil

end)

end

local function HandleEntities()

local entitiesFolder = ReplicatedStorage:WaitForChild("Entities", 5)

if not entitiesFolder then

return

end

if REMOVE_SCREECH then

local screechModel = entitiesFolder:WaitForChild("Screech", 5)

if not screechModel then

return

end

screechModel:Destroy()

end

end

local function HandleAmbience()

if not REMOVE_AMBIENCE_SOUNDS then

return

end

local ambience_dark = workspace:WaitForChild("Ambience_Dark", 5)

if ambience_dark then

ambience_dark.Volume = 0

end

local ambienceFolder = workspace:WaitForChild("Ambience", 5)

if not ambienceFolder then

return

end

for _, descendant in ipairs(ambienceFolder:GetDescendants()) do

if descendant.ClassName == "Sound" then

descendant.Volume = 0

end

end

end

local function HandleSpeedBoost()

if not SPEED_BOOST_ENABLED then

return

end

local function handleCharacter(character)

local humanoid = character:WaitForChild("Humanoid")

local updating = false

local function updateSpeedBoost()

if updating then

return

end

-- basic debounce

updating = true

humanoid:SetAttribute("SpeedBoostBehind", BOOST_EXTRA_WALKSPEED)

updating = false

end

humanoid:GetAttributeChangedSignal("SpeedBoostBehind"):Connect(updateSpeedBoost)

updateSpeedBoost()

end

-- on revive

LocalPlayer.CharacterAdded:Connect(handleCharacter)

handleCharacter(LocalPlayer.Character)

end

local function HandleGameEvents()

local function isValid(func)

return type(func) == "function" and islclosure(func) and not is_synapse_function(func)

end

local gc = getgc()

for _, value in pairs(gc) do

if REMOVE_LIGHT_SHATTER then

if isValid(value) then

local info = debug.getinfo(value)

if info.currentline == 14 and string.find(info.short_src, "Module_Events") then

local functionEnvironment = getfenv(value)

-- remove luau optimizations (thats necessary)

setuntouched(functionEnvironment, false)

-- overwrite spawn

functionEnvironment.spawn = function()end

break

end

end

end

end

end

local function HandleRemotes()

local entityInfo = ReplicatedStorage:WaitForChild("EntityInfo", 5)

if not entityInfo then

return

end

if REMOVE_EYES_DAMAGE then

local motorReplicationEvent = entityInfo:WaitForChild("MotorReplication", 5)

if not motorReplicationEvent then

return

end

local findFirstChild = game.FindFirstChild

local originalNC

originalNC = hookmetamethod(game, "__namecall", function(self, ...)

if self and rawequal(self, motorReplicationEvent) then

if findFirstChild(workspace, "Eyes") then

local function filter(x, y, ...) -- x, y, z, crouching

return x, -89 - math.random(), ...

end

return originalNC(self, filter(...))

end

end

return originalNC(self, ...)

end, true)

end

end

local function SetUp()

workspace.ChildAdded:Connect(HandleModels)

for _, child in ipairs(workspace:GetChildren()) do

task.spawn(HandleModels, child)

end

--

CurrentRooms.ChildAdded:Connect(HandleRooms)

--

game.DescendantAdded:Connect(HandleLoot)

for _, descendant in ipairs(game:GetDescendants()) do

task.spawn(HandleLoot, descendant)

end

--

task.spawn(HandleEntities)

task.spawn(HandleAmbience)

task.spawn(HandleSpeedBoost)

task.spawn(HandleGameEvents)

task.spawn(HandleRemotes)

end

SetUp()

-- NicoThing.luau (should run once)
local Players = cloneref(game:GetService("Players"))
local TweenService = cloneref(game:GetService("TweenService"))
local SoundService = cloneref(game:GetService("SoundService"))

local DialogueService = {}

local gui = Instance.new("ScreenGui")
gui.Name = "TypewriterGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Name = "TypeLabel"
label.Size = UDim2.new(0.5, 0, 0.1, 0)
label.Position = UDim2.new(0.25, 0, 0.4, 0)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.TextColor3 = Color3.new(1, 1, 1)
label.BackgroundTransparency = 1
label.TextTransparency = 1
label.Text = ""
label.Parent = gui

-- SoundMap preload...
local charset = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
local Repo = "https://raw.githubusercontent.com/Hor1zon-Projects/Voyager/refs/heads/main"
local FileManager = loadstring(game:HttpGet(Repo.."/modules/FileManager.luau"))()
local soundBaseUrl = Repo.."/assets/NX-Assets/sounds/"
local SoundMap = {}

for _, char in ipairs(charset) do -- This usually takes 5-10 seconds when running the script for the first time.
	local safe = char == " " and "Space" or char
	local key = char == " " and "`" or char
	local sound = Instance.new("Sound")
	sound.Name = key
	sound.SoundId = FileManager:SetFile("Dialogue_"..safe,soundBaseUrl..safe..".mp3",".mp3")
	sound.Volume = 1
	sound.Parent = SoundService
	SoundMap[key] = sound
end

-- Animal Crossing recreation thingyy
local Speed = 0.02
local PauseChars = {
	["."] = 0.15,
	["!"] = 0.16,
	["?"] = 0.17,
	[","] = 0.1
}

local function PlayCharSound(char, i)
	local sound = SoundMap[char]
	if not sound then return end
	local s = sound:Clone()
	s.Volume = 0
	s.Pitch = math.clamp(0.75 / Speed, 0.8, 2.0)
	s.PlaybackSpeed = math.clamp(math.random(975, 1025) / 1000 + 0.0002 * i, 0.8, 2.0)
	s.Parent = SoundService
	s:Play()
	TweenService:Create(s, TweenInfo.new(0.032), { Volume = 0.5 }):Play()
	task.delay(0.032, function()
		TweenService:Create(s, TweenInfo.new(0.05), { Volume = 0 }):Play()
	end)
	task.delay(0.08, function()
		s:Stop()
		s:Destroy()
	end)
end

-- Typewriter function (took me a while)
function DialogueService.Type(text, onFinished)
	label:SetAttribute("IsTypewriting", true)
	label.Text = text
	label.TextTransparency = 1
	label.MaxVisibleGraphemes = 0
	TweenService:Create(label, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()

	for i = 1, #text do
		label.MaxVisibleGraphemes = i
		local char = text:sub(i,i)
		PlayCharSound(char, i)
		task.wait(PauseChars[char] or Speed)
	end

	label.MaxVisibleGraphemes = -1
	label:SetAttribute("IsTypewriting", false)
	if onFinished then onFinished() end
end

_G.DialogueService = DialogueService

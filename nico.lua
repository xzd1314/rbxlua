if not game:IsLoaded() then game.Loaded:Wait() end

pcall(function()
    if game.CoreGui:FindFirstChild("GermanizedNicos") then game.CoreGui.GermanizedNicos:Destroy() end
    if game.Players.LocalPlayer.PlayerGui:FindFirstChild("GermanizedNicos") then game.Players.LocalPlayer.PlayerGui:FindFirstChild("GermanizedNicos"):Destroy() end
end)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Connections = {}
local original_properties = { walkspeed = 16 }

local function get_character_humanoid()
    local char = LocalPlayer.Character
    return char, char and char:FindFirstChildOfClass("Humanoid")
end

local function update_original_properties()
    local _, humanoid = get_character_humanoid()
    original_properties.walkspeed = humanoid and humanoid.WalkSpeed or 16
end
update_original_properties()

local Window = Fluent:CreateWindow({
    Title = "Germanized's NicoNXBTS Script (V9)| 汉化版",
    SubTitle = "",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 520),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})
Window.Name = "GermanizedNicos"

local Tabs = {
    Main = Window:AddTab({ Title = "功能", Icon = "gamepad" }),
    Settings = Window:AddTab({ Title = "设置", Icon = "settings" })
}
local Options = Fluent.Options

local bots_folder = Workspace:FindFirstChild("bots")
if not bots_folder then
    Tabs.Main:AddParagraph({
        Title = "提示",
        Content = "该脚本仅限于nico的下一个机器人使用。"
    })
else
    Tabs.Main:AddToggle("EnableBotESP", {Title = "启用 Bot 透视", Default = false}):OnChanged(function(enabled)
        if not Workspace:FindFirstChild("bots") then
            return Fluent:Notify({Title = "错误", Content = "未在工作区找到 bots 文件夹！"})
        end
        local function set_esp(bot, state)
            if bot and bot:FindFirstChild("HumanoidRootPart") and bot.HumanoidRootPart:FindFirstChild("icon") then
                bot.HumanoidRootPart.icon.AlwaysOnTop = state
            end
        end
        for _, bot in pairs(Workspace.bots:GetChildren()) do
            if bot:IsA("Model") then set_esp(bot, enabled) end
        end
        if Connections.BotAdded then Connections.BotAdded:Disconnect() end
        if enabled then
            Connections.BotAdded = Workspace.bots.ChildAdded:Connect(function(bot)
                if bot:IsA("Model") and Options.EnableBotESP.Value then
                    task.wait(0.1)
                    set_esp(bot, true)
                end
            end)
        else
            Connections.BotAdded = Workspace.bots.ChildAdded:Connect(function(bot)
                if bot:IsA("Model") then
                    task.wait(0.1)
                    set_esp(bot, false)
                end
            end)
        end
    end)

    Tabs.Main:AddToggle("ThirdPerson", {Title = "开启第三人称", Default = false})
    Tabs.Main:AddParagraph({Title = "重要提示：", Content = "第三人称原生实现已移除，开启仅作为标记！"})

    local speed_slider = Tabs.Main:AddSlider("SpeedChanger", {
        Title = "行走速度",
        Default = original_properties.walkspeed,
        Min = 16,
        Max = 200,
        Rounding = 0
    })
    Tabs.Main:AddButton({Title = "重置移速", Callback = function() speed_slider:SetValue(original_properties.walkspeed) end})
    Tabs.Main:AddToggle("Airstrafe", {Title = "空中左右急转", Default = false, Tooltip = "空中按下 A/D 实现横向漂移"})

    Tabs.Main:AddToggle("Spinbot", {Title = "自旋视角（反瞄准）", Default = false})
    Tabs.Main:AddDropdown("SpinbotPitch", {
        Title = "自旋俯仰角度",
        Values = {"向下", "向上", "正前方"},
        Default = "向下",
        Multi = false
    })

    Tabs.Main:AddToggle("AutoWCSpace", {
        Title = "自动嘲讽跳",
        Default = false,
        Tooltip = "快捷键 F8，开启后强制速度=100，连点=30，重力=200，关闭时恢复"
    })

    local tap_speed_slider = Tabs.Main:AddSlider("TapSpeed", {
        Title = "连点速度 (次/秒)",
        Default = 30,
        Min = 1,
        Max = 100,
        Rounding = 0
    })

    local currentGravity = Workspace.Gravity or 196.2
    local gravity_slider = Tabs.Main:AddSlider("GravitySlider", {
        Title = "重力 [锁定]",
        Default = currentGravity,
        Min = 0,
        Max = 300,
        Rounding = 1
    })

    local default_walkspeed = original_properties.walkspeed
    local default_tap_speed = 30
    local default_gravity = currentGravity

    Tabs.Main:AddButton({Title = "重置数值", Callback = function()
        speed_slider:SetValue(default_walkspeed)
        tap_speed_slider:SetValue(default_tap_speed)
        gravity_slider:SetValue(default_gravity)
    end})

    Tabs.Main:AddToggle("DanceMove", {
        Title = "边跳舞边移动",
        Default = false,
        Tooltip = "快捷键 F7，开启后速度=100，重力=默认，长按 W+C+空格，关闭时恢复"
    })

    Tabs.Main:AddParagraph({Title = "注意", Content = "自旋会操作相机，如果再次出现模糊请关闭自旋测试！"})
    Tabs.Main:AddParagraph({
        Title = "使用方法",
        Content = "先开启 Bot 透视观察 Bot 位置。按 F8 启动自动嘲讽跳（强制速度100、连点30、重力200，关闭自动恢复原值）；按 F7 启动边跳舞边移动（强制速度100、重力默认，长按W+C+空格）。两者互斥，开启一个会自动关闭另一个。"
    })

    local autoActive = false
    local tapLoopTask = nil
    local f8_saved_speed = 16
    local f8_saved_tap = 30
    local f8_saved_gravity = 196.2

    local danceActive = false
    local danceLoopTask = nil
    local dance_saved_speed = 16
    local dance_saved_gravity = 196.2

    local function stopDance()
        if danceLoopTask then
            task.cancel(danceLoopTask)
            danceLoopTask = nil
        end
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, nil)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, nil)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
        danceActive = false
        Options.DanceMove:SetValue(false)
        speed_slider:SetValue(dance_saved_speed)
        gravity_slider:SetValue(dance_saved_gravity)
    end

    local function startDance()
        dance_saved_speed = Options.SpeedChanger.Value
        dance_saved_gravity = Options.GravitySlider.Value
        speed_slider:SetValue(100)
        gravity_slider:SetValue(default_gravity)
        danceActive = true
        Options.DanceMove:SetValue(true)
        danceLoopTask = task.spawn(function()
            while danceActive do
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, nil)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, nil)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, nil)
                task.wait(0.02)
            end
        end)
    end

    local function stopAuto()
        if tapLoopTask then
            task.cancel(tapLoopTask)
            tapLoopTask = nil
        end
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, nil)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, nil)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
        autoActive = false
        Options.AutoWCSpace:SetValue(false)
        speed_slider:SetValue(f8_saved_speed)
        tap_speed_slider:SetValue(f8_saved_tap)
        gravity_slider:SetValue(f8_saved_gravity)
    end

    local function startAuto()
        f8_saved_speed = Options.SpeedChanger.Value
        f8_saved_tap = Options.TapSpeed.Value
        f8_saved_gravity = Options.GravitySlider.Value
        speed_slider:SetValue(100)
        tap_speed_slider:SetValue(30)
        gravity_slider:SetValue(200)
        autoActive = true
        Options.AutoWCSpace:SetValue(true)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, nil)
        tapLoopTask = task.spawn(function()
            while autoActive do
                local speed = Options.TapSpeed.Value
                local interval = speed > 0 and (1 / speed) or 0.1
                local holdTime = math.min(0.01, interval * 0.5)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, nil)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, nil)
                task.wait(holdTime)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, nil)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
                local remain = interval - holdTime
                if remain > 0 then task.wait(remain) end
            end
        end)
    end

    local function setAutoState(state)
        if autoActive == state then return end
        if state and danceActive then
            stopDance()
        end
        if state then
            startAuto()
        else
            stopAuto()
        end
    end

    local function setDanceState(state)
        if danceActive == state then return end
        if state and autoActive then
            stopAuto()
        end
        if state then
            startDance()
        else
            stopDance()
        end
    end

    Options.AutoWCSpace:OnChanged(setAutoState)
    Options.DanceMove:OnChanged(setDanceState)

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.F8 and input.UserInputType == Enum.UserInputType.Keyboard then
            setAutoState(not autoActive)
        elseif input.KeyCode == Enum.KeyCode.F7 and input.UserInputType == Enum.UserInputType.Keyboard then
            setDanceState(not danceActive)
        end
    end)

    RunService:BindToRenderStep("LockGravity", Enum.RenderPriority.Camera.Value + 10, function()
        pcall(function()
            local grav = Options.GravitySlider.Value
            if Workspace.Gravity ~= grav then
                Workspace.Gravity = grav
            end
        end)
    end)

    LocalPlayer.CharacterAdded:Connect(function(char)
        update_original_properties()
        if danceActive then
            stopDance()
            task.wait(0.1)
            startDance()
        end
    end)

    local spin_angle, spin_speed = 0, 45
    RunService:BindToRenderStep("GermanizedLoop", Enum.RenderPriority.Camera.Value + 1, function(dt)
        pcall(function()
            local char, humanoid = get_character_humanoid()
            if not humanoid or humanoid.Health <= 0 then return end

            humanoid.WalkSpeed = Options.SpeedChanger.Value

            if Options.Spinbot.Value then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    humanoid.AutoRotate = false
                    local cam_cframe = Camera.CFrame
                    spin_angle = (spin_angle + dt * spin_speed) % (math.pi * 2)
                    local pitch = 0
                    if Options.SpinbotPitch.Value == "向下" then
                        pitch = math.rad(90)
                    elseif Options.SpinbotPitch.Value == "向上" then
                        pitch = math.rad(-90)
                    end
                    root.CFrame = CFrame.new(root.Position) * CFrame.fromOrientation(0, spin_angle, pitch)
                    if not Options.ThirdPerson.Value then Camera.CFrame = cam_cframe end
                end
            else
                if not humanoid.AutoRotate then humanoid.AutoRotate = true end
            end

            if Options.Airstrafe.Value and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                local root = char.HumanoidRootPart
                if root then
                    local strafe_vector = Vector3.new()
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then strafe_vector += Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then strafe_vector -= Camera.CFrame.RightVector end
                    if strafe_vector.Magnitude > 0 then
                        root.Velocity += Vector3.new(strafe_vector.X, 0, strafe_vector.Z).Unit * 120 * dt
                    end
                end
            end

            for _, obj in ipairs(Lighting:GetChildren()) do
                if obj:IsA("DepthOfFieldEffect") then obj.Enabled = false end
            end
            for _, obj in ipairs(Camera:GetChildren()) do
                if obj:IsA("DepthOfFieldEffect") then obj.Enabled = false end
            end
        end)
    end)
end

Tabs.Settings:AddParagraph({Title = "制作信息", Content = "原作者：Germanized"})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:SetFolder("NicosScript/Final_v9")
InterfaceManager:SetFolder("NicosScript/Final_v9")
SaveManager:IgnoreThemeSettings()
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({Title = "Germanized's NicoNXBTS Script", Content = "脚本加载完成", Duration = 5})
pcall(SaveManager.LoadAutoloadConfig, SaveManager)
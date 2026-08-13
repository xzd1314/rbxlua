local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "踢出工具 | xzd1314",
    SubTitle = "输入原因踢出玩家",
    TabWidth = 160,
    Size = UDim2.fromOffset(420, 280),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "踢出", Icon = "log-out" })
}

local Options = Fluent.Options

local reasonInput = Tabs.Main:AddInput("KickReason", {
    Title = "踢出原因",
    Default = "输入原因...",
    Placeholder = "输入原因...",
    Numeric = false,
    Finished = false,
})

Tabs.Main:AddButton({
    Title = "确定踢出",
    Callback = function()
        local reason = Options.KickReason.Value
        if reason == "" or reason == "输入原因..." then
            reason = "未提供原因"
        end
        Window:Destroy()
        task.wait(0.1)
        localPlayer:Kick(reason)
    end
})

Tabs.Main:AddParagraph({
    Title = "提示",
    Content = "输入踢出原因后点击按钮或按回车键提交。"
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:SetFolder("KickTool_xzd1314")
InterfaceManager:SetFolder("KickTool_xzd1314")
SaveManager:IgnoreThemeSettings()
InterfaceManager:BuildInterfaceSection(Tabs.Main)
SaveManager:BuildConfigSection(Tabs.Main)

Window:SelectTab(1)
Fluent:Notify({
    Title = "踢出工具",
    Content = "已加载，输入原因后踢出玩家。",
    Duration = 3
})

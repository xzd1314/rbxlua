-- 获取本地玩家
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- ========== 创建最高层级的 ScreenGui ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui
screenGui.Name = "KickDialog"
screenGui.DisplayOrder = 999              -- 确保在最上层
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global  -- 全局层级

-- ========== 主框架（响应式尺寸） ==========
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.8, 0, 0.45, 0)   -- 宽80%屏幕，高45%屏幕
frame.Position = UDim2.new(0.5, -0.4, 0.5, -0.225) -- 居中（利用Scale）
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- ========== 标题 ==========
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.18, 0)     -- 高度占Frame的18%
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "输入踢出原因"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 20                       -- 固定字号，也可用TextScaled
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- ========== 多行输入框 ==========
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0.9, 0, 0.5, 0)  -- 宽度90%，高度50%
textBox.Position = UDim2.new(0.05, 0, 0.22, 0)
textBox.BackgroundColor3 = Color3.new(1, 1, 1)
textBox.TextColor3 = Color3.new(0, 0, 0)
textBox.Text = "输入原因..."
textBox.TextSize = 16
textBox.MultiLine = true
textBox.ClearTextOnFocus = false
textBox.Parent = frame
-- 移动端触控优化
textBox.AutomaticSize = Enum.AutomaticSize.None

-- ========== 确定按钮 ==========
local button = Instance.new("TextButton")
button.Size = UDim2.new(0.4, 0, 0.18, 0)  -- 宽度40%，高度18%
button.Position = UDim2.new(0.3, 0, 0.78, 0) -- 居中偏下
button.Text = "确定"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 18
button.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
button.Parent = frame
-- 移动端触控热区加大（实际点击区域已由Size决定）

-- ========== 按钮点击处理 ==========
button.MouseButton1Click:Connect(function()
	local reason = textBox.Text
	if reason == "" or reason == "输入原因..." then
		reason = "未提供原因"
	end

	-- 先销毁窗口，再踢出（保证窗口消失）
	screenGui:Destroy()
	localPlayer:Kick(reason)
end)

-- ========== 回车键提交（PC端快捷操作） ==========
textBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		button:Fire()   -- 触发点击事件
	end
end)

-- ========== 额外：点击空白区域关闭键盘（移动端） ==========
-- 点击框架其他区域让输入框失去焦点，收起虚拟键盘
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		textBox:ReleaseFocus()
	end
end)
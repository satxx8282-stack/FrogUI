-- ═══════════════════════════════════════════════════════════════════════
--    ███████╗██████╗  ██████╗  ██████╗     UI  •  MODERN EDITION
--    ██╔════╝██╔══██╗██╔═══██╗██╔════╝     Clean • Smooth • Animated
--    █████╗  ██████╔╝██║   ██║██║  ███╗    Floating Button + Custom Logo
--    ██╔══╝  ██╔══██╗██║   ██║██║   ██║    API Kompatibel dengan Kavo Lama
--    ██║     ██║  ██║╚██████╔╝╚██████╔╝
--    ╚═╝     ╚═╝  ╚═╝ ╚═════╝  ╚═════╝
-- ═══════════════════════════════════════════════════════════════════════

local Frog = {}

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════════════════════════════
--  UTILITIES
-- ═══════════════════════════════════════════════════════════════════════
local U = {}

function U.tween(obj, dur, props, style, dir)
	local t = TweenService:Create(
		obj,
		TweenInfo.new(dur or 0.25, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
		props
	)
	t:Play()
	return t
end

function U.new(class, props, parent)
	local i = Instance.new(class)
	for k, v in pairs(props or {}) do i[k] = v end
	if parent then i.Parent = parent end
	return i
end

function U.corner(parent, r) return U.new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, parent) end

function U.stroke(parent, color, thick, trans)
	return U.new("UIStroke", {
		Color = color or Color3.fromRGB(255,255,255),
		Thickness = thick or 1,
		Transparency = trans or 0.85,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)
end

function U.gradient(parent, c1, c2, rot)
	return U.new("UIGradient", { Color = ColorSequence.new(c1, c2), Rotation = rot or 0 }, parent)
end

function U.padding(parent, all)
	return U.new("UIPadding", {
		PaddingTop = UDim.new(0, all), PaddingBottom = UDim.new(0, all),
		PaddingLeft = UDim.new(0, all), PaddingRight = UDim.new(0, all),
	}, parent)
end

function U.drag(frame, parent)
	parent = parent or frame
	local dragging, dragInput, startPos, startFrame
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging   = true
			startPos   = input.Position
			startFrame = parent.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - startPos
			parent.Position = UDim2.new(
				startFrame.X.Scale, startFrame.X.Offset + delta.X,
				startFrame.Y.Scale, startFrame.Y.Offset + delta.Y
			)
		end
	end)
end

-- ═══════════════════════════════════════════════════════════════════════
--  🎨 LOGO BUILDER  ── 4 mode: Frog | Image | Text | None
-- ═══════════════════════════════════════════════════════════════════════
--  Config format:
--    { Type = "Frog" }                                    (default)
--    { Type = "Image", Image = "rbxassetid://123456789" }
--    { Type = "Text",  Text = "🐸", TextSize = 18,
--      TextColor = Color3.fromRGB(255,255,255) }
--    { Type = "None" }
-- ═══════════════════════════════════════════════════════════════════════
local function normalizeLogo(cfg)
	cfg = cfg or {}
	cfg.Type = cfg.Type or "Frog"
	if cfg.Type == "Frog" then
		cfg.FaceColor  = cfg.FaceColor  or Color3.fromRGB(15, 20, 18)
		cfg.EyeColor   = cfg.EyeColor   or Color3.fromRGB(255, 255, 255)
		cfg.PupilColor = cfg.PupilColor or Color3.fromRGB(15, 20, 18)
	elseif cfg.Type == "Image" then
		cfg.Image = cfg.Image or "rbxassetid://6031280882"
	elseif cfg.Type == "Text" then
		cfg.Text      = cfg.Text or "🐸"
		cfg.TextSize  = cfg.TextSize or 18
		cfg.TextColor = cfg.TextColor or Color3.fromRGB(255, 255, 255)
		cfg.Font      = cfg.Font or Enum.Font.GothamBold
	end
	return cfg
end

-- Returns a container Frame; caller decides parent & size
local function buildLogo(container, cfg)
	cfg = normalizeLogo(cfg)

	-- wipe previous contents (except background frame)
	for _, c in pairs(container:GetChildren()) do
		if c:IsA("GuiObject") or c:IsA("UIGradient") then
			if c.Name ~= "LogoBG" then c:Destroy() end
		end
	end

	-- ensure background frame exists
	local BG = container:FindFirstChild("LogoBG")
	if not BG then
		BG = U.new("Frame", {
			Name = "LogoBG",
			Parent = container,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			BorderSizePixel = 0,
			ZIndex = container.ZIndex + 1,
		})
	end

	-- clear previous face children
	for _, c in pairs(BG:GetChildren()) do c:Destroy() end

	if cfg.Type == "None" then
		return
	elseif cfg.Type == "Image" then
		U.new("ImageLabel", {
			Parent = BG,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.78, 0, 0.78, 0),
			Position = UDim2.new(0.11, 0, 0.11, 0),
			Image = cfg.Image,
			ImageColor3 = cfg.ImageColor or Color3.fromRGB(255,255,255),
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = BG.ZIndex + 1,
		})
	elseif cfg.Type == "Text" then
		U.new("TextLabel", {
			Parent = BG,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Font = cfg.Font,
			Text = cfg.Text,
			TextColor3 = cfg.TextColor,
			TextSize = cfg.TextSize,
			TextScaled = false,
			ZIndex = BG.ZIndex + 1,
		})
	else -- Frog (default)
		local face = U.new("Frame", {
			Parent = BG,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = BG.ZIndex + 1,
		})

		-- eyes
		local function makeEye(xScale, xOffset)
			local eye = U.new("Frame", {
				Parent = face,
				BackgroundColor3 = cfg.EyeColor,
				BorderSizePixel = 0,
				Position = UDim2.new(xScale, xOffset, 0.22, 0),
				Size = UDim2.new(0.28, 0, 0.28, 0),
				ZIndex = face.ZIndex + 1,
			})
			U.corner(eye, 999)
			U.new("Frame", {
				Parent = eye,
				BackgroundColor3 = cfg.PupilColor,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0.4, 0, 0.4, 0),
				ZIndex = eye.ZIndex + 1,
			})
			U.corner(eye:FindFirstChildOfClass("Frame"), 999)
		end
		makeEye(0.14, 0)
		makeEye(0.58, 0)

		-- smile
		U.new("TextLabel", {
			Parent = face,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0.44, 0),
			Size = UDim2.new(1, 0, 0.5, 0),
			Font = Enum.Font.GothamBold,
			Text = "‿",
			TextColor3 = cfg.FaceColor,
			TextSize = math.max(10, BG.AbsoluteSize.Y * 0.55),
			ZIndex = face.ZIndex + 1,
		})
	end
end

-- ═══════════════════════════════════════════════════════════════════════
--  THEMES
-- ═══════════════════════════════════════════════════════════════════════
local Themes = {
	Frog = {
		SchemeColor  = Color3.fromRGB(76, 217, 100),
		Background   = Color3.fromRGB(18, 24, 20),
		Header       = Color3.fromRGB(13, 18, 15),
		TextColor    = Color3.fromRGB(235, 245, 238),
		SubText      = Color3.fromRGB(130, 165, 140),
		ElementColor = Color3.fromRGB(28, 38, 32),
		Stroke       = Color3.fromRGB(255, 255, 255),
	},
	LilyPad = {
		SchemeColor  = Color3.fromRGB(64, 200, 130),
		Background   = Color3.fromRGB(20, 28, 26),
		Header       = Color3.fromRGB(14, 20, 18),
		TextColor    = Color3.fromRGB(228, 245, 235),
		SubText      = Color3.fromRGB(125, 165, 150),
		ElementColor = Color3.fromRGB(30, 42, 38),
		Stroke       = Color3.fromRGB(255, 255, 255),
	},
	Toad = {
		SchemeColor  = Color3.fromRGB(180, 200, 80),
		Background   = Color3.fromRGB(22, 24, 18),
		Header       = Color3.fromRGB(16, 18, 13),
		TextColor    = Color3.fromRGB(245, 248, 230),
		SubText      = Color3.fromRGB(160, 170, 120),
		ElementColor = Color3.fromRGB(34, 38, 26),
		Stroke       = Color3.fromRGB(255, 255, 255),
	},
	Poison = {
		SchemeColor  = Color3.fromRGB(150, 240, 90),
		Background   = Color3.fromRGB(15, 18, 22),
		Header       = Color3.fromRGB(10, 13, 16),
		TextColor    = Color3.fromRGB(230, 245, 220),
		SubText      = Color3.fromRGB(130, 160, 120),
		ElementColor = Color3.fromRGB(24, 30, 32),
		Stroke       = Color3.fromRGB(255, 255, 255),
	},
	Aqua = {
		SchemeColor  = Color3.fromRGB(66, 200, 244),
		Background   = Color3.fromRGB(14, 22, 30),
		Header       = Color3.fromRGB(9, 15, 22),
		TextColor    = Color3.fromRGB(225, 240, 250),
		SubText      = Color3.fromRGB(130, 160, 185),
		ElementColor = Color3.fromRGB(24, 34, 44),
		Stroke       = Color3.fromRGB(255, 255, 255),
	},
	Gold = {
		SchemeColor  = Color3.fromRGB(240, 190, 60),
		Background   = Color3.fromRGB(24, 20, 14),
		Header       = Color3.fromRGB(18, 15, 10),
		TextColor    = Color3.fromRGB(250, 245, 230),
		SubText      = Color3.fromRGB(180, 160, 110),
		ElementColor = Color3.fromRGB(36, 30, 22),
		Stroke       = Color3.fromRGB(255, 255, 255),
	},
	Blood = {
		SchemeColor  = Color3.fromRGB(235, 70, 90),
		Background   = Color3.fromRGB(18, 12, 14),
		Header       = Color3.fromRGB(12, 8, 10),
		TextColor    = Color3.fromRGB(250, 235, 238),
		SubText      = Color3.fromRGB(160, 130, 138),
		ElementColor = Color3.fromRGB(28, 20, 24),
		Stroke       = Color3.fromRGB(255, 255, 255),
	},
	Midnight = {
		SchemeColor  = Color3.fromRGB(26, 189, 158),
		Background   = Color3.fromRGB(20, 26, 34),
		Header       = Color3.fromRGB(14, 19, 26),
		TextColor    = Color3.fromRGB(230, 240, 245),
		SubText      = Color3.fromRGB(130, 155, 165),
		ElementColor = Color3.fromRGB(30, 38, 48),
		Stroke       = Color3.fromRGB(255, 255, 255),
	},
	Light = {
		SchemeColor  = Color3.fromRGB(76, 217, 100),
		Background   = Color3.fromRGB(245, 246, 250),
		Header       = Color3.fromRGB(255, 255, 255),
		TextColor    = Color3.fromRGB(28, 30, 40),
		SubText      = Color3.fromRGB(120, 125, 145),
		ElementColor = Color3.fromRGB(235, 237, 245),
		Stroke       = Color3.fromRGB(0, 0, 0),
	},
}

-- ═══════════════════════════════════════════════════════════════════════
--  CORE
-- ═══════════════════════════════════════════════════════════════════════
local activeUI = {}

function Frog:DraggingEnabled(frame, parent) U.drag(frame, parent) end

function Frog:ToggleUI()
	if not activeUI.ScreenGui then return end
	Frog:_setVisible(not activeUI.Visible)
end

function Frog:_setVisible(state)
	local ui = activeUI
	if not ui or not ui.Main then return end
	ui.Visible = state
	if state then
		ui.Main.Visible = true
		ui.Main.Size = UDim2.new(0, 0, 0, 0)
		ui.Main.Position = UDim2.new(0.5, -0, 0.5, -0)
		U.tween(ui.Main, 0.35, {
			Size     = UDim2.new(0, 620, 0, 420),
			Position = UDim2.new(0.5, -310, 0.5, -210),
		}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		ui.OpenButton.Visible = false
	else
		U.tween(ui.Main, 0.25, { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0) })
		task.delay(0.25, function()
			ui.Main.Visible = false
			ui.OpenButton.Visible = true
		end)
	end
end

-- ─────────────────────────────────────────────────────────────────────
--  🎨 Frog:SetLogo(config)  — ganti logo saat runtime
--  Contoh:
--    Frog:SetLogo({ Type = "Image", Image = "rbxassetid://123456" })
--    Frog:SetLogo({ Type = "Text",  Text = "⚡", TextSize = 18 })
--    Frog:SetLogo({ Type = "Frog" })
--    Frog:SetLogo({ Type = "None" })
-- ─────────────────────────────────────────────────────────────────────
function Frog:SetLogo(cfg)
	if not activeUI then return end
	activeUI.LogoConfig = normalizeLogo(cfg)
	if activeUI.LogoHolder then
		buildLogo(activeUI.LogoHolder, activeUI.LogoConfig)
	end
	if activeUI.OpenLogoHolder then
		buildLogo(activeUI.OpenLogoHolder, activeUI.LogoConfig)
	end
end

-- ═══════════════════════════════════════════════════════════════════════
--  CREATE LIB
--  Frog.CreateLib(name, theme, logoConfig)
-- ═══════════════════════════════════════════════════════════════════════
function Frog.CreateLib(libName, themeChoice, logoConfig)
	libName = libName or "Frog UI"

	if type(themeChoice) == "string" then
		themeChoice = Themes[themeChoice] or Themes.Frog
	elseif type(themeChoice) == "table" then
		for k, v in pairs(Themes.Frog) do
			if themeChoice[k] == nil then themeChoice[k] = v end
		end
	else
		themeChoice = Themes.Frog
	end
	local T = themeChoice
	logoConfig = normalizeLogo(logoConfig)

	for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
		if v:IsA("ScreenGui") and v.Name == libName .. "_FrogUI" then v:Destroy() end
	end

	local ScreenGui = U.new("ScreenGui", {
		Name = libName .. "_FrogUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	})
	local ok = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
	if not ok or not ScreenGui.Parent then
		ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end

	activeUI.ScreenGui  = ScreenGui
	activeUI.Visible    = true
	activeUI.Theme      = T
	activeUI.LogoConfig = logoConfig

	-- ═══════════════════════════════════════════════════════════════════
	--  MAIN WINDOW
	-- ═══════════════════════════════════════════════════════════════════
	local Main = U.new("Frame", {
		Name = "Main",
		Parent = ScreenGui,
		BackgroundColor3 = T.Background,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 620, 0, 420),
		Position = UDim2.new(0.5, -310, 0.5, -210),
		ClipsDescendants = true,
	})
	U.corner(Main, 14)
	U.stroke(Main, T.Stroke, 1, 0.92)

	local glow = U.new("Frame", {
		Parent = Main,
		BackgroundColor3 = T.SchemeColor,
		BackgroundTransparency = 0.94,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 260, 0, 260),
		Position = UDim2.new(1, -150, 0, -120),
		ZIndex = 0,
	})
	U.corner(glow, 130)

	-- ═══ HEADER ═══
	local Header = U.new("Frame", {
		Name = "Header",
		Parent = Main,
		BackgroundColor3 = T.Header,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 48),
		ZIndex = 2,
	})
	U.corner(Header, 14)
	U.new("Frame", {
		Parent = Header,
		BackgroundColor3 = T.Header,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.75, 0),
		Size = UDim2.new(1, 0, 0.25, 0),
		ZIndex = 2,
	})
	U.drag(Header, Main)

	-- ─── Logo Holder ───
	local LogoHolder = U.new("Frame", {
		Name = "LogoHolder",
		Parent = Header,
		BackgroundColor3 = T.SchemeColor,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 14, 0.5, -15),
		Size = UDim2.new(0, 30, 0, 30),
		ZIndex = 3,
	})
	U.corner(LogoHolder, 9)
	U.gradient(LogoHolder,
		Color3.fromRGB(
			math.min(255, T.SchemeColor.R * 255 + 55),
			math.min(255, T.SchemeColor.G * 255 + 45),
			math.min(255, T.SchemeColor.B * 255 + 65)
		),
		Color3.fromRGB(
			math.max(0, T.SchemeColor.R * 255 - 30),
			math.max(0, T.SchemeColor.G * 255 - 30),
			math.max(0, T.SchemeColor.B * 255 - 15)
		),
		120
	)
	activeUI.LogoHolder = LogoHolder
	buildLogo(LogoHolder, logoConfig)

	-- ─── Title ───
	U.new("TextLabel", {
		Parent = Header,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 54, 0, 0),
		Size = UDim2.new(0, 300, 0, 26),
		Font = Enum.Font.GothamBold,
		Text = libName,
		TextColor3 = T.TextColor,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
	})

	U.new("TextLabel", {
		Parent = Header,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 54, 0, 24),
		Size = UDim2.new(0, 300, 0, 14),
		Font = Enum.Font.Gotham,
		Text = "🐸  froggy modern interface",
		TextColor3 = T.SubText,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
	})

	-- ─── Window Buttons ───
	local function windowBtn(name, icon, xPos, color)
		local btn = U.new("TextButton", {
			Parent = Header,
			BackgroundColor3 = color,
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0,
			Position = UDim2.new(1, xPos, 0.5, -11),
			Size = UDim2.new(0, 22, 0, 22),
			Font = Enum.Font.GothamBold,
			Text = icon,
			TextColor3 = T.TextColor,
			TextSize = 13,
			AutoButtonColor = false,
			Name = name,
			ZIndex = 3,
		})
		U.corner(btn, 7)
		btn.MouseEnter:Connect(function() U.tween(btn, 0.15, { BackgroundTransparency = 0.75 }) end)
		btn.MouseLeave:Connect(function() U.tween(btn, 0.15, { BackgroundTransparency = 0.9 }) end)
		return btn
	end

	local MinBtn   = windowBtn("Minimize", "—", -60, T.SchemeColor)
	local CloseBtn = windowBtn("Close", "×", -32, Color3.fromRGB(235, 70, 90))

	CloseBtn.MouseButton1Click:Connect(function()
		U.tween(Main, 0.25, {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
		})
		task.wait(0.25)
		ScreenGui:Destroy()
	end)
	MinBtn.MouseButton1Click:Connect(function() Frog:_setVisible(false) end)

	-- ═══════════════════════════════════════════════════════════════════
	--  FLOATING BUTTON
	-- ═══════════════════════════════════════════════════════════════════
	local OpenButton = U.new("TextButton", {
		Name = "OpenButton",
		Parent = ScreenGui,
		BackgroundColor3 = T.SchemeColor,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 30, 0.75, 0),
		Size = UDim2.new(0, 56, 0, 56),
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		ZIndex = 50,
	})
	U.corner(OpenButton, 28)
	U.stroke(OpenButton, Color3.fromRGB(255, 255, 255), 1.5, 0.7)
	U.gradient(OpenButton,
		Color3.fromRGB(
			math.min(255, T.SchemeColor.R * 255 + 60),
			math.min(255, T.SchemeColor.G * 255 + 50),
			math.min(255, T.SchemeColor.B * 255 + 70)
		),
		Color3.fromRGB(
			math.max(0, T.SchemeColor.R * 255 - 30),
			math.max(0, T.SchemeColor.G * 255 - 30),
			math.max(0, T.SchemeColor.B * 255 - 10)
		),
		130
	)

	local OpenLogoHolder = U.new("Frame", {
		Name = "OpenLogoHolder",
		Parent = OpenButton,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 51,
	})
	activeUI.OpenLogoHolder = OpenLogoHolder
	buildLogo(OpenLogoHolder, logoConfig)

	OpenButton.MouseEnter:Connect(function()
		U.tween(OpenButton, 0.2, { Size = UDim2.new(0, 62, 0, 62), Position = UDim2.new(0, 27, 0.75, -3) })
	end)
	OpenButton.MouseLeave:Connect(function()
		U.tween(OpenButton, 0.2, { Size = UDim2.new(0, 56, 0, 56), Position = UDim2.new(0, 30, 0.75, 0) })
	end)

	OpenButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			local moved = false
			local start = input.Position
			local startPos = OpenButton.Position
			local moveConn
			moveConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					moveConn:Disconnect()
					if not moved then Frog:_setVisible(true) end
				end
			end)
			local dragConn
			dragConn = UserInputService.InputChanged:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseMovement
				or i.UserInputType == Enum.UserInputType.Touch then
					local delta = i.Position - start
					if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then
						moved = true
						OpenButton.Position = UDim2.new(
							startPos.X.Scale, startPos.X.Offset + delta.X,
							startPos.Y.Scale, startPos.Y.Offset + delta.Y
						)
					end
				end
			end)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					if dragConn then dragConn:Disconnect() end
				end
			end)
		end
	end)

	-- ═══════════════════════════════════════════════════════════════════
	--  SIDEBAR
	-- ═══════════════════════════════════════════════════════════════════
	local Sidebar = U.new("Frame", {
		Name = "Sidebar",
		Parent = Main,
		BackgroundColor3 = T.Header,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 48),
		Size = UDim2.new(0, 160, 1, -48),
		ZIndex = 2,
	})

	local TabScroll = U.new("ScrollingFrame", {
		Parent = Sidebar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 10),
		Size = UDim2.new(1, -20, 1, -20),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = T.SchemeColor,
		BorderSizePixel = 0,
	})
	U.new("UIListLayout", {
		Parent = TabScroll,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local Content = U.new("Frame", {
		Name = "Content",
		Parent = Main,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 160, 0, 48),
		Size = UDim2.new(1, -160, 1, -48),
		ClipsDescendants = true,
		ZIndex = 1,
	})

	local Pages = U.new("Folder", { Name = "Pages", Parent = Content })

	-- ═══════════════════════════════════════════════════════════════════
	--  TAB API
	-- ═══════════════════════════════════════════════════════════════════
	local Tabs = {}
	local firstTab = true

	function Tabs:NewTab(tabName)
		tabName = tabName or "Tab"

		local TabBtn = U.new("TextButton", {
			Name = tabName .. "_Btn",
			Parent = TabScroll,
			BackgroundColor3 = T.SchemeColor,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 34),
			Font = Enum.Font.GothamMedium,
			Text = "  🐸  " .. tabName,
			TextColor3 = T.SubText,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = false,
		})
		U.corner(TabBtn, 8)

		local indicator = U.new("Frame", {
			Parent = TabBtn,
			BackgroundColor3 = T.SchemeColor,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0.5, -8),
			Size = UDim2.new(0, 3, 0, 16),
			BackgroundTransparency = 1,
			ZIndex = 3,
		})
		U.corner(indicator, 2)

		local Page = U.new("ScrollingFrame", {
			Name = tabName .. "_Page",
			Parent = Pages,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = T.SchemeColor,
			BorderSizePixel = 0,
			Visible = false,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
		})
		U.padding(Page, 12)
		local PageLayout = U.new("UIListLayout", {
			Parent = Page,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})

		local function updateCanvas()
			Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 24)
		end
		PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
		updateCanvas()

		local function select()
			for _, p in pairs(Pages:GetChildren()) do
				if p:IsA("ScrollingFrame") then p.Visible = false end
			end
			Page.Visible = true
			for _, b in pairs(TabScroll:GetChildren()) do
				if b:IsA("TextButton") then
					U.tween(b, 0.2, { BackgroundTransparency = 1, TextColor3 = T.SubText })
					local ind = b:FindFirstChildOfClass("Frame")
					if ind then U.tween(ind, 0.2, { BackgroundTransparency = 1 }) end
				end
			end
			U.tween(TabBtn, 0.2, { BackgroundTransparency = 0.88, TextColor3 = T.TextColor })
			U.tween(indicator, 0.2, { BackgroundTransparency = 0 })
		end

		TabBtn.MouseButton1Click:Connect(select)
		if firstTab then firstTab = false; task.defer(select) end

		local Sections = {}

		function Sections:NewSection(secName, hidden)
			secName = secName or "Section"
			hidden  = hidden or false

			local SectionFrame = U.new("Frame", {
				Name = "Section",
				Parent = Page,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			})
			U.new("UIListLayout", {
				Parent = SectionFrame,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			})

			if not hidden then
				local SecHeader = U.new("TextLabel", {
					Parent = SectionFrame,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 22),
					Font = Enum.Font.GothamBold,
					Text = "🐸  " .. secName:upper(),
					TextColor3 = T.SubText,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = 0,
				})
				U.new("UIPadding", { Parent = SecHeader, PaddingLeft = UDim.new(0, 6) })
			end

			local Inner = U.new("Frame", {
				Parent = SectionFrame,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 1,
			})
			U.new("UIListLayout", {
				Parent = Inner,
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
			})

			local Elements = {}

			local function makeRow(height)
				local Row = U.new("TextButton", {
					Parent = Inner,
					BackgroundColor3 = T.ElementColor,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, height or 38),
					Text = "",
					AutoButtonColor = false,
				})
				U.corner(Row, 10)
				U.stroke(Row, T.Stroke, 1, 0.94)
				Row.MouseEnter:Connect(function()
					U.tween(Row, 0.15, {
						BackgroundColor3 = Color3.fromRGB(
							math.min(255, T.ElementColor.R * 255 + 10),
							math.min(255, T.ElementColor.G * 255 + 10),
							math.min(255, T.ElementColor.B * 255 + 12)
						)
					})
				end)
				Row.MouseLeave:Connect(function()
					U.tween(Row, 0.15, { BackgroundColor3 = T.ElementColor })
				end)
				return Row
			end

			local function makeRipple()
				local ripple = U.new("Frame", {
					BackgroundColor3 = T.SchemeColor,
					BackgroundTransparency = 0.7,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 0, 0, 0),
				})
				U.corner(ripple, 999)
				return ripple
			end

			function Elements:NewButton(bname, tip, callback)
				bname    = bname or "Button"
				tip      = tip or "Click me!"
				callback = callback or function() end

				local Row = makeRow(40)
				U.new("TextLabel", {
					Parent = Row, BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0.5, -8),
					Size = UDim2.new(0, 20, 0, 16),
					Font = Enum.Font.GothamBold, Text = "🐸",
					TextColor3 = T.SchemeColor, TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				local Label = U.new("TextLabel", {
					Parent = Row, BackgroundTransparency = 1,
					Position = UDim2.new(0, 38, 0, 0),
					Size = UDim2.new(1, -60, 1, 0),
					Font = Enum.Font.GothamMedium, Text = bname,
					TextColor3 = T.TextColor, TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				U.new("TextLabel", {
					Parent = Row, BackgroundTransparency = 1,
					Position = UDim2.new(1, -30, 0, 0),
					Size = UDim2.new(0, 20, 1, 0),
					Font = Enum.Font.GothamBold, Text = "›",
					TextColor3 = T.SubText, TextSize = 18,
					TextXAlignment = Enum.TextXAlignment.Right,
				})

				Row.MouseButton1Click:Connect(function()
					local ripple = makeRipple()
					ripple.Parent = Row
					local x, y = Mouse.X - Row.AbsolutePosition.X, Mouse.Y - Row.AbsolutePosition.Y
					ripple.Position = UDim2.new(0, x, 0, y)
					U.tween(ripple, 0.5, {
						Size = UDim2.new(0, 200, 0, 200),
						Position = UDim2.new(0, x - 100, 0, y - 100),
						BackgroundTransparency = 1
					})
					task.delay(0.5, function() ripple:Destroy() end)
					pcall(callback)
				end)
				return { UpdateButton = function(_, n) Label.Text = n end }
			end

			function Elements:NewToggle(tname, tip, callback)
				tname    = tname or "Toggle"
				tip      = tip or "Toggle option"
				callback = callback or function() end

				local Row = makeRow(40)
				local toggled = false

				local Label = U.new("TextLabel", {
					Parent = Row, BackgroundTransparency = 1,
					Position = UDim2.new(0, 16, 0, 0),
					Size = UDim2.new(1, -90, 1, 0),
					Font = Enum.Font.GothamMedium, Text = "🐸  " .. tname,
					TextColor3 = T.TextColor, TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
				})

				local Track = U.new("Frame", {
					Parent = Row, BackgroundColor3 = Color3.fromRGB(60, 62, 75),
					BorderSizePixel = 0,
					Position = UDim2.new(1, -56, 0.5, -10),
					Size = UDim2.new(0, 40, 0, 20),
				})
				U.corner(Track, 10)

				local Knob = U.new("Frame", {
					Parent = Track, BackgroundColor3 = Color3.fromRGB(245, 245, 250),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 2, 0.5, -8),
					Size = UDim2.new(0, 16, 0, 16),
				})
				U.corner(Knob, 8)

				local function update(state)
					toggled = state
					if state then
						U.tween(Track, 0.2, { BackgroundColor3 = T.SchemeColor })
						U.tween(Knob, 0.2, { Position = UDim2.new(1, -18, 0.5, -8) })
					else
						U.tween(Track, 0.2, { BackgroundColor3 = Color3.fromRGB(60, 62, 75) })
						U.tween(Knob, 0.2, { Position = UDim2.new(0, 2, 0.5, -8) })
					end
				end

				Row.MouseButton1Click:Connect(function()
					update(not toggled)
					pcall(callback, toggled)
				end)
				return {
					UpdateToggle = function(_, newText, isTogOn)
						if newText then Label.Text = "🐸  " .. newText end
						if isTogOn ~= nil then update(isTogOn); pcall(callback, isTogOn) end
					end
				}
			end

			function Elements:NewSlider(sName, sTip, maxVal, minVal, callback)
				sName    = sName or "Slider"
				sTip     = sTip or "Slide me"
				maxVal   = maxVal or 100
				minVal   = minVal or 0
				callback = callback or function() end

				local Row = U.new("Frame", {
					Parent = Inner, BackgroundColor3 = T.ElementColor,
					BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 54),
				})
				U.corner(Row, 10)
				U.stroke(Row, T.Stroke, 1, 0.94)

				U.new("TextLabel", {
					Parent = Row, BackgroundTransparency = 1,
					Position = UDim2.new(0, 16, 0, 8),
					Size = UDim2.new(1, -100, 0, 16),
					Font = Enum.Font.GothamMedium, Text = "🐸  " .. sName,
					TextColor3 = T.TextColor, TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
				})

				local ValueLabel = U.new("TextLabel", {
					Parent = Row, BackgroundTransparency = 1,
					Position = UDim2.new(1, -70, 0, 8),
					Size = UDim2.new(0, 54, 0, 16),
					Font = Enum.Font.GothamBold, Text = tostring(minVal),
					TextColor3 = T.SchemeColor, TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Right,
				})

				local Track = U.new("Frame", {
					Parent = Row, BackgroundColor3 = Color3.fromRGB(58, 60, 74),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 16, 1, -18),
					Size = UDim2.new(1, -32, 0, 6),
				})
				U.corner(Track, 3)

				local Fill = U.new("Frame", {
					Parent = Track, BackgroundColor3 = T.SchemeColor,
					BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0),
				})
				U.corner(Fill, 3)

				local Knob = U.new("Frame", {
					Parent = Track, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0, 0, 0.5, 0),
					Size = UDim2.new(0, 14, 0, 14), ZIndex = 3,
				})
				U.corner(Knob, 7)
				U.stroke(Knob, T.SchemeColor, 2, 0)

				local dragging = false
				local function setValue(v, fire)
					v = math.clamp(v, minVal, maxVal)
					local alpha = (v - minVal) / (maxVal - minVal)
					U.tween(Fill, 0.1, { Size = UDim2.new(alpha, 0, 1, 0) })
					U.tween(Knob, 0.1, { Position = UDim2.new(alpha, 0, 0.5, 0) })
					ValueLabel.Text = tostring(math.floor(v))
					if fire then pcall(callback, math.floor(v)) end
				end

				Track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						local rel = math.clamp((Mouse.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
						setValue(minVal + rel * (maxVal - minVal), true)
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch) then
						local rel = math.clamp((Mouse.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
						setValue(minVal + rel * (maxVal - minVal), true)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
				end)

				setValue(minVal, false)
				return { SetValue = function(_, v) setValue(v, true) end }
			end

			function Elements:NewDropdown(name, tip, list, callback)
				name = name or "Dropdown"
				list = list or {}
				callback = callback or function() end

				local Holder = U.new("Frame", {
					Parent = Inner, BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 40),
					AutomaticSize = Enum.AutomaticSize.Y,
				})
				U.new("UIListLayout", {
					Parent = Holder, Padding = UDim.new(0, 6),
					SortOrder = Enum.SortOrder.LayoutOrder,
				})

				local Row = U.new("TextButton", {
					Parent = Holder, BackgroundColor3 = T.ElementColor,
					BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 40),
					Text = "", AutoButtonColor = false, LayoutOrder = 1,
				})
				U.corner(Row, 10)
				U.stroke(Row, T.Stroke, 1, 0.94)

				local Label = U.new("TextLabel", {
					Parent = Row, BackgroundTransparency = 1,
					Position = UDim2.new(0, 16, 0, 0),
					Size = UDim2.new(1, -60, 1, 0),
					Font = Enum.Font.GothamMedium, Text = "🐸  " .. name,
					TextColor3 = T.TextColor, TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				local Chev = U.new("TextLabel", {
					Parent = Row, BackgroundTransparency = 1,
					Position = UDim2.new(1, -34, 0, 0),
					Size = UDim2.new(0, 20, 1, 0),
					Font = Enum.Font.GothamBold, Text = "▾",
					TextColor3 = T.SubText, TextSize = 14,
				})

				local ListFrame = U.new("Frame", {
					Parent = Holder, BackgroundColor3 = T.ElementColor,
					BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0),
					ClipsDescendants = true, LayoutOrder = 2,
				})
				U.corner(ListFrame, 10)
				U.stroke(ListFrame, T.Stroke, 1, 0.94)
				local ListLayout = U.new("UIListLayout", {
					Parent = ListFrame, Padding = UDim.new(0, 4),
					SortOrder = Enum.SortOrder.LayoutOrder,
				})
				U.padding(ListFrame, 6)

				local open = false
				local function refreshOptions(newList)
					for _, c in pairs(ListFrame:GetChildren()) do
						if c:IsA("TextButton") then c:Destroy() end
					end
					for i, opt in ipairs(newList) do
						local OptBtn = U.new("TextButton", {
							Parent = ListFrame, BackgroundColor3 = T.Background,
							BackgroundTransparency = 0.3, BorderSizePixel = 0,
							Size = UDim2.new(1, 0, 0, 30),
							Font = Enum.Font.Gotham, Text = "   " .. tostring(opt),
							TextColor3 = T.TextColor, TextSize = 12,
							TextXAlignment = Enum.TextXAlignment.Left,
							AutoButtonColor = false, LayoutOrder = i,
						})
						U.corner(OptBtn, 6)
						OptBtn.MouseEnter:Connect(function()
							U.tween(OptBtn, 0.15, { BackgroundTransparency = 0, BackgroundColor3 = T.SchemeColor })
						end)
						OptBtn.MouseLeave:Connect(function()
							U.tween(OptBtn, 0.15, { BackgroundTransparency = 0.3, BackgroundColor3 = T.Background })
						end)
						OptBtn.MouseButton1Click:Connect(function()
							Label.Text = "🐸  " .. name .. "  ·  " .. tostring(opt)
							Label.TextColor3 = T.SchemeColor
							pcall(callback, opt)
							open = false
							U.tween(Chev, 0.2, { Rotation = 0 })
							U.tween(ListFrame, 0.25, { Size = UDim2.new(1, 0, 0, 0) })
						end)
					end
					if open then
						task.wait(0.05)
						U.tween(ListFrame, 0.25, { Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y + 12) })
					end
				end
				refreshOptions(list)

				Row.MouseButton1Click:Connect(function()
					open = not open
					if open then
						U.tween(Chev, 0.2, { Rotation = 180 })
						U.tween(ListFrame, 0.25, { Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y + 12) })
					else
						U.tween(Chev, 0.2, { Rotation = 0 })
						U.tween(ListFrame, 0.25, { Size = UDim2.new(1, 0, 0, 0) })
					end
				end)
				return { Refresh = function(_, l) refreshOptions(l or {}) end }
			end

			function Elements:NewTextBox(tname, tip, callback)
				tname    = tname or "Input"
				callback = callback or function() end

				local Row = U.new("Frame", {
					Parent = Inner, BackgroundColor3 = T.ElementColor,
					BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 40),
				})
				U.corner(Row, 10)
				U.stroke(Row, T.Stroke, 1, 0.94)

				U.new("TextLabel", {
					Parent = Row, BackgroundTransparency = 1,
					Position = UDim2.new(0, 16, 0, 0),
					Size = UDim2.new(0.45, -20, 1, 0),
					Font = Enum.Font.GothamMedium, Text = "🐸  " .. tname,
					TextColor3 = T.TextColor, TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
				})

				local Input = U.new("TextBox", {
					Parent = Row, BackgroundColor3 = T.Background,
					BorderSizePixel = 0,
					Position = UDim2.new(0.5, 0, 0.5, -11),
					Size = UDim2.new(0.5, -16, 0, 22),
					Font = Enum.Font.Gotham, PlaceholderText = "Type here...",
					PlaceholderColor3 = T.SubText, Text = "",
					TextColor3 = T.TextColor, TextSize = 12,
					ClearTextOnFocus = false,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				U.corner(Input, 6)
				U.new("UIPadding", {
					Parent = Input,
					PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
				})

				Input.Focused:Connect(function()
					U.tween(Input, 0.15, { BackgroundColor3 = T.SchemeColor, BackgroundTransparency = 0.7 })
				end)
				Input.FocusLost:Connect(function(enter)
					U.tween(Input, 0.15, { BackgroundTransparency = 0 })
					if enter then pcall(callback, Input.Text) end
				end)
			end

			function Elements:NewKeybind(kname, ktip, firstKey, callback)
				kname    = kname or "Keybind"
				callback = callback or function() end
				local key = firstKey or Enum.KeyCode.E
				if typeof(key) == "EnumItem" then key = key.Name end

				local Row = U.new("TextButton", {
					Parent = Inner, BackgroundColor3 = T.ElementColor,
					BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 40),
					Text = "", AutoButtonColor = false,
				})
				U.corner(Row, 10)
				U.stroke(Row, T.Stroke, 1, 0.94)

				U.new("TextLabel", {
					Parent = Row, BackgroundTransparency = 1,
					Position = UDim2.new(0, 16, 0, 0),
					Size = UDim2.new(1, -100, 1, 0),
					Font = Enum.Font.GothamMedium, Text = "🐸  " .. kname,
					TextColor3 = T.TextColor, TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
				})

				local KeyBox = U.new("TextLabel", {
					Parent = Row, BackgroundColor3 = T.Background,
					BackgroundTransparency = 0.3, BorderSizePixel = 0,
					Position = UDim2.new(1, -72, 0.5, -11),
					Size = UDim2.new(0, 56, 0, 22),
					Font = Enum.Font.GothamBold, Text = tostring(key),
					TextColor3 = T.SchemeColor, TextSize = 12,
				})
				U.corner(KeyBox, 6)

				local binding = false
				Row.MouseButton1Click:Connect(function()
					if binding then return end
					binding = true
					KeyBox.Text = "..."
					KeyBox.TextColor3 = T.SubText
					local input = UserInputService.InputBegan:Wait()
					if input.KeyCode and input.KeyCode.Name ~= "Unknown" then
						key = input.KeyCode.Name
						KeyBox.Text = key
						KeyBox.TextColor3 = T.SchemeColor
					else
						KeyBox.Text = tostring(key)
						KeyBox.TextColor3 = T.SchemeColor
					end
					binding = false
				end)

				UserInputService.InputBegan:Connect(function(input, gpe)
					if gpe then return end
					if input.KeyCode.Name == key and not binding then pcall(callback) end
				end)
			end

			function Elements:NewLabel(text)
				local Row = U.new("Frame", {
					Parent = Inner, BackgroundColor3 = T.SchemeColor,
					BackgroundTransparency = 0.85, BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 32),
				})
				U.corner(Row, 8)
				local Label = U.new("TextLabel", {
					Parent = Row, BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 0),
					Size = UDim2.new(1, -24, 1, 0),
					Font = Enum.Font.GothamMedium, Text = "🐸  " .. (text or ""),
					TextColor3 = T.TextColor, TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				return { UpdateLabel = function(_, n) Label.Text = "🐸  " .. n end }
			end

			function Elements:NewColorPicker(cname, ctip, defaultColor, callback)
				cname = cname or "Color"
				defaultColor = defaultColor or Color3.fromRGB(76, 217, 100)
				callback = callback or function() end

				local Row = U.new("Frame", {
					Parent = Inner, BackgroundColor3 = T.ElementColor,
					BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 44),
				})
				U.corner(Row, 10)
				U.stroke(Row, T.Stroke, 1, 0.94)

				U.new("TextLabel", {
					Parent = Row, BackgroundTransparency = 1,
					Position = UDim2.new(0, 16, 0, 0),
					Size = UDim2.new(1, -80, 1, 0),
					Font = Enum.Font.GothamMedium, Text = "🐸  " .. cname,
					TextColor3 = T.TextColor, TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				local Swatch = U.new("Frame", {
					Parent = Row, BackgroundColor3 = defaultColor,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -60, 0.5, -12),
					Size = UDim2.new(0, 46, 0, 24),
				})
				U.corner(Swatch, 8)
				U.stroke(Swatch, Color3.fromRGB(255,255,255), 1, 0.7)

				local Panel = U.new("Frame", {
					Parent = Row, BackgroundColor3 = T.Background,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 12, 1, 6),
					Size = UDim2.new(1, -24, 0, 0),
					ClipsDescendants = true,
				})
				U.corner(Panel, 10)
				U.stroke(Panel, T.Stroke, 1, 0.9)

				local open = false
				Row.MouseButton1Click:Connect(function()
					open = not open
					U.tween(Panel, 0.25, { Size = UDim2.new(1, -24, 0, open and 120 or 0) })
				end)

				local hue, sat, val = Color3.toHSV(defaultColor)

				local function makeBar(yPos, initColor, grad1, grad2)
					local bar = U.new("Frame", {
						Parent = Panel, BackgroundColor3 = initColor,
						BorderSizePixel = 0,
						Position = UDim2.new(0, 12, 0, yPos),
						Size = UDim2.new(1, -24, 0, 16),
					})
					U.corner(bar, 8)
					if grad1 and grad2 then
						U.new("UIGradient", {
							Parent = bar,
							Color = ColorSequence.new(grad1, grad2), Rotation = 0,
						})
					end
					local knob = U.new("Frame", {
						Parent = bar, BackgroundColor3 = Color3.fromRGB(255,255,255),
						BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0, 0, 0.5, 0),
						Size = UDim2.new(0, 18, 0, 18), ZIndex = 3,
					})
					U.corner(knob, 9)
					U.stroke(knob, Color3.fromRGB(0,0,0), 2, 0.5)
					return bar, knob
				end

				local HueBar, HueKnob = makeBar(12, Color3.fromRGB(255,0,0),
					Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0))
				HueBar.UIGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
					ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
					ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
					ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
					ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
					ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
				})

				local SatBar, SatKnob = makeBar(40, Color3.fromHSV(hue, 1, 1),
					Color3.fromRGB(255,255,255), Color3.fromHSV(hue, 1, 1))
				local ValBar, ValKnob = makeBar(68, Color3.fromHSV(hue, sat, 1),
					Color3.fromRGB(0,0,0), Color3.fromRGB(255,255,255))

				local function apply()
					local c = Color3.fromHSV(hue, sat, val)
					Swatch.BackgroundColor3 = c
					SatBar.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
					SatBar.UIGradient.Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromHSV(hue, 1, 1))
					ValBar.BackgroundColor3 = Color3.fromHSV(hue, sat, 1)
					pcall(callback, c)
				end

				local function makeDrag(bar, knob, setter)
					local dragging = false
					bar.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
					end)
					UserInputService.InputChanged:Connect(function(input)
						if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
							local rel = math.clamp((Mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
							knob.Position = UDim2.new(rel, 0, 0.5, 0)
							setter(rel); apply()
						end
					end)
					UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
					end)
				end
				makeDrag(HueBar, HueKnob, function(r) hue = r end)
				makeDrag(SatBar, SatKnob, function(r) sat = r end)
				makeDrag(ValBar, ValKnob, function(r) val = r end)
			end

			return Elements
		end

		return Sections
	end

	return Tabs
end

return Frog
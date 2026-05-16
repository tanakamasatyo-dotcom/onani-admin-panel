-- ================================================================
--  Onani Admin Panel v4.0
--  LocalScript → StarterPlayerScripts に配置
--  ] キーで開閉 | F2 でFreecam終了
-- ================================================================

local Players  = game:GetService("Players")
local UIS      = game:GetService("UserInputService")
local RS       = game:GetService("RunService")
local TS       = game:GetService("TweenService")
local WS       = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local SG       = game:GetService("StarterGui")
local Stats    = game:GetService("Stats")
local Debris   = game:GetService("Debris")

local LP    = Players.LocalPlayer
local PGui  = LP:WaitForChild("PlayerGui")
local Mouse = LP:GetMouse()
local Cam   = WS.CurrentCamera

-- ================================================================
-- ユーティリティ
-- ================================================================
local function Notify(title, body, dur)
    pcall(function()
        SG:SetCore("SendNotification",{
            Title=tostring(title), Text=tostring(body), Duration=dur or 3
        })
    end)
end

local function TW(obj, props, t, sty, dir)
    TS:Create(obj, TweenInfo.new(
        t or 0.2,
        sty or Enum.EasingStyle.Quart,
        dir or Enum.EasingDirection.Out
    ), props):Play()
end

local function New(cls, props, parent)
    local o = Instance.new(cls)
    for k,v in pairs(props or {}) do
        pcall(function() o[k] = v end)
    end
    if parent then o.Parent = parent end
    return o
end

local function GetHum()  return LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") end
local function GetHRP()  return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") end
local function GetChar() return LP.Character end

local function FindPlayer(q)
    q = q:lower()
    for _,pl in pairs(Players:GetPlayers()) do
        if pl.Name:lower():find(q,1,true) then return pl end
    end
end

-- ================================================================
-- カラーパレット
-- ================================================================
local C = {
    bg      = Color3.fromRGB(11,11,17),
    sidebar = Color3.fromRGB(15,16,24),
    panel   = Color3.fromRGB(20,21,32),
    tbar    = Color3.fromRGB(16,17,26),
    accent  = Color3.fromRGB(82,136,255),
    green   = Color3.fromRGB(45,195,115),
    red     = Color3.fromRGB(212,52,52),
    yellow  = Color3.fromRGB(212,155,28),
    purple  = Color3.fromRGB(160,90,255),
    text    = Color3.fromRGB(215,218,242),
    sub     = Color3.fromRGB(100,105,140),
    border  = Color3.fromRGB(35,40,68),
    input   = Color3.fromRGB(14,15,22),
}

-- ================================================================
-- GUI ルート
-- ================================================================
pcall(function()
    local old = PGui:FindFirstChild("OAP4")
    if old then old:Destroy() end
end)

local Root = New("ScreenGui", {
    Name = "OAP4",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PGui)

local WIN_W  = 680
local WIN_H  = 500
local TBAR_H = 36
local SIDE_W = 145
local CMD_H  = 36

-- メインウィンドウ
local Main = New("Frame", {
    Name = "Main",
    Size = UDim2.new(0,WIN_W,0,WIN_H),
    Position = UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Visible = false,
}, Root)
New("UICorner", {CornerRadius=UDim.new(0,9)}, Main)
New("UIStroke", {Color=C.border, Thickness=1.2}, Main)

-- 影エフェクト（外側フレーム）
local Shadow = New("Frame", {
    Size = UDim2.new(1,16,1,16),
    Position = UDim2.new(0,-8,0,-8),
    BackgroundColor3 = Color3.fromRGB(0,0,0),
    BackgroundTransparency = 0.6,
    BorderSizePixel = 0,
    ZIndex = 0,
}, Main)
New("UICorner", {CornerRadius=UDim.new(0,14)}, Shadow)

-- ================================================================
-- タイトルバー
-- ================================================================
local TBar = New("Frame", {
    Size = UDim2.new(1,0,0,TBAR_H),
    BackgroundColor3 = C.tbar,
    BorderSizePixel = 0,
    ZIndex = 10,
}, Main)
New("UICorner", {CornerRadius=UDim.new(0,9)}, TBar)

-- タイトル
New("TextLabel", {
    Size = UDim2.new(1,-120,1,0),
    Position = UDim2.new(0,12,0,0),
    BackgroundTransparency = 1,
    Text = "Onani Admin Panel  v4.0",
    TextColor3 = C.accent,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 11,
}, TBar)

-- ウィンドウボタン
local function MakeWinBtn(xOffset, col, lbl)
    local b = New("TextButton", {
        Size = UDim2.new(0,16,0,16),
        Position = UDim2.new(1,-xOffset,0.5,-8),
        BackgroundColor3 = col,
        BorderSizePixel = 0,
        Text = "",
        ZIndex = 12,
        AutoButtonColor = false,
    }, TBar)
    New("UICorner", {CornerRadius=UDim.new(1,0)}, b)
    local hovered = false
    local lblObj = New("TextLabel", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Text = lbl,
        TextColor3 = Color3.fromRGB(50,50,50),
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        Transparency = 1,
        ZIndex = 13,
    }, b)
    b.MouseEnter:Connect(function()
        TW(b, {BackgroundColor3=col:Lerp(Color3.new(1,1,1),0.2)}, 0.1)
        lblObj.Visible = true
    end)
    b.MouseLeave:Connect(function()
        TW(b, {BackgroundColor3=col}, 0.1)
        lblObj.Visible = false
    end)
    return b
end

local BtnClose = MakeWinBtn(28, Color3.fromRGB(218,58,58), "×")
local BtnMin   = MakeWinBtn(52, Color3.fromRGB(218,165,28), "−")
local BtnMax   = MakeWinBtn(76, Color3.fromRGB(45,188,88), "+")

-- ================================================================
-- サイドバー
-- ================================================================
local Sidebar = New("Frame", {
    Size = UDim2.new(0,SIDE_W,1,-TBAR_H),
    Position = UDim2.new(0,0,0,TBAR_H),
    BackgroundColor3 = C.sidebar,
    BorderSizePixel = 0,
    ZIndex = 6,
}, Main)

-- サイドバー下部にバージョン表示
New("TextLabel", {
    Size = UDim2.new(1,0,0,20),
    Position = UDim2.new(0,0,1,-22),
    BackgroundTransparency = 1,
    Text = "v4.0  |  OAP",
    TextColor3 = C.sub,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    ZIndex = 7,
}, Sidebar)

New("UIListLayout", {Padding=UDim.new(0,2), SortOrder=Enum.SortOrder.LayoutOrder}, Sidebar)
New("UIPadding", {
    PaddingTop=UDim.new(0,8),
    PaddingLeft=UDim.new(0,5),
    PaddingRight=UDim.new(0,5),
}, Sidebar)

-- 区切り線
New("Frame", {
    Size = UDim2.new(0,1,1,-TBAR_H),
    Position = UDim2.new(0,SIDE_W,0,TBAR_H),
    BackgroundColor3 = C.border,
    BorderSizePixel = 0,
    ZIndex = 7,
}, Main)

-- ================================================================
-- コンテンツエリア
-- ================================================================
local Content = New("Frame", {
    Size = UDim2.new(1,-SIDE_W,1,-TBAR_H-CMD_H),
    Position = UDim2.new(0,SIDE_W,0,TBAR_H),
    BackgroundTransparency = 1,
    ZIndex = 5,
}, Main)

-- ================================================================
-- コマンドバー
-- ================================================================
local CmdBar = New("Frame", {
    Size = UDim2.new(1,-SIDE_W,0,CMD_H),
    Position = UDim2.new(0,SIDE_W,1,-CMD_H),
    BackgroundColor3 = C.input,
    BorderSizePixel = 0,
    ZIndex = 9,
}, Main)
New("UIStroke", {Color=C.border, Thickness=1}, CmdBar)

New("TextLabel", {
    Size = UDim2.new(0,20,1,0),
    BackgroundTransparency = 1,
    Text = ">_",
    TextColor3 = C.accent,
    TextSize = 13,
    Font = Enum.Font.Code,
    ZIndex = 10,
}, CmdBar)

local CmdIn = New("TextBox", {
    Size = UDim2.new(1,-80,1,0),
    Position = UDim2.new(0,22,0,0),
    BackgroundTransparency = 1,
    PlaceholderText = "コマンド入力...  (help で一覧)",
    PlaceholderColor3 = C.sub,
    Text = "",
    TextColor3 = C.text,
    TextSize = 13,
    Font = Enum.Font.Code,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    ZIndex = 10,
}, CmdBar)

local ExecBtn = New("TextButton", {
    Size = UDim2.new(0,68,1,-6),
    Position = UDim2.new(1,-72,0,3),
    BackgroundColor3 = C.accent,
    BorderSizePixel = 0,
    Text = "EXEC",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    ZIndex = 10,
}, CmdBar)
New("UICorner", {CornerRadius=UDim.new(0,5)}, ExecBtn)
ExecBtn.MouseEnter:Connect(function() TW(ExecBtn,{BackgroundColor3=C.accent:Lerp(Color3.new(1,1,1),0.18)},0.1) end)
ExecBtn.MouseLeave:Connect(function() TW(ExecBtn,{BackgroundColor3=C.accent},0.1) end)

-- ================================================================
-- ページシステム
-- ================================================================
local Pages = {}
local function MakePage(name)
    local p = New("ScrollingFrame", {
        Name = name,
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.accent,
        ScrollBarImageTransparency = 0.4,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 6,
    }, Content)
    New("UIListLayout", {Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder}, p)
    New("UIPadding", {
        PaddingTop=UDim.new(0,10),
        PaddingLeft=UDim.new(0,10),
        PaddingRight=UDim.new(0,12),
        PaddingBottom=UDim.new(0,10),
    }, p)
    Pages[name] = p
    return p
end

local function ShowPage(name)
    for n,pg in pairs(Pages) do pg.Visible = (n==name) end
end

-- ================================================================
-- ウィジェット
-- ================================================================
local function Sec(parent, label)
    local f = New("Frame", {
        Size=UDim2.new(1,0,0,22),
        BackgroundTransparency=1,
        ZIndex=6,
    }, parent)
    New("TextLabel", {
        Size=UDim2.new(1,0,1,-6),
        BackgroundTransparency=1,
        Text=label:upper(),
        TextColor3=C.accent,
        TextSize=10,
        Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=7,
    }, f)
    New("Frame", {
        Size=UDim2.new(1,0,0,1),
        Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=C.border,
        BorderSizePixel=0,
        ZIndex=6,
    }, f)
end

local function Btn(parent, label, col, cb)
    col = col or C.accent
    local b = New("TextButton", {
        Size=UDim2.new(1,0,0,30),
        BackgroundColor3=col,
        BorderSizePixel=0,
        Text=label,
        TextColor3=Color3.fromRGB(240,242,255),
        TextSize=12,
        Font=Enum.Font.GothamSemibold,
        AutoButtonColor=false,
        ZIndex=7,
    }, parent)
    New("UICorner", {CornerRadius=UDim.new(0,5)}, b)
    b.MouseEnter:Connect(function() TW(b,{BackgroundColor3=col:Lerp(Color3.new(1,1,1),0.14)},0.1) end)
    b.MouseLeave:Connect(function() TW(b,{BackgroundColor3=col},0.1) end)
    b.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
    return b
end

local function Toggle(parent, label, default, cb)
    local state = default or false
    local row = New("Frame", {
        Size=UDim2.new(1,0,0,30),
        BackgroundColor3=C.panel,
        BorderSizePixel=0,
        ZIndex=6,
    }, parent)
    New("UICorner", {CornerRadius=UDim.new(0,5)}, row)
    New("TextLabel", {
        Size=UDim2.new(1,-52,1,0),
        Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1,
        Text=label,
        TextColor3=C.text,
        TextSize=12,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=7,
    }, row)
    local trk = New("Frame", {
        Size=UDim2.new(0,38,0,18),
        Position=UDim2.new(1,-44,0.5,-9),
        BackgroundColor3=state and C.green or C.sub,
        BorderSizePixel=0, ZIndex=7,
    }, row)
    New("UICorner", {CornerRadius=UDim.new(1,0)}, trk)
    local knob = New("Frame", {
        Size=UDim2.new(0,14,0,14),
        Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),
        BackgroundColor3=Color3.fromRGB(255,255,255),
        BorderSizePixel=0, ZIndex=8,
    }, trk)
    New("UICorner", {CornerRadius=UDim.new(1,0)}, knob)
    local function flip()
        state = not state
        TW(trk, {BackgroundColor3=state and C.green or C.sub}, 0.15)
        TW(knob, {Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}, 0.15)
        if cb then pcall(cb, state) end
    end
    row.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then flip() end
    end)
    return row
end

local function Slider(parent, label, mn, mx, def, cb)
    local val = math.clamp(def or mn, mn, mx)
    local drag = false
    local c = New("Frame", {
        Size=UDim2.new(1,0,0,46),
        BackgroundColor3=C.panel,
        BorderSizePixel=0, ZIndex=6,
    }, parent)
    New("UICorner", {CornerRadius=UDim.new(0,5)}, c)
    local lbl = New("TextLabel", {
        Size=UDim2.new(1,-60,0,18),
        Position=UDim2.new(0,10,0,4),
        BackgroundTransparency=1,
        Text=label,
        TextColor3=C.text, TextSize=11,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=7,
    }, c)
    local valLbl = New("TextLabel", {
        Size=UDim2.new(0,50,0,18),
        Position=UDim2.new(1,-56,0,4),
        BackgroundTransparency=1,
        Text=tostring(val),
        TextColor3=C.accent, TextSize=11,
        Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Right,
        ZIndex=7,
    }, c)
    local trk = New("Frame", {
        Size=UDim2.new(1,-20,0,4),
        Position=UDim2.new(0,10,1,-13),
        BackgroundColor3=Color3.fromRGB(35,38,58),
        BorderSizePixel=0, ZIndex=7,
    }, c)
    New("UICorner", {CornerRadius=UDim.new(1,0)}, trk)
    local fill = New("Frame", {
        Size=UDim2.new((val-mn)/(mx-mn),0,1,0),
        BackgroundColor3=C.accent,
        BorderSizePixel=0, ZIndex=8,
    }, trk)
    New("UICorner", {CornerRadius=UDim.new(1,0)}, fill)
    local knob = New("Frame", {
        Size=UDim2.new(0,12,0,12),
        Position=UDim2.new((val-mn)/(mx-mn),0,0.5,-6),
        BackgroundColor3=Color3.fromRGB(228,232,255),
        BorderSizePixel=0, ZIndex=9,
    }, trk)
    New("UICorner", {CornerRadius=UDim.new(1,0)}, knob)
    local function upd(x)
        local r = math.clamp((x-trk.AbsolutePosition.X)/trk.AbsoluteSize.X,0,1)
        val = math.floor(mn+r*(mx-mn))
        valLbl.Text = tostring(val)
        fill.Size = UDim2.new(r,0,1,0)
        knob.Position = UDim2.new(r,0,0.5,-6)
        if cb then pcall(cb,val) end
    end
    trk.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; upd(i.Position.X) end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
    return c
end

-- 情報行
local function InfoRow(parent, key, value)
    local row = New("Frame", {
        Size=UDim2.new(1,0,0,26),
        BackgroundColor3=C.panel,
        BorderSizePixel=0, ZIndex=6,
    }, parent)
    New("UICorner", {CornerRadius=UDim.new(0,5)}, row)
    New("TextLabel", {
        Size=UDim2.new(0.42,0,1,0),
        Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1,
        Text=key,
        TextColor3=C.sub, TextSize=11,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=7,
    }, row)
    local valLbl = New("TextLabel", {
        Size=UDim2.new(0.58,-10,1,0),
        Position=UDim2.new(0.42,0,0,0),
        BackgroundTransparency=1,
        Text=tostring(value),
        TextColor3=C.text, TextSize=11,
        Font=Enum.Font.GothamSemibold,
        TextXAlignment=Enum.TextXAlignment.Right,
        ZIndex=7,
    }, row)
    New("UIPadding", {PaddingRight=UDim.new(0,8)}, valLbl)
    return row, valLbl
end

-- ================================================================
-- タブ定義
-- ================================================================
local TABS = {
    {n="Server Info"},
    {n="Player"},
    {n="Movement"},
    {n="Freecam"},
    {n="World"},
    {n="Lighting"},
    {n="ESP"},
    {n="Character"},
    {n="Physics"},
    {n="Tools"},
}

local TabBtns = {}
local function SetTab(name)
    for _,t in pairs(TabBtns) do
        local a = (t.n == name)
        TW(t.b, {
            BackgroundColor3 = a and C.accent or C.panel,
            BackgroundTransparency = a and 0 or 0,
        }, 0.15)
        TW(t.lbl, {TextColor3 = a and Color3.fromRGB(255,255,255) or C.sub}, 0.15)
    end
    ShowPage(name)
end

for i,tab in ipairs(TABS) do
    MakePage(tab.n)
    local b = New("TextButton", {
        Size=UDim2.new(1,0,0,30),
        BackgroundColor3=C.panel,
        BackgroundTransparency=0,
        BorderSizePixel=0, Text="",
        LayoutOrder=i, ZIndex=7,
    }, Sidebar)
    New("UICorner", {CornerRadius=UDim.new(0,5)}, b)
    local lbl = New("TextLabel", {
        Size=UDim2.new(1,-10,1,0),
        Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1,
        Text=tab.n,
        TextColor3=C.sub, TextSize=12,
        Font=Enum.Font.GothamSemibold,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=8,
    }, b)
    b.MouseEnter:Connect(function()
        if lbl.TextColor3 ~= Color3.fromRGB(255,255,255) then
            TW(lbl,{TextColor3=C.text},0.1)
        end
    end)
    b.MouseLeave:Connect(function()
        if lbl.TextColor3 ~= Color3.fromRGB(255,255,255) then
            TW(lbl,{TextColor3=C.sub},0.1)
        end
    end)
    b.MouseButton1Click:Connect(function() SetTab(tab.n) end)
    table.insert(TabBtns,{b=b,lbl=lbl,n=tab.n})
end

-- ================================================================
-- PAGE: Server Info
-- ================================================================
do
    local pg = Pages["Server Info"]

    Sec(pg, "Server")
    local _, placeIdVal   = InfoRow(pg, "Place ID",       tostring(game.PlaceId))
    local _, jobIdVal     = InfoRow(pg, "Job ID",         game.JobId:sub(1,16).."...")
    local _, serverRegion = InfoRow(pg, "Region",         "取得中...")
    local _, startedVal   = InfoRow(pg, "Start Time",     os.date("%H:%M:%S", os.time()))
    local _, uptimeVal    = InfoRow(pg, "Uptime",         "0s")
    local startTime       = os.time()

    Sec(pg, "Network")
    local _, pingVal      = InfoRow(pg, "Ping",           "---  ms")
    local _, fpsVal       = InfoRow(pg, "Client FPS",     "---")
    local _, heapVal      = InfoRow(pg, "Memory (MB)",    "---")

    Sec(pg, "Players")
    local _, countVal     = InfoRow(pg, "Players",        #Players:GetPlayers().." / "..Players.MaxPlayers)
    local _, selfVal      = InfoRow(pg, "Your Name",      LP.Name)
    local _, selfIdVal    = InfoRow(pg, "Your UserID",    tostring(LP.UserId))
    local _, selfAgeVal   = InfoRow(pg, "Account Age",    LP.AccountAge.." days")
    local _, selfPosVal   = InfoRow(pg, "Your Position",  "---")

    -- プレイヤー一覧
    Sec(pg, "Player List")
    local plListFrame = New("Frame", {
        Size=UDim2.new(1,0,0,4),
        BackgroundColor3=C.panel,
        BorderSizePixel=0, ZIndex=6,
        AutomaticSize=Enum.AutomaticSize.Y,
    }, pg)
    New("UICorner", {CornerRadius=UDim.new(0,5)}, plListFrame)
    New("UIListLayout", {Padding=UDim.new(0,1), SortOrder=Enum.SortOrder.LayoutOrder}, plListFrame)
    New("UIPadding", {PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)}, plListFrame)

    local plLabels = {}

    local function RefreshPlayerList()
        for _,c in pairs(plListFrame:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
        plLabels = {}
        for _,pl in pairs(Players:GetPlayers()) do
            local lbl = New("TextLabel", {
                Size=UDim2.new(1,0,0,22),
                BackgroundTransparency=1,
                Text=string.format("%-20s  ID:%-12s  %s days",
                    pl.Name, tostring(pl.UserId), tostring(pl.AccountAge)),
                TextColor3=(pl==LP) and C.accent or C.text,
                TextSize=11,
                Font=Enum.Font.Code,
                TextXAlignment=Enum.TextXAlignment.Left,
                ZIndex=7,
            }, plListFrame)
            table.insert(plLabels, lbl)
        end
        countVal.Text = #Players:GetPlayers().." / "..Players.MaxPlayers
    end

    RefreshPlayerList()
    Players.PlayerAdded:Connect(RefreshPlayerList)
    Players.PlayerRemoving:Connect(function()
        task.defer(RefreshPlayerList)
    end)

    Btn(pg, "Refresh List", C.accent, RefreshPlayerList)

    -- リアルタイム更新
    RS.Heartbeat:Connect(function()
        -- Uptime
        local up = math.floor(os.time()-startTime)
        uptimeVal.Text = string.format("%dh %dm %ds",
            math.floor(up/3600), math.floor((up%3600)/60), up%60)

        -- FPS
        fpsVal.Text = math.floor(1/RS.RenderStepped:Wait()).."  fps" -- approx

        -- Memory
        pcall(function()
            heapVal.Text = string.format("%.1f MB", Stats:GetTotalMemoryUsageMb())
        end)

        -- Ping
        pcall(function()
            pingVal.Text = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()).."  ms"
        end)

        -- Position
        local hrp = GetHRP()
        if hrp then
            local p = hrp.Position
            selfPosVal.Text = string.format("%.0f, %.0f, %.0f", p.X, p.Y, p.Z)
        end
    end)
end

-- ================================================================
-- PAGE: Player
-- ================================================================
do
    local pg = Pages["Player"]

    Sec(pg, "HP")
    Slider(pg, "MaxHealth", 1, 2000, 100, function(v)
        local h=GetHum(); if h then h.MaxHealth=v; h.Health=v end
    end)
    Btn(pg, "Full Heal",       C.green, function()
        local h=GetHum(); if h then h.Health=h.MaxHealth; Notify("Heal","全回復") end end)
    Btn(pg, "HP = 1",         C.yellow, function()
        local h=GetHum(); if h then h.Health=1; Notify("HP","1にセット") end end)
    Btn(pg, "Instant Kill",    C.red,   function()
        local h=GetHum(); if h then h.Health=0 end end)

    Sec(pg, "Respawn")
    Btn(pg, "Respawn",         C.accent, function() LP:LoadCharacter(); Notify("Respawn","リスポーン") end)
    Btn(pg, "Break Joints",    C.red,    function()
        local c=GetChar(); if c then c:BreakJoints(); Notify("Ragdoll","ジョイント破壊") end end)

    Sec(pg, "Info")
    Btn(pg, "Show Position",   C.panel, function()
        local hrp=GetHRP(); if hrp then
            local p=hrp.Position
            Notify("Position",("X:%.1f  Y:%.1f  Z:%.1f"):format(p.X,p.Y,p.Z),5)
        end
    end)
    Btn(pg, "Show Account Info", C.panel, function()
        Notify("Account",LP.Name.." | ID:"..LP.UserId.." | "..LP.AccountAge.." days",6)
    end)
    Btn(pg, "Show Player List", C.panel, function()
        local t={}
        for _,p in pairs(Players:GetPlayers()) do table.insert(t,p.Name) end
        Notify("Players",table.concat(t,", "),6)
    end)
    Btn(pg, "Game Time", C.panel, function()
        local t=math.floor(WS.DistributedGameTime)
        Notify("GameTime",("%dm %ds"):format(math.floor(t/60),t%60),4)
    end)
end

-- ================================================================
-- PAGE: Movement
-- ================================================================
do
    local pg = Pages["Movement"]

    Sec(pg, "Speed / Jump")
    Slider(pg, "WalkSpeed", 1, 500, 16, function(v)
        local h=GetHum(); if h then h.WalkSpeed=v end end)
    Slider(pg, "JumpPower", 1, 500, 50, function(v)
        local h=GetHum(); if h then h.JumpPower=v end end)
    Btn(pg, "Reset (16 / 50)", Color3.fromRGB(60,62,92), function()
        local h=GetHum()
        if h then h.WalkSpeed=16; h.JumpPower=50; Notify("Reset","速度リセット") end
    end)

    Sec(pg, "Fly")
    local flyOn=false; local flyBV,flyBG,flyHB
    Toggle(pg, "Fly Mode", false, function(s)
        flyOn=s
        if flyHB  then flyHB:Disconnect();  flyHB=nil  end
        if flyBV  then flyBV:Destroy();     flyBV=nil  end
        if flyBG  then flyBG:Destroy();     flyBG=nil  end
        if not s  then Notify("Fly","OFF"); return     end
        local hrp=GetHRP(); if not hrp then return end
        flyBV=New("BodyVelocity",{Velocity=Vector3.zero,MaxForce=Vector3.new(1e5,1e5,1e5),Name="_FlyBV"},hrp)
        flyBG=New("BodyGyro",{MaxTorque=Vector3.new(1e5,1e5,1e5),D=100,Name="_FlyBG"},hrp)
        flyHB=RS.Heartbeat:Connect(function()
            if not flyOn then return end
            local h2=GetHRP(); if not h2 then return end
            local d=Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+Cam.CFrame.LookVector  end
            if UIS:IsKeyDown(Enum.KeyCode.S) then d=d-Cam.CFrame.LookVector  end
            if UIS:IsKeyDown(Enum.KeyCode.A) then d=d-Cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then d=d+Cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space)       then d=d+Vector3.new(0,1,0)  end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d=d-Vector3.new(0,1,0)  end
            local spd = UIS:IsKeyDown(Enum.KeyCode.LeftShift) and 220 or 85
            flyBV.Velocity = d*spd
            flyBG.CFrame   = Cam.CFrame
        end)
        Notify("Fly","ON  |  Shift=高速  Ctrl=下降")
    end)

    Sec(pg, "Noclip")
    local ncOn=false; local ncHB
    Toggle(pg, "Noclip", false, function(s)
        ncOn=s
        if ncHB then ncHB:Disconnect(); ncHB=nil end
        if s then
            ncHB=RS.Stepped:Connect(function()
                local c=GetChar(); if not c then return end
                for _,v in pairs(c:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide=false end
                end
            end)
        else
            local c=GetChar()
            if c then
                for _,v in pairs(c:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide=true end
                end
            end
        end
        Notify("Noclip", s and "ON" or "OFF")
    end)

    Sec(pg, "Teleport")
    Btn(pg, "TP to Mouse Cursor",    C.accent, function()
        local hrp=GetHRP()
        if hrp then
            hrp.CFrame=CFrame.new(Mouse.Hit.Position+Vector3.new(0,3,0))
            Notify("TP","マウス位置にTP")
        end
    end)
    Btn(pg, "TP to Origin (0,5,0)", Color3.fromRGB(55,60,100), function()
        local hrp=GetHRP(); if hrp then hrp.CFrame=CFrame.new(0,5,0); Notify("TP","原点") end end)
    Btn(pg, "TP Up +300",           Color3.fromRGB(55,60,100), function()
        local hrp=GetHRP()
        if hrp then hrp.CFrame=CFrame.new(hrp.Position+Vector3.new(0,300,0)); Notify("TP","上空") end end)
    Btn(pg, "Dash Forward  (50st)", Color3.fromRGB(55,80,130), function()
        local hrp=GetHRP()
        if hrp then hrp.CFrame=hrp.CFrame*CFrame.new(0,0,-50); Notify("Dash","前方50") end end)

    Sec(pg, "Freeze")
    Btn(pg, "Freeze",   C.yellow, function()
        local h=GetHRP(); if h then h.Anchored=true;  Notify("Freeze","固定") end end)
    Btn(pg, "Unfreeze", C.green,  function()
        local h=GetHRP(); if h then h.Anchored=false; Notify("Unfreeze","解除") end end)
end

-- ================================================================
-- PAGE: Freecam
-- ================================================================
do
    local pg = Pages["Freecam"]
    local FC = {Active=false, Speed=60, Pitch=0, Yaw=0, CF=CFrame.new()}
    local fcConn, fcOrigCT

    local function StartFC()
        if FC.Active then return end
        FC.Active = true
        fcOrigCT  = Cam.CameraType
        Cam.CameraType = Enum.CameraType.Scriptable
        FC.CF    = Cam.CFrame
        FC.Pitch = 0; FC.Yaw = 0
        UIS.MouseBehavior = Enum.MouseBehavior.LockCenter

        fcConn = RS.RenderStepped:Connect(function(dt)
            if not FC.Active then return end
            local delta = UIS:GetMouseDelta()
            FC.Yaw   = FC.Yaw   - delta.X*0.3
            FC.Pitch = math.clamp(FC.Pitch - delta.Y*0.3, -89, 89)
            local rot = CFrame.Angles(0,math.rad(FC.Yaw),0)*CFrame.Angles(math.rad(FC.Pitch),0,0)
            local mv  = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then mv=mv+Vector3.new(0,0,-1) end
            if UIS:IsKeyDown(Enum.KeyCode.S) then mv=mv+Vector3.new(0,0,1)  end
            if UIS:IsKeyDown(Enum.KeyCode.A) then mv=mv+Vector3.new(-1,0,0) end
            if UIS:IsKeyDown(Enum.KeyCode.D) then mv=mv+Vector3.new(1,0,0)  end
            if UIS:IsKeyDown(Enum.KeyCode.Space)       then mv=mv+Vector3.new(0,1,0)  end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv=mv-Vector3.new(0,1,0)  end
            local spd = FC.Speed
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then spd=spd*3  end
            if UIS:IsKeyDown(Enum.KeyCode.Q)         then spd=spd*0.2 end
            FC.CF = FC.CF * CFrame.new(mv*spd*dt)
            Cam.CFrame = CFrame.new(FC.CF.Position)*rot
        end)
        Notify("Freecam","ON  |  WASD移動  Shift=高速  Q=低速  F2=終了")
    end

    local function StopFC()
        if not FC.Active then return end
        FC.Active = false
        if fcConn then fcConn:Disconnect(); fcConn=nil end
        UIS.MouseBehavior   = Enum.MouseBehavior.Default
        Cam.CameraType      = fcOrigCT or Enum.CameraType.Custom
        Notify("Freecam","OFF")
    end

    UIS.InputBegan:Connect(function(i,gp)
        if not gp and i.KeyCode==Enum.KeyCode.F2 and FC.Active then StopFC() end
    end)

    Sec(pg, "Control")
    Btn(pg, "Start Freecam",    C.green,  StartFC)
    Btn(pg, "Stop Freecam  [F2]", C.red,  StopFC)
    Slider(pg, "Move Speed", 5, 800, 60, function(v) FC.Speed=v end)

    Sec(pg, "Camera Presets")
    Btn(pg, "Top View (Y+500)", Color3.fromRGB(55,65,120), function()
        local hrp=GetHRP(); local pos=hrp and hrp.Position or Vector3.zero
        FC.CF=CFrame.new(pos+Vector3.new(0,500,0)); FC.Pitch=-89; FC.Yaw=0
        if not FC.Active then StartFC() end
        Notify("Freecam","トップビュー")
    end)
    Btn(pg, "Behind Character", Color3.fromRGB(55,65,120), function()
        local hrp=GetHRP()
        if hrp then FC.CF=hrp.CFrame*CFrame.new(0,4,-14); if not FC.Active then StartFC() end end
    end)
    Btn(pg, "Front Character",  Color3.fromRGB(55,65,120), function()
        local hrp=GetHRP()
        if hrp then FC.CF=hrp.CFrame*CFrame.new(0,4,14)*CFrame.Angles(0,math.pi,0); if not FC.Active then StartFC() end end
    end)

    Sec(pg, "FOV / Camera")
    Slider(pg, "Field of View", 10, 130, 70, function(v) Cam.FieldOfView=v end)
    Toggle(pg, "First Person Lock", false, function(s)
        LP.CameraMode = s and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
        Notify("Camera", s and "1人称" or "通常")
    end)
    Btn(pg, "Reset Camera", Color3.fromRGB(70,55,55), function()
        StopFC(); Cam.CameraType=Enum.CameraType.Custom; Cam.FieldOfView=70; Notify("Camera","リセット")
    end)
end

-- ================================================================
-- PAGE: World
-- ================================================================
do
    local pg = Pages["World"]

    Sec(pg, "Gravity / Time")
    Slider(pg, "Gravity",         0, 400, 196, function(v) WS.Gravity=v           end)
    Slider(pg, "ClockTime (0-24)",0, 24,  14,  function(v) Lighting.ClockTime=v   end)

    Sec(pg, "Weather")
    Btn(pg, "Rain",   Color3.fromRGB(48,80,165), function()
        if WS:FindFirstChild("_OAP_Rain") then return end
        local pt=New("Part",{Name="_OAP_Rain",Anchored=true,CanCollide=false,
            Size=Vector3.new(600,1,600),Transparency=1,CFrame=CFrame.new(0,120,0)},WS)
        New("ParticleEmitter",{Texture="rbxassetid://6101261690",Rate=1500,
            Speed=NumberRange.new(80,100),Lifetime=NumberRange.new(1,2),
            Size=NumberSequence.new{NumberSequenceKeypoint.new(0,0.04),NumberSequenceKeypoint.new(1,0.04)},
            Direction=Vector3.new(0,-1,0),SpreadAngle=Vector2.new(0,0)},pt)
        Notify("Weather","Rain ON")
    end)
    Btn(pg, "Snow",   Color3.fromRGB(135,175,218), function()
        if WS:FindFirstChild("_OAP_Snow") then return end
        local pt=New("Part",{Name="_OAP_Snow",Anchored=true,CanCollide=false,
            Size=Vector3.new(600,1,600),Transparency=1,CFrame=CFrame.new(0,120,0)},WS)
        New("ParticleEmitter",{Texture="rbxassetid://1095708795",Rate=450,
            Speed=NumberRange.new(6,18),Lifetime=NumberRange.new(4,7),
            Size=NumberSequence.new{NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(1,0.08)},
            Direction=Vector3.new(0,-1,0),SpreadAngle=Vector2.new(22,22),RotSpeed=NumberRange.new(-55,55)},pt)
        Notify("Weather","Snow ON")
    end)
    Btn(pg, "Clear Weather", Color3.fromRGB(85,65,45), function()
        for _,n in pairs({"_OAP_Rain","_OAP_Snow"}) do
            local v=WS:FindFirstChild(n); if v then v:Destroy() end
        end
        Notify("Weather","Clear")
    end)
    Toggle(pg, "Fog", false, function(s)
        Lighting.FogEnd=s and 180 or 100000; Lighting.FogStart=0
        Lighting.FogColor=Color3.fromRGB(185,195,210)
        Notify("Fog", s and "ON" or "OFF")
    end)
    Slider(pg, "Fog Distance", 10, 2000, 180, function(v) Lighting.FogEnd=v end)

    Sec(pg, "Reset")
    Btn(pg, "Reset World", Color3.fromRGB(92,42,42), function()
        WS.Gravity=196; Lighting.ClockTime=14; Lighting.Brightness=2; Lighting.FogEnd=100000
        Lighting.Ambient=Color3.fromRGB(70,70,70)
        for _,n in pairs({"_OAP_Rain","_OAP_Snow"}) do local v=WS:FindFirstChild(n); if v then v:Destroy() end end
        Notify("Reset","ワールド初期化")
    end)
end

-- ================================================================
-- PAGE: Lighting
-- ================================================================
do
    local pg = Pages["Lighting"]

    Sec(pg, "Brightness")
    Slider(pg, "Brightness", 0, 10, 2, function(v) Lighting.Brightness=v end)

    Sec(pg, "Presets")
    Btn(pg, "Day",    Color3.fromRGB(55,125,205), function()
        Lighting.ClockTime=12; Lighting.Brightness=3
        Lighting.Ambient=Color3.fromRGB(115,115,115); Notify("Lighting","Day") end)
    Btn(pg, "Sunset", Color3.fromRGB(190,92,32), function()
        Lighting.ClockTime=18.5; Lighting.Ambient=Color3.fromRGB(255,125,45)
        Lighting.OutdoorAmbient=Color3.fromRGB(215,85,25); Notify("Lighting","Sunset") end)
    Btn(pg, "Night",  Color3.fromRGB(16,16,62), function()
        Lighting.ClockTime=0; Lighting.Ambient=Color3.fromRGB(8,8,22)
        Lighting.OutdoorAmbient=Color3.fromRGB(5,5,14); Notify("Lighting","Night") end)
    Btn(pg, "Dawn",   Color3.fromRGB(135,88,145), function()
        Lighting.ClockTime=5.5; Lighting.Ambient=Color3.fromRGB(175,138,198)
        Lighting.OutdoorAmbient=Color3.fromRGB(198,158,218); Notify("Lighting","Dawn") end)
    Btn(pg, "Midnight Horror", Color3.fromRGB(10,8,30), function()
        Lighting.ClockTime=0; Lighting.Ambient=Color3.fromRGB(2,2,8)
        Lighting.OutdoorAmbient=Color3.fromRGB(0,0,5); Lighting.Brightness=0
        Notify("Lighting","Midnight Horror") end)

    Sec(pg, "Post FX")
    Toggle(pg, "Bloom",             false, function(s)
        local e=Lighting:FindFirstChildOfClass("BloomEffect")
        if s and not e then New("BloomEffect",{Intensity=0.9,Size=24,Threshold=1,Parent=Lighting})
        elseif not s and e then e:Destroy() end; Notify("Bloom",s and "ON" or "OFF") end)
    Toggle(pg, "Blur",              false, function(s)
        local e=Lighting:FindFirstChildOfClass("BlurEffect")
        if s and not e then New("BlurEffect",{Size=16,Parent=Lighting})
        elseif not s and e then e:Destroy() end; Notify("Blur",s and "ON" or "OFF") end)
    Toggle(pg, "Sun Rays",          false, function(s)
        local e=Lighting:FindFirstChildOfClass("SunRaysEffect")
        if s and not e then New("SunRaysEffect",{Intensity=0.25,Spread=0.5,Parent=Lighting})
        elseif not s and e then e:Destroy() end; Notify("SunRays",s and "ON" or "OFF") end)
    Toggle(pg, "Depth of Field",    false, function(s)
        local e=Lighting:FindFirstChildOfClass("DepthOfFieldEffect")
        if s and not e then New("DepthOfFieldEffect",{FarIntensity=0.8,FocusDistance=50,InFocusRadius=10,NearIntensity=0.6,Parent=Lighting})
        elseif not s and e then e:Destroy() end; Notify("DoF",s and "ON" or "OFF") end)
    Toggle(pg, "Color Correction",  false, function(s)
        local e=Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
        if s and not e then New("ColorCorrectionEffect",{Saturation=0.25,TintColor=Color3.fromRGB(200,215,255),Parent=Lighting})
        elseif not s and e then e:Destroy() end; Notify("ColorCorrection",s and "ON" or "OFF") end)
end

-- ================================================================
-- PAGE: ESP
-- ================================================================
do
    local pg = Pages["ESP"]

    -- 共通データ
    local espData   = {}   -- {player: {box, nameTag, distTag, healthBar, teamBox}}
    local espFlags  = {box=false, name=false, dist=false, health=false, chams=false, tracer=false}
    local tracerConns = {}

    local function ESPColor(pl)
        if pl.Team then return pl.TeamColor.Color end
        return Color3.fromRGB(255,60,60)
    end

    local function RemoveESP(pl)
        if not espData[pl] then return end
        for _,v in pairs(espData[pl]) do
            pcall(function() v:Destroy() end)
        end
        espData[pl] = nil
    end

    local function RebuildESP(pl)
        if pl == LP then return end
        RemoveESP(pl)
        if not pl.Character then return end
        local char = pl.Character
        local head = char:FindFirstChild("Head")
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not head or not hrp then return end

        local col = ESPColor(pl)
        espData[pl] = {}

        -- BOX ESP
        if espFlags.box then
            local sel = Instance.new("SelectionBox")
            sel.Color3               = col
            sel.LineThickness        = 0.04
            sel.SurfaceColor3        = col
            sel.SurfaceTransparency  = 0.88
            sel.Adornee              = char
            sel.Parent               = PGui
            espData[pl].box          = sel
        end

        -- NAME TAG
        if espFlags.name then
            local bb = New("BillboardGui",{Name="_OAP_Name",Adornee=head,
                Size=UDim2.new(0,130,0,32),StudsOffset=Vector3.new(0,3.2,0),
                AlwaysOnTop=true,Parent=head})
            New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                Text=pl.Name,TextColor3=col,TextStrokeTransparency=0,
                Font=Enum.Font.GothamBold,TextScaled=true,Parent=bb})
            espData[pl].nameTag = bb
        end

        -- DISTANCE TAG
        if espFlags.dist then
            local bb = New("BillboardGui",{Name="_OAP_Dist",Adornee=head,
                Size=UDim2.new(0,80,0,20),StudsOffset=Vector3.new(0,1.4,0),
                AlwaysOnTop=true,Parent=head})
            local lbl = New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                TextColor3=Color3.fromRGB(255,220,50),TextStrokeTransparency=0,
                Font=Enum.Font.GothamBold,TextScaled=true,Parent=bb})
            espData[pl].distTag = {bb=bb, lbl=lbl}
        end

        -- HEALTH BAR
        if espFlags.health then
            local bb = New("BillboardGui",{Name="_OAP_HP",Adornee=hrp,
                Size=UDim2.new(0,6,0,50),StudsOffset=Vector3.new(-2.8,0,0),
                AlwaysOnTop=true,Parent=hrp})
            local bg = New("Frame",{Size=UDim2.new(1,0,1,0),
                BackgroundColor3=Color3.fromRGB(30,30,30),BorderSizePixel=0,Parent=bb})
            New("UICorner",{CornerRadius=UDim.new(0,2)},bg)
            local bar = New("Frame",{Size=UDim2.new(1,0,1,0),
                BackgroundColor3=Color3.fromRGB(60,220,80),BorderSizePixel=0,
                AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Parent=bg})
            New("UICorner",{CornerRadius=UDim.new(0,2)},bar)
            espData[pl].hpBar = {bb=bb, bar=bar, hum=hum}
        end

        -- CHAMS (solid highlight)
        if espFlags.chams then
            local hl = Instance.new("SelectionBox")
            hl.Color3              = col
            hl.LineThickness       = 0
            hl.SurfaceColor3       = col
            hl.SurfaceTransparency = 0.5
            hl.Adornee             = char
            hl.Parent              = PGui
            espData[pl].chams      = hl
        end

        -- TRACER LINE
        if espFlags.tracer then
            -- tracerは毎フレーム描画するので別管理
        end
    end

    -- ESPリビルド関数
    local function RebuildAll()
        for _,pl in pairs(Players:GetPlayers()) do RebuildESP(pl) end
    end

    -- プレイヤー接続
    Players.PlayerAdded:Connect(function(pl)
        pl.CharacterAdded:Connect(function() task.wait(0.5); RebuildESP(pl) end)
    end)
    Players.PlayerRemoving:Connect(function(pl) RemoveESP(pl) end)
    for _,pl in pairs(Players:GetPlayers()) do
        if pl ~= LP then
            pl.CharacterAdded:Connect(function() task.wait(0.5); RebuildESP(pl) end)
        end
    end

    -- 毎フレーム更新
    RS.Heartbeat:Connect(function()
        local myHRP = GetHRP()
        for pl,data in pairs(espData) do
            -- 距離更新
            if data.distTag and myHRP and pl.Character then
                local phrp = pl.Character:FindFirstChild("HumanoidRootPart")
                if phrp then
                    local dist = math.floor((myHRP.Position-phrp.Position).Magnitude)
                    data.distTag.lbl.Text = dist.."m"
                end
            end
            -- HPバー更新
            if data.hpBar and data.hpBar.hum then
                local h = data.hpBar.hum
                local ratio = math.clamp(h.Health/math.max(h.MaxHealth,1),0,1)
                data.hpBar.bar.Size = UDim2.new(1,0,ratio,0)
                local r = 1-ratio; local g = ratio
                data.hpBar.bar.BackgroundColor3 = Color3.fromRGB(r*220, g*220, 50*ratio)
            end
        end

        -- Tracer
        if espFlags.tracer and myHRP then
            for _,pl in pairs(Players:GetPlayers()) do
                if pl ~= LP and pl.Character then
                    local phrp = pl.Character:FindFirstChild("HumanoidRootPart")
                    if phrp then
                        -- ビームの代わりに BillboardGui+ImageLabel は重すぎるため
                        -- SelectionBox で代替（完全なラインはServerで要 Part）
                    end
                end
            end
        end
    end)

    Sec(pg, "Player ESP")
    Toggle(pg, "Box ESP",         false, function(s) espFlags.box=s;    RebuildAll(); Notify("Box ESP",s and "ON" or "OFF") end)
    Toggle(pg, "Name Tags",       false, function(s) espFlags.name=s;   RebuildAll(); Notify("Name Tags",s and "ON" or "OFF") end)
    Toggle(pg, "Distance Tags",   false, function(s) espFlags.dist=s;   RebuildAll(); Notify("Distance",s and "ON" or "OFF") end)
    Toggle(pg, "Health Bars",     false, function(s) espFlags.health=s; RebuildAll(); Notify("Health Bar",s and "ON" or "OFF") end)
    Toggle(pg, "Chams (Solid)",   false, function(s) espFlags.chams=s;  RebuildAll(); Notify("Chams",s and "ON" or "OFF") end)

    Sec(pg, "ESP Color Theme")
    Btn(pg, "Theme: Red   (default)", Color3.fromRGB(180,40,40), function()
        for pl,data in pairs(espData) do
            if data.box  then data.box.Color3=Color3.fromRGB(255,60,60); data.box.SurfaceColor3=Color3.fromRGB(255,60,60) end
            if data.chams then data.chams.Color3=Color3.fromRGB(255,60,60); data.chams.SurfaceColor3=Color3.fromRGB(255,60,60) end
        end; Notify("ESP Theme","Red")
    end)
    Btn(pg, "Theme: Cyan",           Color3.fromRGB(20,160,180), function()
        for pl,data in pairs(espData) do
            if data.box  then data.box.Color3=Color3.fromRGB(0,220,255); data.box.SurfaceColor3=Color3.fromRGB(0,220,255) end
            if data.chams then data.chams.Color3=Color3.fromRGB(0,220,255); data.chams.SurfaceColor3=Color3.fromRGB(0,220,255) end
        end; Notify("ESP Theme","Cyan")
    end)
    Btn(pg, "Theme: Team Color",     Color3.fromRGB(60,80,160), function()
        for pl,data in pairs(espData) do
            local col = ESPColor(pl)
            if data.box  then data.box.Color3=col;  data.box.SurfaceColor3=col  end
            if data.chams then data.chams.Color3=col; data.chams.SurfaceColor3=col end
        end; Notify("ESP Theme","Team Color")
    end)

    Sec(pg, "World ESP")
    Toggle(pg, "Highlight All Parts", false, function(s)
        if s then
            for _,v in pairs(WS:GetDescendants()) do
                if v:IsA("BasePart") and v.Name~="Terrain" and not v:FindFirstChildOfClass("SelectionBox") then
                    local sel=Instance.new("SelectionBox")
                    sel.Name="OAP_WorldESP"
                    sel.Color3=Color3.fromRGB(0,200,255)
                    sel.LineThickness=0.03
                    sel.SurfaceTransparency=0.95
                    sel.Adornee=v; sel.Parent=PGui
                end
            end
            Notify("World ESP","ON")
        else
            for _,v in pairs(PGui:GetChildren()) do
                if v.Name=="OAP_WorldESP" then v:Destroy() end
            end
            Notify("World ESP","OFF")
        end
    end)

    Sec(pg, "Clear")
    Btn(pg, "Clear All ESP", C.red, function()
        for _,flag in pairs(espFlags) do espFlags[_]=false end
        espFlags={box=false,name=false,dist=false,health=false,chams=false,tracer=false}
        for pl,_ in pairs(espData) do RemoveESP(pl) end
        for _,v in pairs(PGui:GetChildren()) do if v.Name=="OAP_WorldESP" then v:Destroy() end end
        Notify("ESP","全クリア")
    end)
end

-- ================================================================
-- PAGE: Character
-- ================================================================
do
    local pg = Pages["Character"]

    Sec(pg, "Scale")
    Slider(pg, "Head Scale",   0.1, 5, 1, function(v) local h=GetHum(); if h then h.HeadScale=v end end)
    Slider(pg, "Body Height",  0.3, 5, 1, function(v) local h=GetHum(); if h then h.BodyHeightScale=v end end)
    Slider(pg, "Body Width",   0.3, 5, 1, function(v) local h=GetHum(); if h then h.BodyWidthScale=v; h.BodyDepthScale=v end end)

    Sec(pg, "Body Color")
    local COLS={
        Red=BrickColor.new("Bright red"), Blue=BrickColor.new("Bright blue"),
        Green=BrickColor.new("Bright green"), Yellow=BrickColor.new("Bright yellow"),
        White=BrickColor.White(), Black=BrickColor.Black(),
        Pink=BrickColor.new("Hot pink"), Orange=BrickColor.new("Bright orange"),
        Purple=BrickColor.new("Medium lilac"), Cyan=BrickColor.new("Cyan"),
    }
    local colGrid = New("Frame",{
        Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1, ZIndex=6,
    },pg)
    New("UIGridLayout",{
        CellSize=UDim2.new(0.5,-3,0,28),
        CellPadding=UDim2.new(0,4,0,4),
        SortOrder=Enum.SortOrder.LayoutOrder,
    },colGrid)
    for name,col in pairs(COLS) do
        local b=New("TextButton",{
            BackgroundColor3=col.Color,BorderSizePixel=0,
            Text=name,TextColor3=Color3.fromRGB(255,255,255),
            TextSize=11,Font=Enum.Font.GothamBold,
            TextStrokeTransparency=0.5,AutoButtonColor=false,ZIndex=7,
        },colGrid)
        New("UICorner",{CornerRadius=UDim.new(0,4)},b)
        b.MouseButton1Click:Connect(function()
            local c=GetChar(); if c then
                for _,v in pairs(c:GetDescendants()) do
                    if v:IsA("BasePart") then v.BrickColor=col end
                end
                Notify("Color",name)
            end
        end)
    end
    Btn(pg,"Random Color",Color3.fromRGB(80,45,120),function()
        local c=GetChar(); if c then
            local col=Color3.fromHSV(math.random(),0.85,1)
            for _,v in pairs(c:GetDescendants()) do if v:IsA("BasePart") then v.Color=col end end
            Notify("Color","Random")
        end
    end)

    Sec(pg, "Visibility")
    Btn(pg, "Invisible",        Color3.fromRGB(40,42,65), function()
        local c=GetChar(); if c then
            for _,v in pairs(c:GetDescendants()) do if v:IsA("BasePart") then v.Transparency=1 end end
            Notify("Vis","透明化")
        end
    end)
    Btn(pg, "Semi-transparent", Color3.fromRGB(50,52,78), function()
        local c=GetChar(); if c then
            for _,v in pairs(c:GetDescendants()) do if v:IsA("BasePart") then v.Transparency=0.6 end end
            Notify("Vis","半透明")
        end
    end)
    Btn(pg, "Visible (reset)",  C.green, function()
        local c=GetChar(); if c then
            for _,v in pairs(c:GetDescendants()) do
                if v:IsA("BasePart") and v.Name~="HumanoidRootPart" then v.Transparency=0 end
            end
            Notify("Vis","表示復元")
        end
    end)

    Sec(pg, "Glow (PointLight)")
    local glowPart
    local GCOLS={
        Blue=Color3.fromRGB(0,100,255), Red=Color3.fromRGB(255,0,0),
        Green=Color3.fromRGB(0,255,80), Yellow=Color3.fromRGB(255,220,0),
        White=Color3.fromRGB(255,255,255), Purple=Color3.fromRGB(180,0,255),
        Pink=Color3.fromRGB(255,0,180), Orange=Color3.fromRGB(255,120,0),
    }
    local gGrid=New("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,ZIndex=6},pg)
    New("UIGridLayout",{CellSize=UDim2.new(0.5,-3,0,26),CellPadding=UDim2.new(0,4,0,4),SortOrder=Enum.SortOrder.LayoutOrder},gGrid)
    for name,col in pairs(GCOLS) do
        local b=New("TextButton",{BackgroundColor3=Color3.fromRGB(25,26,42),BorderSizePixel=0,
            Text="Glow: "..name,TextColor3=col,TextSize=11,Font=Enum.Font.GothamSemibold,AutoButtonColor=false,ZIndex=7},gGrid)
        New("UICorner",{CornerRadius=UDim.new(0,4)},b)
        b.MouseButton1Click:Connect(function()
            local hrp=GetHRP(); if not hrp then return end
            if glowPart then glowPart:Destroy() end
            glowPart=New("Part",{Anchored=false,CanCollide=false,Size=Vector3.new(0.1,0.1,0.1),Transparency=1,CFrame=hrp.CFrame,Parent=WS})
            New("WeldConstraint",{Part0=hrp,Part1=glowPart,Parent=glowPart})
            New("PointLight",{Brightness=10,Range=32,Color=col,Parent=glowPart})
            Notify("Glow","ON: "..name)
        end)
    end
    Btn(pg,"Glow OFF",C.red,function()
        if glowPart then glowPart:Destroy(); glowPart=nil end; Notify("Glow","OFF") end)

    Sec(pg, "Accessories")
    Btn(pg,"Remove All Accessories",C.red,function()
        local c=GetChar(); if c then
            for _,v in pairs(c:GetChildren()) do if v:IsA("Accessory") then v:Destroy() end end
            Notify("Accessories","全削除")
        end
    end)
end

-- ================================================================
-- PAGE: Physics
-- ================================================================
do
    local pg = Pages["Physics"]

    Sec(pg, "Launch")
    Btn(pg,"Launch Up",       C.yellow, function()
        local hrp=GetHRP(); if not hrp then return end
        local bv=New("BodyVelocity",{Velocity=Vector3.new(0,260,0),MaxForce=Vector3.new(0,1e6,0)},hrp)
        Debris:AddItem(bv,0.12); Notify("Launch","上に発射")
    end)
    Btn(pg,"Yeet (Random)",   C.purple, function()
        local hrp=GetHRP(); if not hrp then return end
        local bv=New("BodyVelocity",{
            Velocity=Vector3.new(math.random(-130,130),260,math.random(-130,130)),
            MaxForce=Vector3.new(1e6,1e6,1e6)},hrp)
        Debris:AddItem(bv,0.1); Notify("Yeet","飛んだ")
    end)
    Btn(pg,"Slam Down",       C.red, function()
        local hrp=GetHRP(); if not hrp then return end
        local bv=New("BodyVelocity",{Velocity=Vector3.new(0,-200,0),MaxForce=Vector3.new(0,1e6,0)},hrp)
        Debris:AddItem(bv,0.2); Notify("Slam","下に叩きつけ")
    end)

    Sec(pg, "Spin")
    local spinOn=false; local spinConn
    Toggle(pg,"Spin Character",false,function(s)
        spinOn=s
        if spinConn then spinConn:Disconnect(); spinConn=nil end
        if s then
            spinConn=RS.Heartbeat:Connect(function()
                if not spinOn then return end
                local hrp=GetHRP()
                if hrp then hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(9),0) end
            end)
        end
        Notify("Spin",s and "ON" or "OFF")
    end)

    Sec(pg, "Explosion")
    Btn(pg,"Explosion at Position",C.red,function()
        local hrp=GetHRP(); if not hrp then return end
        local e=Instance.new("Explosion")
        e.Position=hrp.Position; e.BlastRadius=25
        e.BlastPressure=5e5; e.DestroyJointRadiusPercent=0; e.Parent=WS
        Notify("Explosion","爆発！")
    end)

    Sec(pg, "World Parts")
    Btn(pg,"Explode Nearby Parts (35st)",C.red,function()
        local hrp=GetHRP(); if not hrp then return end
        local n=0
        for _,v in pairs(WS:GetDescendants()) do
            if v:IsA("BasePart") and not v.Anchored and v.Name~="HumanoidRootPart"
               and (v.Position-hrp.Position).Magnitude<35 then
                local bv=New("BodyVelocity",{
                    Velocity=Vector3.new(math.random(-80,80),math.random(50,150),math.random(-80,80)),
                    MaxForce=Vector3.new(1e5,1e5,1e5)},v)
                Debris:AddItem(bv,0.5); n=n+1
            end
        end
        Notify("Explode",n.." 個吹き飛ばした")
    end)
    Btn(pg,"Anchor Nearby (60st)",  C.green, function()
        local hrp=GetHRP(); if not hrp then return end
        local n=0
        for _,v in pairs(WS:GetDescendants()) do
            if v:IsA("BasePart") and (v.Position-hrp.Position).Magnitude<60 then v.Anchored=true; n=n+1 end
        end
        Notify("Anchor",n.." 個固定")
    end)
    Btn(pg,"Unanchor Nearby (60st)",C.yellow,function()
        local hrp=GetHRP(); if not hrp then return end
        local n=0
        for _,v in pairs(WS:GetDescendants()) do
            if v:IsA("BasePart") and (v.Position-hrp.Position).Magnitude<60 then v.Anchored=false; n=n+1 end
        end
        Notify("Unanchor",n.." 個解除")
    end)
end

-- ================================================================
-- PAGE: Tools
-- ================================================================
do
    local pg = Pages["Tools"]

    Sec(pg, "Crosshair")
    Toggle(pg,"Custom Crosshair",false,function(s)
        local ex=PGui:FindFirstChild("_OAP_CH")
        if s and not ex then
            local g=New("ScreenGui",{Name="_OAP_CH",ResetOnSpawn=false,Parent=PGui})
            local function L(sx,sy,px,py)
                New("Frame",{Size=UDim2.new(0,sx,0,sy),
                    Position=UDim2.new(0.5,px,0.5,py),
                    BackgroundColor3=Color3.fromRGB(240,242,255),
                    BorderSizePixel=0,Parent=g})
            end
            L(1,10,  -1,-5); L(1,10,  -1, 2)
            L(10,1,  -5,-1); L(10,1,   2,-1)
            New("Frame",{Size=UDim2.new(0,2,0,2),Position=UDim2.new(0.5,-1,0.5,-1),
                BackgroundColor3=Color3.fromRGB(255,55,55),BorderSizePixel=0,Parent=g})
            Notify("Crosshair","ON")
        elseif not s and ex then ex:Destroy(); Notify("Crosshair","OFF") end
    end)

    Sec(pg, "HUD Overlay")
    local hudConn; local hudGui
    Toggle(pg,"Speed / Pos HUD",false,function(s)
        if hudGui then hudGui:Destroy(); hudGui=nil end
        if hudConn then hudConn:Disconnect(); hudConn=nil end
        if not s then Notify("HUD","OFF"); return end
        hudGui=New("ScreenGui",{Name="_OAP_HUD",ResetOnSpawn=false,Parent=PGui})
        local frame=New("Frame",{
            Size=UDim2.new(0,210,0,70),Position=UDim2.new(0,12,1,-85),
            BackgroundColor3=Color3.fromRGB(8,8,14),BackgroundTransparency=0.3,
            BorderSizePixel=0,Parent=hudGui})
        New("UICorner",{CornerRadius=UDim.new(0,6)},frame)
        New("UIStroke",{Color=C.border,Thickness=1},frame)
        local rows={"Speed","Pos","HP"}
        local lbls={}
        for i,r in ipairs(rows) do
            local lbl=New("TextLabel",{
                Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,8,0,(i-1)*22),
                BackgroundTransparency=1,Text=r..": ---",
                TextColor3=C.text,TextSize=12,Font=Enum.Font.Code,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=frame})
            lbls[r]=lbl
        end
        hudConn=RS.Heartbeat:Connect(function()
            local h=GetHum(); local hrp=GetHRP()
            if h   then lbls["Speed"].Text="Speed:  "..math.floor(h.WalkSpeed)
                        lbls["HP"].Text   ="HP:      "..math.floor(h.Health).." / "..math.floor(h.MaxHealth) end
            if hrp then
                local p=hrp.Position
                lbls["Pos"].Text=("Pos:   %.0f, %.0f, %.0f"):format(p.X,p.Y,p.Z)
            end
        end)
        Notify("HUD","ON")
    end)

    Sec(pg, "Reach")
    Slider(pg,"Tool Reach Size",1,120,5,function(v)
        local c=GetChar(); if not c then return end
        for _,tool in pairs(c:GetChildren()) do
            if tool:IsA("Tool") then
                local h=tool:FindFirstChild("Handle"); if h then h.Size=Vector3.new(v,v,v) end
            end
        end
    end)

    Sec(pg, "Misc")
    Btn(pg,"Test Notification",C.accent,function() Notify("Test","テスト通知",3) end)
    Btn(pg,"Remove This GUI",  C.red,   function() Root:Destroy() end)
end

-- ================================================================
-- コマンドシステム
-- ================================================================
local CMD={}

-- Movement
CMD.speed=function(a) local h=GetHum(); if h then h.WalkSpeed=tonumber(a[1]) or 16; Notify("speed",h.WalkSpeed) end end
CMD.ws=CMD.speed
CMD.jump=function(a) local h=GetHum(); if h then h.JumpPower=tonumber(a[1]) or 50; Notify("jump",h.JumpPower) end end
CMD.jp=CMD.jump
CMD.noclip=function()
    if CMD._nc then return end
    CMD._ncOn=true
    CMD._nc=RS.Stepped:Connect(function()
        if not CMD._ncOn then return end
        local c=GetChar(); if not c then return end
        for _,v in pairs(c:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end
    end)
    Notify("noclip","ON")
end
CMD.clip=function()
    CMD._ncOn=false
    if CMD._nc then CMD._nc:Disconnect(); CMD._nc=nil end
    local c=GetChar(); if c then
        for _,v in pairs(c:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=true end end
    end
    Notify("clip","ON")
end
CMD.fly=function()
    if CMD._flyOn then Notify("fly","既に飛行中"); return end
    local hrp=GetHRP(); if not hrp then return end
    CMD._flyOn=true
    CMD._flyBV=New("BodyVelocity",{Velocity=Vector3.zero,MaxForce=Vector3.new(1e5,1e5,1e5),Name="_CmdFlyBV"},hrp)
    CMD._flyBG=New("BodyGyro",{MaxTorque=Vector3.new(1e5,1e5,1e5),D=100,Name="_CmdFlyBG"},hrp)
    CMD._flyHB=RS.Heartbeat:Connect(function()
        if not CMD._flyOn then return end
        local h2=GetHRP(); if not h2 then return end
        local d=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then d=d-Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then d=d-Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then d=d+Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space)       then d=d+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d=d-Vector3.new(0,1,0) end
        CMD._flyBV.Velocity=d*(UIS:IsKeyDown(Enum.KeyCode.LeftShift) and 220 or 85)
        CMD._flyBG.CFrame=Cam.CFrame
    end)
    Notify("fly","ON  |  nofly で停止")
end
CMD.nofly=function()
    CMD._flyOn=false
    if CMD._flyHB then CMD._flyHB:Disconnect(); CMD._flyHB=nil end
    if CMD._flyBV then CMD._flyBV:Destroy(); CMD._flyBV=nil end
    if CMD._flyBG then CMD._flyBG:Destroy(); CMD._flyBG=nil end
    Notify("nofly","OFF")
end
CMD.freeze=function() local h=GetHRP(); if h then h.Anchored=true;  Notify("freeze","固定") end end
CMD.unfreeze=function() local h=GetHRP(); if h then h.Anchored=false; Notify("unfreeze","解除") end end
CMD.tp=function(a)
    local x,y,z=tonumber(a[1]),tonumber(a[2]),tonumber(a[3])
    local hrp=GetHRP()
    if hrp and x and y and z then hrp.CFrame=CFrame.new(x,y,z); Notify("tp",x..","..y..","..z) end
end
CMD.tpme=function(a)
    local pl=FindPlayer(a[1] or "")
    if not pl then Notify("tpme","見つからない: "..(a[1] or "?")); return end
    local hrp=GetHRP(); local thrp=pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
    if hrp and thrp then hrp.CFrame=thrp.CFrame*CFrame.new(3,0,3); Notify("tpme",pl.Name.."にTP") end
end
CMD.sky=function() local h=GetHRP(); if h then h.CFrame=CFrame.new(h.Position.X,500,h.Position.Z); Notify("sky","高度500") end end
CMD.ground=function() local h=GetHRP(); if h then h.CFrame=CFrame.new(h.Position.X,5,h.Position.Z); Notify("ground","地面") end end
CMD.forward=function(a) local d=tonumber(a[1]) or 40; local h=GetHRP(); if h then h.CFrame=h.CFrame*CFrame.new(0,0,-d); Notify("forward",d) end end
CMD.back=function(a)    local d=tonumber(a[1]) or 40; local h=GetHRP(); if h then h.CFrame=h.CFrame*CFrame.new(0,0,d);  Notify("back",d) end end
CMD.up=function(a)      local d=tonumber(a[1]) or 40; local h=GetHRP(); if h then h.CFrame=h.CFrame*CFrame.new(0,d,0);  Notify("up",d) end end
CMD.yeet=function()
    local h=GetHRP(); if not h then return end
    local bv=New("BodyVelocity",{Velocity=Vector3.new(math.random(-130,130),260,math.random(-130,130)),MaxForce=Vector3.new(1e6,1e6,1e6)},h)
    Debris:AddItem(bv,0.1); Notify("yeet","！")
end
CMD.sit=function() local h=GetHum(); if h then h.Sit=true; Notify("sit","座った") end end

-- HP / Character
CMD.hp=function(a) local h=GetHum(); if h then h.Health=tonumber(a[1]) or 100; Notify("hp",h.Health) end end
CMD.h=CMD.hp
CMD.maxhp=function(a) local h=GetHum(); if h then local v=tonumber(a[1]) or 100; h.MaxHealth=v; h.Health=v; Notify("maxhp",v) end end
CMD.heal=function() local h=GetHum(); if h then h.Health=h.MaxHealth; Notify("heal","全回復") end end
CMD.kill=function() local h=GetHum(); if h then h.Health=0 end end
CMD.k=CMD.kill
CMD.respawn=function() LP:LoadCharacter(); Notify("respawn","リスポーン") end
CMD.r=CMD.respawn
CMD.vis=function() local c=GetChar(); if c then for _,v in pairs(c:GetDescendants()) do if v:IsA("BasePart") then v.Transparency=0 end end end end
CMD.invis=function() local c=GetChar(); if c then for _,v in pairs(c:GetDescendants()) do if v:IsA("BasePart") then v.Transparency=1 end end end end
CMD.ghost=function()
    local c=GetChar(); if c then
        for _,v in pairs(c:GetDescendants()) do if v:IsA("BasePart") then v.Transparency=0.6; v.CanCollide=false end end
        Notify("ghost","ゴーストモード")
    end
end
CMD.unghost=function()
    local c=GetChar(); if c then
        for _,v in pairs(c:GetDescendants()) do if v:IsA("BasePart") then v.Transparency=0; v.CanCollide=true end end
        Notify("unghost","解除")
    end
end
CMD.spin=function(a)
    if CMD._spinConn then CMD._spinConn:Disconnect() end
    local spd=tonumber(a[1]) or 10; CMD._spinOn=true
    CMD._spinConn=RS.Heartbeat:Connect(function()
        if not CMD._spinOn then return end
        local hrp=GetHRP(); if hrp then hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(spd),0) end
    end)
    Notify("spin","ON speed:"..spd)
end
CMD.unspin=function()
    CMD._spinOn=false
    if CMD._spinConn then CMD._spinConn:Disconnect(); CMD._spinConn=nil end
    Notify("unspin","OFF")
end
CMD.size=function(a)
    local v=tonumber(a[1]) or 1; local h=GetHum()
    if h then h.BodyHeightScale=v; h.BodyWidthScale=v; h.BodyDepthScale=v; h.HeadScale=v; Notify("size",v) end
end
CMD.headsize=function(a) local h=GetHum(); if h then h.HeadScale=tonumber(a[1]) or 1; Notify("headsize",h.HeadScale) end end
CMD.color=function(a)
    local nm=(a[1] or ""):lower()
    local cols={red=BrickColor.new("Bright red"),blue=BrickColor.new("Bright blue"),
        green=BrickColor.new("Bright green"),yellow=BrickColor.new("Bright yellow"),
        white=BrickColor.White(),black=BrickColor.Black(),pink=BrickColor.new("Hot pink"),
        orange=BrickColor.new("Bright orange"),purple=BrickColor.new("Medium lilac"),cyan=BrickColor.new("Cyan")}
    if cols[nm] then
        local c=GetChar(); if c then for _,v in pairs(c:GetDescendants()) do if v:IsA("BasePart") then v.BrickColor=cols[nm] end end end
        Notify("color",nm)
    else Notify("color","red/blue/green/yellow/white/black/pink/orange/purple/cyan") end
end
CMD.glow=function(a)
    local nm=(a[1] or "blue"):lower()
    local cols={blue=Color3.fromRGB(0,100,255),red=Color3.fromRGB(255,0,0),green=Color3.fromRGB(0,255,80),
        yellow=Color3.fromRGB(255,220,0),white=Color3.fromRGB(255,255,255),purple=Color3.fromRGB(180,0,255),
        pink=Color3.fromRGB(255,0,180),orange=Color3.fromRGB(255,120,0)}
    local col=cols[nm] or Color3.fromRGB(0,100,255)
    local hrp=GetHRP(); if not hrp then return end
    if CMD._glowPart then CMD._glowPart:Destroy() end
    CMD._glowPart=New("Part",{Anchored=false,CanCollide=false,Size=Vector3.new(0.1,0.1,0.1),Transparency=1,CFrame=hrp.CFrame,Parent=WS})
    New("WeldConstraint",{Part0=hrp,Part1=CMD._glowPart,Parent=CMD._glowPart})
    New("PointLight",{Brightness=10,Range=32,Color=col,Parent=CMD._glowPart})
    Notify("glow","ON: "..nm)
end
CMD.noglow=function() if CMD._glowPart then CMD._glowPart:Destroy(); CMD._glowPart=nil end; Notify("noglow","OFF") end

-- World / Lighting
CMD.gravity=function(a) WS.Gravity=tonumber(a[1]) or 196; Notify("gravity",WS.Gravity) end
CMD.g=CMD.gravity
CMD.time=function(a) Lighting.ClockTime=tonumber(a[1]) or 12; Notify("time",Lighting.ClockTime) end
CMD.t=CMD.time
CMD.day=function() Lighting.ClockTime=12; Lighting.Brightness=3; Lighting.Ambient=Color3.fromRGB(115,115,115); Notify("day","昼") end
CMD.night=function() Lighting.ClockTime=0; Lighting.Ambient=Color3.fromRGB(8,8,22); Notify("night","夜") end
CMD.sunset=function() Lighting.ClockTime=18.5; Lighting.Ambient=Color3.fromRGB(255,125,45); Notify("sunset","夕焼け") end
CMD.bright=function(a) Lighting.Brightness=tonumber(a[1]) or 2; Notify("bright",Lighting.Brightness) end
CMD.b=CMD.bright
CMD.fog=function(a) Lighting.FogEnd=tonumber(a[1]) or 200; Lighting.FogStart=0; Notify("fog","ON") end
CMD.nofog=function() Lighting.FogEnd=100000; Notify("nofog","OFF") end
CMD.fov=function(a) Cam.FieldOfView=tonumber(a[1]) or 70; Notify("fov",Cam.FieldOfView) end
CMD.f=CMD.fov
CMD.bloom=function(a) if not Lighting:FindFirstChildOfClass("BloomEffect") then New("BloomEffect",{Intensity=tonumber(a[1]) or 0.9,Size=24,Threshold=1,Parent=Lighting}) end; Notify("bloom","ON") end
CMD.nobloom=function() local e=Lighting:FindFirstChildOfClass("BloomEffect"); if e then e:Destroy() end; Notify("nobloom","OFF") end
CMD.blur=function(a) if not Lighting:FindFirstChildOfClass("BlurEffect") then New("BlurEffect",{Size=tonumber(a[1]) or 16,Parent=Lighting}) end; Notify("blur","ON") end
CMD.noblur=function() local e=Lighting:FindFirstChildOfClass("BlurEffect"); if e then e:Destroy() end; Notify("noblur","OFF") end
CMD.sunrays=function() if not Lighting:FindFirstChildOfClass("SunRaysEffect") then New("SunRaysEffect",{Intensity=0.25,Spread=0.5,Parent=Lighting}) end; Notify("sunrays","ON") end
CMD.nosunrays=function() local e=Lighting:FindFirstChildOfClass("SunRaysEffect"); if e then e:Destroy() end; Notify("nosunrays","OFF") end
CMD.dof=function() if not Lighting:FindFirstChildOfClass("DepthOfFieldEffect") then New("DepthOfFieldEffect",{FarIntensity=0.8,FocusDistance=50,InFocusRadius=10,NearIntensity=0.6,Parent=Lighting}) end; Notify("dof","ON") end
CMD.nodof=function() local e=Lighting:FindFirstChildOfClass("DepthOfFieldEffect"); if e then e:Destroy() end; Notify("nodof","OFF") end
CMD.rain=function()
    if WS:FindFirstChild("_OAP_Rain") then return end
    local pt=New("Part",{Name="_OAP_Rain",Anchored=true,CanCollide=false,Size=Vector3.new(600,1,600),Transparency=1,CFrame=CFrame.new(0,120,0)},WS)
    New("ParticleEmitter",{Texture="rbxassetid://6101261690",Rate=1500,Speed=NumberRange.new(80,100),
        Lifetime=NumberRange.new(1,2),Size=NumberSequence.new{NumberSequenceKeypoint.new(0,0.04),NumberSequenceKeypoint.new(1,0.04)},
        Direction=Vector3.new(0,-1,0),SpreadAngle=Vector2.new(0,0)},pt)
    Notify("rain","ON")
end
CMD.snow=function()
    if WS:FindFirstChild("_OAP_Snow") then return end
    local pt=New("Part",{Name="_OAP_Snow",Anchored=true,CanCollide=false,Size=Vector3.new(600,1,600),Transparency=1,CFrame=CFrame.new(0,120,0)},WS)
    New("ParticleEmitter",{Texture="rbxassetid://1095708795",Rate=450,Speed=NumberRange.new(6,18),
        Lifetime=NumberRange.new(4,7),Size=NumberSequence.new{NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(1,0.08)},
        Direction=Vector3.new(0,-1,0),SpreadAngle=Vector2.new(22,22),RotSpeed=NumberRange.new(-55,55)},pt)
    Notify("snow","ON")
end
CMD.norain=function()
    for _,n in pairs({"_OAP_Rain","_OAP_Snow"}) do local v=WS:FindFirstChild(n); if v then v:Destroy() end end
    Notify("norain","天気クリア")
end
CMD.nosnow=CMD.norain
CMD.explosion=function(a)
    local hrp=GetHRP(); if not hrp then return end
    local e=Instance.new("Explosion")
    e.Position=hrp.Position; e.BlastRadius=tonumber(a[1]) or 25
    e.BlastPressure=5e5; e.DestroyJointRadiusPercent=0; e.Parent=WS
    Notify("explosion","爆発！")
end

-- Info
CMD.pos=function()
    local hrp=GetHRP(); if hrp then
        local p=hrp.Position; Notify("Position",("X:%.1f  Y:%.1f  Z:%.1f"):format(p.X,p.Y,p.Z),5)
    end
end
CMD.p=CMD.pos
CMD.age=function() Notify("Account",LP.Name.." | "..LP.AccountAge.." days",5) end
CMD.id=function() Notify("UserID","ID: "..LP.UserId,5) end
CMD.gametime=function()
    local t=math.floor(WS.DistributedGameTime)
    Notify("GameTime",("%dm %ds"):format(math.floor(t/60),t%60),4)
end
CMD.players=function()
    local t={}; for _,pl in pairs(Players:GetPlayers()) do t[#t+1]=pl.Name end
    Notify("Players",table.concat(t,", "),6)
end
CMD.serverinfo=function()
    SetTab("Server Info"); Notify("Server Info","Server Infoタブを開きました")
end

-- Camera
CMD["1p"]=function() LP.CameraMode=Enum.CameraMode.LockFirstPerson; Notify("1p","一人称") end
CMD["3p"]=function() LP.CameraMode=Enum.CameraMode.Classic; Notify("3p","三人称") end
CMD.freecam=function() SetTab("Freecam"); Notify("Freecam","Freecamタブを開きました") end

-- Reset
CMD.reset=function()
    WS.Gravity=196; Lighting.ClockTime=14; Lighting.Brightness=2; Lighting.FogEnd=100000
    Lighting.Ambient=Color3.fromRGB(70,70,70); Cam.FieldOfView=70
    local h=GetHum(); if h then h.WalkSpeed=16; h.JumpPower=50; h.MaxHealth=100; h.Health=100 end
    Notify("reset","全設定リセット")
end

CMD.help=function()
    Notify("help 1/4","speed  jump  fly  nofly  noclip  clip  freeze  unfreeze  sit  yeet",6)
    task.delay(1,function() Notify("help 2/4","tp  tpme  sky  ground  forward  back  up  spin  unspin  size  headsize",6) end)
    task.delay(2,function() Notify("help 3/4","hp  heal  maxhp  kill  respawn  vis  invis  ghost  unghost  color  glow  noglow",6) end)
    task.delay(3,function() Notify("help 4/4","gravity  time  day  night  sunset  fog  nofog  bright  fov  bloom  blur  sunrays  dof  rain  snow  explosion  pos  age  id  players  serverinfo  reset",6) end)
end

-- Exec
local function Exec(raw)
    raw = raw:match("^%s*(.-)%s*$")
    if raw=="" then return end
    local parts=raw:split(" ")
    local cmd=parts[1]:lower()
    local a={}; for i=2,#parts do a[#a+1]=parts[i] end
    local fn=CMD[cmd]
    if fn then local ok,err=pcall(fn,a); if not ok then Notify("Error",tostring(err)) end
    else Notify("Unknown","'"..cmd.."'  |  helpで一覧") end
end

ExecBtn.MouseButton1Click:Connect(function() Exec(CmdIn.Text); CmdIn.Text="" end)
CmdIn.FocusLost:Connect(function(enter) if enter then Exec(CmdIn.Text); CmdIn.Text="" end end)

-- ================================================================
-- ウィンドウ操作
-- ================================================================
local minimized=false; local maximized=false
local origSize=UDim2.new(0,WIN_W,0,WIN_H)
local origPos =UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)

BtnClose.MouseButton1Click:Connect(function()
    TW(Main,{Size=UDim2.new(0,WIN_W,0,0),BackgroundTransparency=1},0.2,
        Enum.EasingStyle.Quart,Enum.EasingDirection.In)
    task.delay(0.2,function() Main.Visible=false; Main.Size=origSize; Main.BackgroundTransparency=0 end)
end)

BtnMin.MouseButton1Click:Connect(function()
    if minimized then
        Main.ClipsDescendants=true
        TW(Main,{Size=origSize},0.25,Enum.EasingStyle.Back)
        minimized=false
    else
        TW(Main,{Size=UDim2.new(0,WIN_W,0,TBAR_H)},0.2,Enum.EasingStyle.Quart)
        minimized=true
    end
end)

BtnMax.MouseButton1Click:Connect(function()
    if maximized then
        TW(Main,{Size=origSize,Position=origPos},0.25,Enum.EasingStyle.Back)
        maximized=false
    else
        TW(Main,{Size=UDim2.new(1,-4,1,-4),Position=UDim2.new(0,2,0,2)},0.25,Enum.EasingStyle.Quart)
        maximized=true
    end
end)

-- ドラッグ
local dragging=false; local dragSt; local posSt
TBar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true; dragSt=i.Position; posSt=Main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-dragSt
        Main.Position=UDim2.new(posSt.X.Scale,posSt.X.Offset+d.X,posSt.Y.Scale,posSt.Y.Offset+d.Y)
        origPos=Main.Position
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)

-- ] キーで開閉
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.RightBracket then
        if Main.Visible then
            TW(Main,{Size=UDim2.new(0,WIN_W,0,0)},0.18,Enum.EasingStyle.Quart,Enum.EasingDirection.In)
            task.delay(0.18,function() Main.Visible=false; Main.Size=origSize; minimized=false end)
        else
            Main.Visible=true; Main.Size=UDim2.new(0,WIN_W,0,0)
            TW(Main,{Size=origSize},0.28,Enum.EasingStyle.Back)
            SetTab("Server Info")
        end
    end
end)

-- ================================================================
-- 起動
-- ================================================================
SetTab("Server Info")
Main.Visible=true
Main.Size=UDim2.new(0,WIN_W,0,0)
TW(Main,{Size=origSize},0.35,Enum.EasingStyle.Back)
Notify("Onani Admin Panel  v4.0","] で開閉  |  F2でFreecam終了  |  helpでコマンド一覧",6)

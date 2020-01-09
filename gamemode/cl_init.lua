AddCSLuaFile( "cl_deathnotice.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )

include( "shared.lua" )
include( "cl_deathnotice.lua" )
include( "cl_scoreboard.lua" )


//language.Add("worldspawn", "Fell to his Clumsy Death")
language.Add("trigger_hurt", "Fell over Writhing in Pain")

// These are our kill icons
local Color_Icon = Color( 255, 80, 0, 255 )
local NPC_Color = Color( 250, 50, 50, 255 )

killicon.AddFont( "human_gun",			"CSKillIcons",		"c",	Color_Icon )
killicon.AddFont( "ninja_gun",			"CSKillIcons",		"y",	Color_Icon )
killicon.AddFont( "pred_gun",			"CSKillIcons",		"j",	Color_Icon )
killicon.AddFont( "neo_gun",			"CSKillIcons",		"s",	Color_Icon )
killicon.AddFont( "hitman_gun",			"CSKillIcons",		"n",	Color_Icon )
killicon.AddFont( "jugg_gun",			"CSKillIcons",		"k",	Color_Icon )
killicon.AddFont( "bomber_gun",			"CSKillIcons",		"I",	Color_Icon )
killicon.AddFont( "swat_gun",			"CSKillIcons",		"w",	Color_Icon )
killicon.AddFont( "terrorist_gun",		"CSKillIcons",		"b",	Color_Icon )
killicon.AddFont( "sorcerer_gun",		"HL2MPTypeDeath",		"!",	Color_Icon )
killicon.AddFont( "golem_gun",			"CSKillIcons",		"z",	Color_Icon )
killicon.AddFont( "gunner_gun",			"CSKillIcons",		"f",	Color_Icon )
killicon.AddFont( "assassin_gun",		"CSKillIcons",		"i",	Color_Icon )
killicon.AddFont( "grenade_gun",		"HL2MPTypeDeath",		"4",	Color_Icon )
killicon.AddFont( "raider_gun",		"CSKillIcons",		"l",	Color_Icon )
killicon.AddFont( "advancer_gun",		"CSKillIcons",		"m",	Color_Icon )
killicon.AddFont( "arena_rocket",		"HL2MPTypeDeath",		"3",	Color_Icon )
killicon.AddFont( "prop_physics",		"HL2MPTypeDeath", 	"8", 	Color_Icon )


endMenu = {} 
maps = {} -- map votes

surface.CreateFont( "ClassName", {
	font = "coolvetica",
	extended = false,
	size = 22,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "ClassNameSmall", {
	font = "coolvetica",
	extended = false,
	size = 17,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "ClassNameLarge", {
	font = "coolvetica",
	extended = false,
	size = 26,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "CSKillIcons", {
      font = "csd",
      size = 50,
      weight = 500,
      blursize = 0,
      scanlines = 0,
      antialias = false,
	  shadow = false,
	  additive = true
} )

surface.CreateFont( "HL2MPTypeDeath", {
      font = "hl2mp",
      size = 50,
      weight = 500,
      blursize = 0,
      scanlines = 0,
      antialias = false,
	  shadow = false,
	  additive = true
} )


-- server-side originating, player independent (broadcast) vars
gamePhase = -1 -- 0=waiting, 1=build, 2=fight, 3=game over
gameTime = 300 -- build time
winner = "Nobody" -- 0=blue, 1=red, 2=green, 3=yellow

DEFAULT_BALL_TIME = 120
blueTimeLeft = 120
redTimeLeft = 120
greenTimeLeft = 120
yellowTimeLeft = 120
-- -- -- -- -- -- -- -- --

-- server-side originating, player-specific net vars
activeClass = 1 -- ID of Shared.lua/Classes{}. default is human, 1
classes = {}
isAdmin = 0
cash = 2500
-- -- -- -- -- -- -- -- --

-- client-side local vars
Blue = Color(0, 0, 255, 120)
Red = Color(255, 0, 0, 120)
Green = Color(0, 255, 0, 120)
Yellow = Color(255, 255, 0, 120)      
HudColor = Color(42, 42, 42, 180)

myprops = {}

local storeOpen;
local propMenuOpen;
-- -- -- -- -- -- -- -- -- --

-- Convars and Score HUD/Target Text taken directly from Darklands FW --

TeamsPresent = 0
TeamInfo = {}

net.Receive("initFW",function(  )
	local index = net.ReadInt(32)
	while(index != 0) do
		TeamInfo[index] = {
			Present = true,
			BoxCount = 0,
			HoldTime = DEFAULT_BALL_TIME
		}
		TeamsPresent = TeamsPresent + 1
		index = net.ReadInt(32)
	end
end)

CreateClientConVar( "fw_advcrouch", "1", true, true )
MenuOnSpawn = CreateClientConVar( "fw_menuonspawn", "1", true, true )
CreateClientConVar( "fw_spawnwithgrav", "1", true, true )
CreateClientConVar( "fw_chatsounds", "1", true, true )
CreateClientConVar( "fw_zoomaftereload", "1", true, true )
CrosshairColor = CreateClientConVar( "fw_crosshaircolor", "0 255 0 255", true, true ):GetString()
CreateClientConVar( "fw_crosshairlength", "20", true, true ):GetString()
CreateClientConVar( "fw_crosshairwidth", "1", true, true ):GetString()
CreateClientConVar( "fw_crosshairdot", "0", true, true )

function ScoreWindow()
	local num = 0
	local adjustforteams = 0
	--print("Valid teams")
	-- PrintTable(TeamInfo)
	for i,v in pairs(TeamInfo) do
		if v.Present then
		    adjustforteams = adjustforteams + 1
		end
	end

	draw.RoundedBox(6, 10, -6, 267, 71+(adjustforteams*17), Color(200, 200, 200, 100))
	draw.RoundedBox(6, 11, -6, 265, 70+(adjustforteams*17), Color(5, 5, 5, 245))
		
	draw.RoundedBox(4, 16, 7, 256, 25, Color(200, 200, 200, 100))
	draw.RoundedBox(4, 17, 8, 254, 23, Color(5, 5, 5, 220))

	draw.SimpleText("FortWars", "ClassName", 136, 20, Color(255, 255, 255, 255), 1, 1)
		
		
	draw.DrawText("Capture the ball and hold it until\nyour team's timer runs out", "Default", 136, 35, Color(255, 255, 255, 255), 1, 1)

		for i, v in pairs(TeamInfo) do
		
			if v.Present then
			
				local c = team.GetColor(i)
				draw.RoundedBox(0, 29, 65 + num * 16, 242, 13, Color(0, 0, 0, 100))
				surface.SetTexture(surface.GetTextureID("darkland/fortwars/timerBar"))
			
				//if holdingTeam == i then 
				//	c = Color(math.Clamp((c.r + 75), 0, 255), math.Clamp((c.g + 75), 0, 255), math.Clamp((c.b + 75), 0, 255), 210)
				//end
				surface.SetDrawColor(Color(c.r, c.g, c.b, 210))
				surface.DrawTexturedRect(30, 66 + num * 16, 240, 11)
				
				draw.RoundedBox(7, 23 + (DEFAULT_BALL_TIME - v.HoldTime) / DEFAULT_BALL_TIME * 242, 64 + num * 16, 14, 14, Color(c.r, c.g, c.b, 255))
				//draw.Circle( 23 + (DEFAULT_BALL_TIME - v.HoldTime) / DEFAULT_BALL_TIME * 242, 64 + num * 16, 2, 2 )
				
				local font = "Default"
				//if holdingTeam == i then font = "DefaultSmall" end
				draw.SimpleText(string.ToMinutesSeconds(v.HoldTime), font, 136, 70+num*16, Color(255, 255, 255, 255), 0, 1)
			end
			num = num + 1;
		end

end


function GM:HUDDrawTargetID()
	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	if (!trace.HitNonWorld) then return end
	
	local text = "ERROR"
	local font = "TargetID"
	

	if (trace.Entity:IsPlayer()) then
		if trace.Entity:GetNWString("ADMDisguise") == "" then
			text = trace.Entity:GetName()
		else
			text = trace.Entity:GetNWString("ADMDisguise")
		end
	else
		return
		--text = trace.Entity:GetClass()
	end

	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	
	local MouseX, MouseY = gui.MousePos()
	
	if ( MouseX == 0 && MouseY == 0 ) then
	
		MouseX = ScrW() / 2
		MouseY = ScrH() / 2
	
	end
	
	local x = MouseX
	local y = MouseY
	x = x - w / 2
	y = y + 30
	
	 if trace.Entity:GetNWBool( "cloaked") == false and trace.Entity:GetNWBool( "acloaked") == false then
	 
		-- The fonts internal drop shadow looks lousy with AA on
		draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,120) )
		draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,50) )
		draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )
		
		y = y + h + 5
		
		local text = trace.Entity:Health() .. "%"
		local font = "TargetIDSmall"
		
		surface.SetFont( font )
		local w, h = surface.GetTextSize( text )
		local x =  MouseX  - w / 2
		
		draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,120) )
		draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,50) )
		draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )	
	end
end

--- -- --- ---- --- ---- --- -- ---

function drawHealthMoney() -- health, money, energy, and current class in bottom left
    draw.RoundedBox(30, -45, ScrH()-100, 300, 145, HudColor )
	surface.SetFont( "Trebuchet24" )
	surface.SetTextColor( 5, 255, 5 )
	surface.SetTextPos( 12, ScrH()- 90 )
	surface.DrawText( "$"..cash )
	
	surface.SetTextColor( 255, 255, 255 )
	surface.SetTextPos( 175, ScrH()- 80 )
	surface.DrawText( Classes[activeClass].NAME )
	
	 maxHealth = Classes[activeClass].HEALTH
	 plyHealth = LocalPlayer():Health() 
	 -- health bar 75, 188,
	 draw.RoundedBox(6, 5, ScrH()-60,
		math.Clamp(11+plyHealth/(maxHealth)*215, 11, 226), 12,
		Color(170, 0, 0, 240))
		
	 draw.SimpleTextOutlined("Health: "..plyHealth, "Default", 17, ScrH()-55,
		Color(255, 255, 255, 255), 0, 1, 1, Color(0, 0, 0, 255))
	
	 --energy bar 74, 232,
	 draw.RoundedBox(6, 5, ScrH()-35,
	    11+LocalPlayer():GetNWInt('energy')/(100)*215, 12, Color(0, 0, 170, 240))
	 draw.SimpleTextOutlined("Energy: "..math.Round(LocalPlayer():GetNWInt('energy')),
	    "Default", 18, ScrH()-30, Color(255, 255, 255, 255), 0, 1, 1, Color(0, 0, 0, 255)) 
	
	--maxHealth = Classes[activeClass].HEALTH
	--plyHealth = LocalPlayer():Health()
	--healthRed = math.floor((plyHealth/maxHealth)*255) + 255 -- ((99/100)*-255) + 255
	--healthGreen = math.floor((plyHealth/maxHealth)*255)
	--healthColor = Color(healthRed, healthGreen, 0)
	--draw.RoundedBox(30, 5, ScrH()-60, (plyHealth/maxHealth)*290, 70, healthColor )
end

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	return name ~= "CHudHealth" -- hide the default health HUD
end )

-- top left HUD for team ball timers
-- top middle HUD for build/fight timer
hook.Add( "HUDPaint", "HUDPaint_Draw", function()
	
	drawHealthMoney() -- bottom left
	
	surface.SetFont( "Trebuchet24" )
	surface.SetTextColor( 255, 255, 255 )
	if gamePhase == 0 then
	    surface.SetDrawColor( 42, 42, 42, 128 )
	    draw.RoundedBox(30, ScrW()/2 - 124, -45, 235, 95, HudColor ) -- top middle
	    surface.SetTextPos( ScrW()/2 - 120, 15 )
	    surface.DrawText( "Waiting for more players!" )
	elseif gamePhase == 1 then
	    surface.SetDrawColor( 42, 42, 42, 128 )
	    draw.RoundedBox(30, ScrW()/2 - 124, -45, 235, 95, HudColor ) -- top middle
		surface.SetTextPos( ScrW()/2 - 100, 15 )
	    surface.DrawText( "Build time left:")
		
		surface.SetTextPos( ScrW()/2 - 105, 45 )
		seconds = math.mod(gameTime,60)
	    if seconds < 10 then
		    seconds = "0" .. seconds
		end
	    surface.DrawText( math.floor(gameTime/60)..":"..seconds)
	elseif gamePhase == 2 then
	    --draw.RoundedBox(30, 0, 0, 259, 128, HudColor ) -- top left HUD only when fighting
		--surface.SetTextPos( ScrW()/2 - 100, 15 )
	    --surface.DrawText( "Fight!")
		--drawTeamCounters() 
		ScoreWindow()
	elseif gamePhase == 3 then
		surface.SetTextPos( ScrW()/2 - 77, 10 )
	    surface.DrawText( "Game over!" )
		
		--surface.SetTextPos( ScrW()/2 - 107, 45 )
	    --surface.DrawText( "Winner: ".. winner .."!")
    else
		surface.SetTextPos( ScrW()/2 - 115, 15 )
	    surface.DrawText( "Waiting for server...")
	end
end )

function showStore()
        storeOpen = true
        local Frame = vgui.Create( "DFrame" )
		Frame:SetPos( ScrW()/2 - 300, ScrH()/2 - 300 )
		Frame:SetSize( 775, 600 )
		Frame:SetTitle( "Fortwars Store" )
		Frame:SetVisible( true )
		Frame:SetDraggable( true )
		Frame:ShowCloseButton( true )
		Frame:MakePopup()
		
		
		function Frame:OnClose()
			storeOpen = false
		end
		
		local sheet = vgui.Create( "DPropertySheet", Frame )
		sheet:Dock( FILL )

		local panel1 = vgui.Create( "DPanel", sheet )
		panel1.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 128, 255, self:GetAlpha() ) ) end
		sheet:AddSheet( "Player Store", panel1, "icon16/group.png" )

        if isAdmin == 1 then
		    local players = {}
			local panel2 = vgui.Create( "DPanel", sheet )
			panel2.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 42, 42, 42, self:GetAlpha() ) ) end
			sheet:AddSheet( "Admin", panel2, "icon16/tick.png" )
			
			-- ADMIN PANEL -- SELECT PLAYER Combo Box -----
			local selectedPly = -1
			local comboBox = panel2:Add( "DComboBox")--, panel2 )
			comboBox:SetPos( 5, 5 )
			comboBox:SetSize( 100, 20 )
			comboBox:SetValue( "Select a player" )

			comboBox.OnSelect = function( self, value, data )
			     print( value )
				 print(data )
			    selectedPly = players[value]
				print( selectedPly)--.." was selected!" )
			end

			for k, v in pairs( player.GetAll() ) do
			    players[k] = v:UserID()  
				comboBox:AddChoice( v:Name() )
			end
			---
			-- Give money textbox + button --
			local TextEntry = panel2:Add( "DTextEntry")--, frame ) -- create the form as a child of frame
			TextEntry:SetPos( 115, 5 )
			TextEntry:SetSize( 75, 25 )
			TextEntry:SetText( "0" )
			--TextEntry.OnEnter = function( self )
			--	chat.AddText( self:GetValue() )	-- print the form's text as server text
			--e--nd
			
			local DermaButton = panel2:Add( "DButton")--, frame )
			DermaButton:SetText( "Give cash" )					 
			DermaButton:SetPos( 195, 5 )					 
			DermaButton:SetSize( 65, 27 )					 
			DermaButton.DoClick = function()
				    chat.AddText(Color(255, 0, 0), selectedPly)
				    RunConsoleCommand( "addcash", TextEntry:GetValue(), selectedPly ) --addcash 500 1 (adds $500 to user 1)		
				
			end
			
			-- END OF ADD CASH ComboBox + Button
		end
		
		local Scroll = vgui.Create( "DScrollPanel", panel1 )
		Scroll:Dock( FILL )

		local List = vgui.Create( "DIconLayout", Scroll )
		List:Dock( FILL )
		List:SetSpaceY( 5 )
		List:SetSpaceX( 5 )
		
		for k, v in pairs(Classes) do
			local Panel = List:Add( "DPanel")
			Panel:SetSize( 760, 175 )
			Panel.OwnLine = true
			Panel:SetBackgroundColor( Color(42, 42, 42, 170) )
			
			local icon = Panel:Add( "DModelPanel")
			icon:SetSize( 125, 125 )
			icon:SetModel( v.MODEL )
			
			local DLabel1 = Panel:Add( "DLabel")
			DLabel1:SetPos( 130, 10 )
			DLabel1:SetText( "Class name: "..v.NAME )
			DLabel1:SetFont("CenterPrintText")
			DLabel1:SetSize(280, 50)
			DLabel1:SetWrap( true )
			
			local DLabel2 = Panel:Add( "DLabel" )
			DLabel2:SetPos( 130, 30 )
			DLabel2:SetText( "Cost: "..v.COST )
			DLabel2:SetFont("CenterPrintText")
			DLabel2:SetSize(280, 50)	
			DLabel2:SetWrap( true )
			
			local DLabel3 = Panel:Add( "DLabel" )
			DLabel3:SetPos( 290, 10 )
			DLabel3 :SetText( "Description: "..v.DESCRIPTION )
			DLabel3:SetFont("CenterPrintText")
			DLabel3:SetSize(390, 100)	
			DLabel3:SetWrap( true )
			
			local DLabel4 = Panel:Add( "DLabel" )
			DLabel4:SetPos( 130, 50 )
			DLabel4:SetText( "Health: "..v.HEALTH )
			DLabel4:SetFont("CenterPrintText")
			DLabel4:SetSize(280, 50)	
			DLabel4:SetWrap( true )
			
			local DLabel5 = Panel:Add( "DLabel" )
			DLabel5:SetPos( 130, 70 )
			DLabel5:SetText( "Speed: "..v.SPEED )
			DLabel5:SetFont("CenterPrintText")
			DLabel5:SetSize(280, 50)
			DLabel5:SetWrap( true )
			
			local DLabel6 = Panel:Add( "DLabel" )
			DLabel6:SetPos( 130, 90 )
			DLabel6:SetText( "Jump power: "..v.JUMPOWER )
			DLabel6:SetFont("CenterPrintText")
			DLabel6:SetSize(280, 50)
			DLabel6:SetWrap( true )
			
			if v.SPECIALABILITY then
				local DLabel7 = Panel:Add( "DLabel" )
				local SpecAbilYPos = 10 + (9 * string.len(v.DESCRIPTION) / 45)
				DLabel7:SetPos( 290, SpecAbilYPos )
				DLabel7:SetText( "Special ability: "..v.SPECIALABILITY   )
			    DLabel7:SetFont("CenterPrintText")
				DLabel7:SetSize(390, 100)	
				DLabel7:SetWrap( true )
			
				local DLabel8 = Panel:Add( "DLabel" )
				DLabel8:SetPos( 130, 110 )
				DLabel8:SetText( "Special ability cost: "..v.SPECIALABILITY_COST )
				DLabel8:SetFont("CenterPrintText")
				DLabel8:SetSize(280, 50)	
				DLabel8:SetWrap( true )
			
			end 
			
			
			plyHasClass = 0
			
			for k2,v in pairs(classes) do
			    if tonumber(v['ClassId']) == k then plyHasClass = 1 end
				--chat.AddText(Color(255, 255, 255), "Checking if player has class ".. k .. " : " .. v['ClassId'])
			end
			
			if plyHasClass == 0 then -- only show Buy button for classes the player doesn't have
				local DermaButton = Panel:Add( "DButton")--, frame )
				DermaButton:SetText( "Buy" )					 
				DermaButton:SetPos( 40, 128 )					 
				DermaButton:SetSize( 35, 27 )					 
				DermaButton.DoClick = function()
					if cash<v.COST then
					    chat.AddText(Color(255, 0, 0), "Not enough money!")
					else
					    RunConsoleCommand( "buyclass", k )		
					end
				end
		    else -- show the "Switch to" button if they have the class
			    local DermaButton = Panel:Add( "DButton")--, frame )
				DermaButton:SetText( "Switch to this class" )					 
				DermaButton:SetPos( 15, 120 )					 
				DermaButton:SetSize( 100, 27 )					 
				DermaButton.DoClick = function()
					
					    RunConsoleCommand( "switchclass", k )		
					
				end
			end
		end
end

function showPropMenu()
        propMenuOpen = true
        local Frame = vgui.Create( "DFrame" )
		Frame:SetPos( ScrW()/2 - 300, ScrH()/2 - 300 )
		Frame:SetSize( 600, 600 )
		Frame:SetTitle( "Prop Store" )
		Frame:SetVisible( true )
		Frame:SetDraggable( false )
		Frame:ShowCloseButton( true )
		Frame:MakePopup()
end

function GM:PostDrawViewModel( vm, ply, weapon )
  if ( weapon.UseHands || !weapon:IsScripted() ) then
    local hands = LocalPlayer():GetHands()
    if ( IsValid( hands ) ) then hands:DrawModel() end
  end
end

hook.Add("Think", "OpenStores", function()
    if (input.IsButtonDown(KEY_F1) and !storeOpen) then
		showStore();
	end
	
    --if (input.IsButtonDown(KEY_Q) and !propMenuOpen) then
	--	showPropMenu();
	--end
end);

net.Receive( "GamePhase", function( len, pl )
	gamePhase = net.ReadInt(32) 
end )

net.Receive( "GameTime", function( len, pl )
	gameTime = net.ReadInt(32)
end )

net.Receive( "GameWinner", function( len, pl )
	winner = net.ReadString()
end )

net.Receive( "PlyCash", function( len, pl )
	cash = net.ReadInt(32)
end )

net.Receive( "TeamCounts", function( len, pl )
	blueTimeLeft = net.ReadInt(32)
	if TeamInfo[1] then
	    TeamInfo[1].HoldTime = blueTimeLeft
	end
	redTimeLeft = net.ReadInt(32)
	if TeamInfo[2] then
	    TeamInfo[2].HoldTime = redTimeLeft
	end
	yellowTimeLeft = net.ReadInt(32)
	if TeamInfo[3] then
	    TeamInfo[3].HoldTime = yellowTimeLeft
	end
	greenTimeLeft = net.ReadInt(32)
	if TeamInfo[4] then
	    TeamInfo[4].HoldTime = greenTimeLeft
	end
end )

net.Receive( "PlyClasses", function( len, pl )
	classes = net.ReadTable()
end )

net.Receive( "PlySwitchClass", function( len, pl )
	activeClass = net.ReadInt(32)
end )

net.Receive( "PlyIsAdmin", function( len, pl )
	isAdmin = net.ReadInt(32)
end )

net.Receive("chatprint", function(len)
	local r = net.ReadInt(10)
	local g = net.ReadInt(10)
	local b = net.ReadInt(10)
	local color = Color( r, g, b )
	local text = net.ReadString()
	
	chat.AddText( color, text )
end)

net.Receive("getMaps", function(len)
  -- open end game menu once we get the maps
  local Frame = vgui.Create( "DFrame" )
	Frame:SetPos( ScrW()/2 - 320, ScrH()/2 - 285 )
	Frame:SetSize(640, 485)
	Frame:SetTitle( "Game over!" )
	Frame:SetVisible( true )
	Frame:SetDraggable( false )
	Frame:ShowCloseButton( false )
	Frame:MakePopup()
	
  local wide = (Frame:GetWide() - 10) / math.min(5, table.getn(mapList))
  buttons = {} -- array of vote buttons
  for i=1, math.min(5, table.getn(mapList)) do
    local int = net.ReadInt(10)
    maps[int] = i
    local image = "darkland/map_images/image_not_found"
    if file.Exists("materials/darkland/map_images/"..mapList[int][1]..".vtf", "GAME") then
	  image = "darkland/map_images/"..mapList[int][1]
    --else if file.Exists("materials/darkland/map_images/"..mapList[int][1]..".png", "GAME") then
    --  image = 
	end
	local myImage = Frame:Add("DImageButton")--, Frame)
    myImage:SetImage( image )
    myImage:SetSize(128, 72)
    myImage:SetPos(4 + (i - 1) * wide, Frame:GetTall() - 100)
    myImage.DoClick = function() RunConsoleCommand("mapVote", int) end
    local bigImage
    myImage.OnCursorEntered = function(btn) 
      bigImage = Frame:Add("DImage")--, Frame)
      bigImage:SetImage(image)
      bigImage:SetSize(512, 288) 
      bigImage:SetPos(Frame:GetWide() / 2-bigImage:GetWide() / 2, 50)
    end
    myImage.OnCursorExited = function(btn) 
      bigImage:Remove( )
    end  

    local DermaButton = Frame:Add("DButton") --vgui.Create( "DButton", frame ) // Create the button and parent it to the frame
	DermaButton:SetText( mapList[int][1] )
	DermaButton:SetPos(4 + (i - 1) * wide, Frame:GetTall() - 18)
	DermaButton:SetSize( 128, 16 )
	DermaButton.DoClick = function()
		RunConsoleCommand( "mapVote", int )
	end
	DermaButton.numVotes = 0
	buttons[int] = DermaButton
    --local b = vgui.Create("DVoteButton", Frame)
    --b:SetSize(wide, 30)
    --b:SetPos(5 + (i - 1) * wide, Frame:GetTall() - 40)
    
    --b.mapType = maps[i]
    --b
    --b.DoClick = function() RunConsoleCommand("mapVote", int) end
    --b:SetText(mapList[int][1].." - "..b.numVotes)
  end
end)

net.Receive("getMapVote", function(len)
	local int = net.ReadInt(10) -- first int is map id
	local b = buttons[int] --endMenu.buttons[maps[int]]
	b.numVotes = b.numVotes + net.ReadInt(10) -- second int is +/1 vote power
	b:SetText(mapList[int][1].." - "..b.numVotes)
end)

function ToMoney( money )
  money = tostring( money )
  for i = #money - 3, 1, -3 do
     money = string.sub( money, 0, i ) .. "," .. string.sub( money, i + 1 )
  end
  return "$"..money
end
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile("cl_deathnotice.lua")
AddCSLuaFile("cl_scoreboard.lua")

include( "shared.lua" )
include("sv_funcs.lua")
include("sv_scoreboard.lua")
include("sv_funcs.lua")
include("sv_commands.lua")

------ TODO-------
-- Fix class store descriptions being cut off, and button positions
-- Admin menu features like ban, kick, sql console, etc (addcash implemented)
-- Addcash for prop damage
-- Fix team assignment (sometimes broken)
-- Fix prop dmg
-- Buy special abilities (class specific) & upgrades (class independent)
-- Round end screen (started, not completed), map vote, and honorable mentions
-- MOTD explaining gamemode rules
-- Fix class weapons:
-- Human is fine
-- Gunner, not sure
-- Ninja doesn't regen energy
-- Hitman scope doesn't render
-- Golem error
---------END TODO----
gamePhase = 0
gameTime = 300 -- build time left
ballId = 0 -- ent id of the ball
fightStarted = 0 -- used to track loadout & when to "intial" spawn plys for fight
wallDisabled = 0
BALL_MONEY = 10 -- 10 moneys per second the player is holding the ball
KILL_MONEY = 25 -- 25 moneys per second the player is holding the ball
MAP_VOTE_TIME = 30 -- 1 minute for end game map vote
TeamsThisMap = {}

superAdminSteamId = 'STEAM_0:0:19114120' -- cody8295 

winner = -1 -- 0 for blue, 1 for red, 2 for green, 3 for yellow

TeamInfo = {}
TeamInfo[1] = {
Spawn = "info_player_blue",
Present = false,
BoxCount = 0,
HoldTime = 120,
Name = "Blue"
}
TeamInfo[2] = {
Spawn = "info_player_red",
Present = false,
BoxCount = 0,
HoldTime = 120,
Name = "Red"
}
TeamInfo[3] = {
Spawn = "info_player_yellow",
Present = false,
BoxCount = 0,
HoldTime = 120,
Name = "Yellow"
}
TeamInfo[4] = {
Spawn = "info_player_green",
Present = false,
BoxCount = 0,
HoldTime = 120,
Name = "Green"
}

-- SQL DDL - Table setup scripts

function CreatePlyTable()
     if !sql.TableExists('Players') then
	     sql.Query( "CREATE TABLE Players( SteamID TEXT, Money INTEGER, IsBanned BIT, IsAdmin BIT )" )
     end
end

function CreatePlyWepTable() -- not used
     if !sql.TableExists('PlyWeps') then
	     sql.Query( "CREATE TABLE playerweps ( SteamID TEXT, WepId INTEGER )" )
     end
end

function CreatePlyClassTable() -- level 0 = no special. level 1 = special
     if !sql.TableExists('PlyClasses') then
	     sql.Query( "CREATE TABLE PlyClasses ( SteamID TEXT, ClassId INTEGER, level INTEGER, active BIT )" )
     end
end

function CreatePlySkillTable()
     if !sql.TableExists('PlySkills') then
	     sql.Query( "CREATE TABLE PlySkills ( SteamID TEXT, SkillId INTEGER, level INTEGER)" )
     end
end


-- End of SQL DDL

-- SQL ply operations (DML templates)


function InsertPly(ply, admin)
	 sql.Query( "INSERT INTO Players ( SteamID, Money, isBanned, isAdmin ) VALUES( '"..ply:SteamID().."', 2500, 0, " .. admin .. ")" )
end

function InsertPlyClass(ply, classId)
     -- first de-activate the currently active class
     sql.Query( "UPDATE PlyClasses SET active = 0 WHERE SteamID='"..ply:SteamID().."'") 
	  -- then insert the new one and mark it active
     sql.Query( "INSERT INTO PlyClasses ( SteamID, ClassID, level, active ) VALUES( '"..ply:SteamID().."', ".. classId ..",0,1 )" )
end

function SelectPly(ply)
      tbl = sql.Query( "SELECT DISTINCT ClassID, active FROM Players p INNER JOIN PlyClasses pc on p.SteamID = pc.SteamID WHERE p.SteamID = '".. ply:SteamID().."'"	  )
	  if !tbl then
		  -- sql error, not really sure what to do here
	  end
	  return tbl
end

function SavePlyMoney(ply, Money)
	 sql.Query( "UPDATE Players SET Money="..Money.." WHERE SteamID='"..ply:SteamID().."'" )
end

function SavePlyBanned(ply, banned)
	 sql.Query( "UPDATE Players SET IsBanned="..banned.." WHERE SteamID='"..ply:SteamID().."'" )
end

function SavePlyAdmin(ply, admin)
	 sql.Query( "UPDATE Players SET IsAdmin="..admin.." WHERE SteamID='"..ply:SteamID().."'" )
end

function SavePlyActiveClass(ply, classId)
	 --first deactivate all classes for this ply
	 sql.Query( "UPDATE PlyClasses SET active=0 WHERE SteamID='"..ply:SteamID().."'" )
	 -- then activate the class the client requested (and has)
	 sql.Query( "UPDATE PlyClasses SET active=1 WHERE SteamID='"..ply:SteamID().."' AND ClassID = "..classId )
end

function GetPlyCash(ply)
    return sql.QueryValue("SELECT Money FROM Players WHERE SteamID ='"..ply:SteamID() .."'")
	--return money
end

function GetPlySkill(ply, skillId)
    lvl = sql.QueryValue("SELECT level FROM PlySkills WHERE SteamID='"..ply:SteamID().."' AND SkillId = "..skillId)
    return lvl or 0
end

function SavePlySkill(ply, skillId, level)
     -- first find out if the ply has a record for this skill
	 tbl = sql.Query("SELECT * FROM PlySkills WHERE SteamID='"..ply:SteamID().."' AND SkillId = "..skillId)
	 if tbl then -- if they have the skill already, update the level
	     tbl = sql.Query("UPDATE PlySkills SET level = "..level.." WHERE SteamID = '"..ply:SteamID().."' AND SkillId="..skillId)
	 else -- they don't have the skill, insert it
	     tbl = sql.Query( "INSERT INTO PlySkills (SteamID, SkillId, level ) VALUES ('"..ply:SteamID().."', "..skillId..", " .. level .. ")"		 )
     end
end

function PlyHasSpecial(ply, classId)
    hasSpecial = sql.QueryValue("SELECT level FROM PlyClasses WHERE SteamID-'"..ply:SteamID().."' AND ClassID = "..classId)
	if !hasSpecial then return 0 end
	return tonumber(hasSpecial) == 1
end

function SavePlySpecial(ply, classId, level)
    sql.Query("UPDATE PlyClasses SET level = "..level.." WHERE SteamID='"..ply:SteamID().."' AND ClassID = "..classId)
end

function PlyActiveClass(ply)
	plyClasses = SelectPly(ply)
	if !plyClasses then return end
	for k,v in pairs(plyClasses) do
		if tonumber(v['active']) == 1 then -- found players active class
			plyClass = Classes[tonumber(v['ClassId'])]
			return plyClass
		end
	end	
end

function PlyActiveClassID(ply)
	plyClasses = SelectPly(ply)
	if !plyClasses then return end
	for k,v in pairs(plyClasses) do
		if tonumber(v['active']) == 1 then -- found players active class
			return tonumber(v['ClassId'])
		end
	end	
end
-- timer.Create( string identifier, number delay, number repetitions, function func )
function PlyTakeEnergy(ply, energy)
    ply:SetNWInt('energy', ply:GetNWInt('energy')-energy)
	plyClassID = PlyActiveClassID(ply)
	--print(plyClassID)
    --print(GetPlySkill(ply, plyClassID))
	--PrintTable(Skills[3]['LEVEL'])
    plyEnergyBonus = Skills[3]['LEVEL'][GetPlySkill(ply, plyClassID)]
	timerName = ply:SteamID() .. "." .. os.time() .. "."..math.random(1, 1000)
	timer.Create(timerName, 0.4, 15, function()
	    plyEn = ply:GetNWInt('energy')
		plyEnergyMax = 100 + plyEnergyBonus
		if plyEn < plyEnergyMax then -- skill[3][3]
		    plyAddEnergy = math.Clamp(3, 0, plyEnergyMax-plyEn)
			ply:SetNWInt('energy', plyEn + plyAddEnergy)
		else
		    timer.Remove( timerName )
		end
	end)
end


function SetupPly(ply) -- called when players first spawn
    tbl = SelectPly(ply)
	if !tbl then
	    -- setup new player with cash and class
		InsertPly(ply, 0) -- ply is not an admin
		InsertPlyClass(ply, 1) -- human is default class
	end
end
-- end of SQL ply ops

-- Begin networked strings and broadcast functions
util.AddNetworkString( "GamePhase" ) // 0 = waiting for players
                                     // 1 = build
									 // 2 = fight
								     // 3 = game over, vote on next map
util.AddNetworkString( "GameTime" ) // build time remaining
util.AddNetworkString( "GameWinner" ) // string of winning team name
util.AddNetworkString( "TeamCounts" ) // int representing how long each team has held balldrop
util.AddNetworkString( "PlyCash" ) 
util.AddNetworkString( "PlyClasses" ) 
util.AddNetworkString( "PlyClasses" )
util.AddNetworkString( "PlySwitchClass" )
util.AddNetworkString( "PlyIsAdmin" )
util.AddNetworkString( "initFW" )
util.AddNetworkString( "getMapVote" )
util.AddNetworkString( "getMaps" )
util.AddNetworkString( "cooldown" )

-- Directly from Darklands FW source---
			
//killfeed networking
util.AddNetworkString( "PlayerKilledByPlayers" )
util.AddNetworkString( "PlayerKilledSelf" )
util.AddNetworkString( "PlayerFallKilled" )
util.AddNetworkString( "PlayerKilledByPlayer" )
util.AddNetworkString( "PlayerKilled" )

resource.AddFile("materials/darkland/scope/scope.vmt")
resource.AddFile("materials/darkland/f1bg_temp.vmt")
resource.AddFile("materials/darkland/fortwars/ammohud1.vmt")
resource.AddFile("materials/darkland/fortwars/prophud1.vmt")
resource.AddFile("materials/darkland/fortwars/timerhud1a.vmt")
resource.AddFile("materials/darkland/fortwars/hud3.vmt")
resource.AddFile("materials/darkland/fortwars/timerBar.vmt")
resource.AddFile("materials/darkland/fortwars/user2.vmt")
resource.AddFile("materials/darkland/fortwars/itembg1.vmt")
resource.AddFile("materials/darkland/fortwars/propmenualt.vmt")
resource.AddFile("materials/darkland/pumpkin2.vmt")

----------------
--Sounds
---------------

resource.AddFile("sound/darkland/fortwars/bomberlol.mp3")
resource.AddFile("sound/darkland/rocket_launcher.mp3")
resource.AddFile("sound/darkland/fortwars/win9.mp3")
resource.AddFile("sound/darkland/fortwars/WinTest.mp3")
resource.AddFile("sound/darkland/freeze_cam.wav")
resource.AddFile("sound/weapons/hacks01.wav")
resource.AddFile("sound/darkland/fortwars/killingspree.wav")
resource.AddFile("sound/darkland/fortwars/rampage.wav")
resource.AddFile("sound/darkland/fortwars/dominating.wav")
resource.AddFile("sound/darkland/fortwars/unstoppable.wav")
resource.AddFile("sound/darkland/fortwars/wickedsick.wav")
resource.AddFile("sound/darkland/fortwars/godlike.wav")
resource.AddFile("sound/darkland/fortwars/multikill.wav")
resource.AddFile("sound/darkland/fortwars/ultrakill.wav")
resource.AddFile("sound/darkland/fortwars/monsterkill.wav")
resource.AddFile("sound/darkland/fortwars/ludricouskill.wav")
resource.AddFile("sound/darkland/fortwars/holyshit.wav")
resource.AddFile("sound/darkland/fortwars/ninja_dodge1.wav")
resource.AddFile("sound/darkland/fortwars/ninja_dodge2.wav")
resource.AddFile("sound/darkland/fortwars/ninja_dodge3.wav")
resource.AddFile("sound/darkland/fortwars/ninja_dodge4.wav")
resource.AddFile("sound/darkland/fortwars/chainlightning.wav")
resource.AddFile("sound/darkland/fortwars/sorcerer_seek.wav")
resource.AddFile("sound/darkland/fortwars/pumpkin.wav")
resource.AddFile("sound/darkland/fortwars/pumpkinlaunch.wav")
resource.AddFile("sound/darkland/fortwars/wickedmalelaugh1.wav")
resource.AddFile("sound/darkland/fortwars/wickedmalelaugh2.wav")
resource.AddFile("sound/darkland/fortwars/wickedmalelaugh3.wav")

--gotta have that chat sound :D
resource.AddFile("sound/darkland/chatmessage.wav")	

-- end Darklands FW original source for resources

function broadcastWinner()
    net.Start("GameWinner")
	net.WriteString(winner)
	net.Broadcast()
end

function broadcastTeamInfo()
	net.Start("TeamCounts")
	net.WriteInt(TeamInfo[1].HoldTime, 32)
	net.WriteInt(TeamInfo[2].HoldTime, 32)
	net.WriteInt(TeamInfo[3].HoldTime, 32)
	net.WriteInt(TeamInfo[4].HoldTime, 32)
	net.Broadcast()
end

function DisableWall()
    wallDisabled = 1
    if gamePhase == 2 then
		for k, v in pairs(ents.FindByClass("func_wall_toggle")) do
			v:SetColor(Color(0,0,0,0))
			v:SetNotSolid(true)
			v:SetNoDraw(true)
		end
	end
end

function DropBall()
	local balldrop = ents.FindByClass("balldrop")
	if gamePhase == 2 then
		ent = ents.Create("prop_physics")
		ent:SetModel("models/Roller.mdl")
		ent:SetName("ball")
		for _, t in pairs(ents.FindByClass("balldrop")) do	
			ent:SetPos(t:GetPos())
		end
		ent:Spawn()
		ent:GetPhysicsObject():EnableMotion(true)
		ent:GetPhysicsObject():Wake()
		ent:Activate()
		
		ballId = ent:EntIndex()
		--local rp = RecipientFilter()
		--rp:AddAllPlayers()
		--net.Start("ballentid")
		--net.WriteInt(ent:EntIndex(), 32)
		--net.Send(rp)
	end
end
			
function broadcastGameInfo()
    -- always broadcast the current game phase
    net.Start("GamePhase")
	net.WriteInt(gamePhase, 32)
	net.Broadcast()
	
	if gamePhase == 1 then -- build
	    gameTime = gameTime - 1
		
		-- only broadcast game/build time when it's build phase
		net.Start("GameTime")
		net.WriteInt(gameTime, 32)
		net.Broadcast()
	
		if gamePhase == 1 and gameTime == 0 then -- build time over
		    gamePhase = 2 -- fight
				
		end
	elseif gamePhase == 2 then -- fight..
		broadcastTeamInfo() -- communicate team counters only in fight phase
		
		for k, v in pairs(ents.FindByClass("spawn_marker")) do -- hide spawn points
			v:Disable()
		end
		
		for k, v in pairs(ents.FindByClass("ball_spawn")) do -- hide ghost ball
			v:Disable()
		end
		
		if fightStarted == 0 then -- respawn players when fight round starts, for weapons loadout
		    fightStarted = 1

			for k,v in pairs(player.GetAll()) do
			    v:StripWeapons() -- remove build weps
				v:Kill()
				v:Spawn()
			end
		end
		
		if wallDisabled < 1 || ballId == 0 then
		    DisableWall()
		    DropBall()
		end
		
		for k,v in pairs(TeamInfo) do
		    if TeamInfo[k].HoldTime == 0 then
			    winner = k
				SendMaps()
	            broadcastWinner() 
				gamePhase = 3
				timer.Simple(MAP_VOTE_TIME, function()
				    ChangeMap()
				end)
			end
		end
	elseif gamePhase == 3 then -- game over, vote on next map
		
	else -- waiting for more players, dont do anything
	
	end
end

function SendCashInfo(ply)
    plyCash = GetPlyCash(ply)
	net.Start("PlyCash")
	net.WriteInt(tonumber(plyCash), 32) 
	net.Send(ply)
end

function SendClassesInfo(ply)
    plyClasses = SelectPly(ply)
	
	--PrintTable(plyClasses)
	
	net.Start("PlyClasses") 
	net.WriteTable(plyClasses)
	net.Send(ply)
end

function SendActiveClass(ply, classId)
    plyClasses = SelectPly(ply) -- select distinct classid, active
	activeClass = 1 -- if the server is sending a class that the client doesnt have
	                -- we'll just switch the ply to Human (default)
					-- already enforced in switchClass, but just to be safe
	for k,v in pairs(plyClasses) do
	    -- if we passed a class id, and we have it, then switch to it
	    if !classId then
		    if tonumber(v['active'])==1 then
			    activeClass = tonumber(v['ClassId'])
			end
		else -- if we passed no class if, send the active class
		    if tonumber(v['ClassId'])==tonumber(classId) then
			    activeClass = tonumber(classId)
		    end
	    end
	end
	net.Start("PlySwitchClass")
	net.WriteInt(activeClass, 32)
	net.Send(ply)
end

function SendIsAdmin(ply)
	if ply:SteamID() ~= superAdminSteamId then return end
	
	net.Start("PlyIsAdmin") 
	net.WriteInt(1, 32)
	net.Send(ply)
end

local maps = {}
function SendMaps()
	while (#maps<5) do
		local map = math.random(1,#mapList)
		if (!table.HasValue(maps,map)) then
			table.insert(maps,map)
		end
	end
	net.Start( "getMaps" )
	for i=1,5 do
		net.WriteInt(maps[i], 10)
	end
	net.Broadcast()
end

-- end network stuff and broadcast functions

function ChangeMap()
	table.sort(mapList,function(a,b) return a.votes > b.votes end)
	print("changelevel "..mapList[1][1].."\n")
	game.ConsoleCommand("changelevel "..mapList[1][1].."\n")
end

-- Hooks
--function GM:ShowTeam(ply)
--	ply:ConCommand("fw_leaderboards")
--end

-- directly from Darkland FW
function SetColor( ply, color )
	ply:SetPlayerColor( Vector( color.r/255, color.g/255, color.b/255 ) )
end

function assignPlayerTeam(ply)
  if !IsValid(ply) or ply:Team() == (1 or 2 or 3 or 4) then
      ply:ChatPrint("Ply is already on team: " .. ply:Team())
      return
  end -- he picked a team already
  
  local t = {}
  --t[1] = 1
  for i, v in pairs(TeamInfo) do 
    if v.Present then 
      table.insert(t, i) 
    end 
  end
  
  print("Finding team")
  if t then
	  PrintTable(t)
	  print ("Found team table^")
  else
      print ("Didn't find team table!") 
	  while !t || !t[1] do
	      print("Waiting for spawns to load")
	  end
   end
  table.sort(t, function(a, b) return team.NumPlayers(a) < team.NumPlayers(b) end)
  ply:UnSpectate()
  ply:SetTeam(t[1])
  local c = team.GetColor(t[1])
  ply:SetColor(Color(c.r, c.g, c.b, c.a))
  
  SetColor( ply, c )
  --players[ply:SteamID()] = t[1]
  --ply:Kill()
  
  ply:Spawn()
  ply:SetDeaths(0)
  
  hook.Call("PlayerJoinedTeam", GAMEMODE, ply)
end

hook.Add( "PlayerSay", "ChatSound", function( ply, text, teamchat )

	----------------------
	--How do I X...
	----------------------

	--if string.lower(string.sub( text, 1, 8 )) == "how do i" or string.lower(string.sub( text, 1, 10 )) == "how do you"  then
		--for k, v in pairs(ChatCommands) do
		--	print(k)
		--end
	
	--	timer.Simple(.1, function()
	--		ply:ChatPrint("Most questions can be answered by reading the help tab in the f1 menu")
	--	end)
	--end
	
	----------------------
	--Chat sounds
	----------------------
	
	if string.sub( text, 1, 1 ) == "/" or string.sub( text, 1, 1 ) == "!" then return end
	if teamchat then
		for k, v in pairs(player.GetAll()) do
			if v:Team() == ply:Team() then
				if v:GetInfo( "fw_chatsounds" ) == "1" then v:SendLua( [[surface.PlaySound( "darkland/chatmessage.wav" )]] ) end
			end
		end
	else
		for k, v in pairs(player.GetAll()) do
		
		if v:GetInfo( "fw_chatsounds" ) == "1" then v:SendLua( [[surface.PlaySound( "darkland/chatmessage.wav" )]] ) end
			
		end				
	end
end)

---------------------
--Drowning
---------------------
function GM:HandlePlayerSwimming(ply)
  if !IsValid(ply) then return end 

  if ply.timerrunning == nil then
    ply.timerrunning = false
  end

  if !timer.Exists(ply:SteamID().."delay") then
   // ply.DrownUpgrade = ply.Skills[6]
    timer.Create(ply:SteamID().."delay", 5, 1, function() StartDrown(ply) end )
    timer.Stop(ply:SteamID().."delay")
  end
  
  if !timer.Exists(ply:SteamID().."timer") then
    timer.Create(ply:SteamID().."timer", 1, 0, function() Drown(ply) end)
    timer.Stop(ply:SteamID().."timer")
  end
  
  if !DM_MODE and ply.timerrunning then
    timer.Stop(ply:SteamID().."delay")
    timer.Stop(ply:SteamID().."timer")
    ply.timerrunning = false
    return
  end
    
  if ply:WaterLevel() == 3 and !ply.timerrunning and DM_MODE then
    timer.Start(ply:SteamID().."delay")
    ply.timerrunning = true
  elseif ply:WaterLevel() != 3 and ply.timerrunning and DM_MODE then
    timer.Stop(ply:SteamID().."delay")
    timer.Stop(ply:SteamID().."timer")
    ply.timerrunning = false
  end
end

--Starts the drown timer which ticks every second
function StartDrown(ply)
  if !IsValid(ply) then return end
  if timer.Exists(ply:SteamID().."timer") then
    timer.Start(ply:SteamID().."timer")
  end
end

-- Takes away 12 hp if the player is underwater and simulates a drowning effect.
function Drown(ply)
  if !ply:IsValid() then return end
  if ply:WaterLevel() == 3 and DM_MODE then
    local dmginfo = DamageInfo()
    dmginfo:SetDamage(12)
    dmginfo:SetDamageType(DMG_DROWN)
    dmginfo:SetAttacker(game.GetWorld())
    dmginfo:SetInflictor(ply)
    ply:TakeDamageInfo(dmginfo) 
    
    if ply:Health() <= 0 and timer.Exists(ply:SteamID().."timer") then
      timer.Stop(ply:SteamID().."delay")
      timer.Stop(ply:SteamID().."timer")  
      ply.timerrunning = false
    end
  end
end
---------------------
--End drowning
---------------------

-- end original Darkland FW source

hook.Add( "PlayerSay", "PlayerSayExample", function( ply, text, team )
	if ply:SteamID() == superAdminSteamId then
		return "[Admin] " .. text
	else return text end
end )

--function GAMEMODE:EntityTakeDamage(ent, inflictor, attacker, amount) --it was fucked up during beta so i decided this would work plus its more customizable
--	if DM_MODE == false then return false end
--	 if inflictor:IsPlayer() then
--		currentweapon = inflictor:GetActiveWeapon():GetClass()
--		if currentweapon == "weapon_pistol" then
--			amount = 3
--		elseif currentweapon == "weapon_smg1" then
--			amount = 2
--		elseif currentweapon == "weapon_ar2" then
--			amount = 7
--		elseif currentweapon == "weapon_357" then
--			amount = 20
--		elseif currentweapon == "weapon_shotgun" then
--			amount = 70
--		end
--	end
--	ent:SetHealth(ent:Health() - amount)
--	if ent:Health() <= 0 then
--		ent:GibBreakServer( )
--	end
--	return true
--end

function GM:EntityTakeDamage( ply, dmginfo )
	local inflictorType = dmginfo:GetInflictor():GetClass()
	local inflictor = dmginfo:GetInflictor()
	local attacker = dmginfo:GetAttacker()
	local amount = dmginfo:GetDamage()
	
    if ( ply:IsPlayer() and dmginfo:GetDamageType() == DMG_CRUSH and ( dmginfo:GetInflictor():GetClass() == "swatnade"  or dmginfo:GetInflictor():GetClass() == "sent_rpgrocket" ) 
	) then
	
        dmginfo:ScaleDamage( 0 )
	
	elseif ply:GetNWBool("outtamyway") == true and ply:IsPlayer() then
		dmginfo:ScaleDamage( .5 ) 
			
	// temp gunner special
	
	elseif ply:IsPlayer() and ply:GetActiveWeapon():GetClass() == "gunner_gun" and dmginfo:IsBulletDamage() and ply:HasSpecial(2) then
	
		--ply:TakeEnergy(amount*1.5)
	    PlyTakeEnergy(ply, amount*1.5)
		if ply:GetNWInt('energy') > 0 then
			dmginfo:ScaleDamage(0)
			ply:EmitSound(Sound("darkland/fortwars/ninja_dodge"..tostring(math.random(1, 4))..".wav"), 100, 100)			
		else
			dmginfo:ScaleDamage(1)
		end
    end
		propTeam = ply.Team -- nil for anything other than props
		if propTeam and inflictor:IsPlayer() then -- prop dmg
            --print("Prop dmg")
			if propTeam == inflictor:Team() then
				dmginfo:ScaleDamage(0)
			else
			    --print("Prop dmg - opp team")
				dmginfo:ScaleDamage(1)
				propMaxHealth = ply.MaxHealth
				if propMaxHealth then 
					propHealth = ply:Health() 
					propColor = ply:GetColor()
					healthPerc = propHealth / propMaxHealth
					propR = math.floor(propColor.r * healthPerc)
					propG = math.floor(propColor.g * healthPerc)
					propB = math.floor(propColor.b * healthPerc)
					ply:SetColor(propR, propG, propB)
					
					amount = dmginfo:GetDamage()
					ply:SetHealth(ply:Health() - amount)
					if ply:Health() <= 0 then
						ply:GibBreakServer( dmginfo:GetDamageForce() )
						ply:Remove()
					end
				end
			end
	    end
	
    return dmginfo
	
end

function GM:PlayerDeath(victim,weapon,killer)
	
	victim.damagetaken = 0
	victim.currentLifeKills = 0
	victim.respawntime = CurTime() + 3
	print(victim.myassistor)
	
	if IsValid(killer.LastHolder) then killer = killer.LastHolder end
	
	if (killer == victim) and IsValid(victim.myassistor) then
			killer = victim.myassistor
	end
			
	if (killer:IsWorld() and IsValid(victim.myassistor)) then
			killer = victim.myassistor
			//addKillMoney(killer)
	end
	
	
	if (victim.myassistor != killer and IsValid(victim.myassistor) and IsValid(killer) and  killer != victim and victim.lastattack > CurTime()) then
	
		victim.myassistor:SetNWInt("Assists", victim.myassistor:GetNWInt("Assists")+1)
		victim.myassistor.stats[2] = victim.myassistor.stats[2] + 1
		victim.myassistor:AddMoney(ASSIST_MONEY)
	
	
		if (killer != victim ) then
			killer:AddFrags(1)		
		end
	
	timer.Simple(1.5,function()self:FreezeCam(victim,killer)end)
    net.Start("PlayerKilledByPlayers")
      net.WriteEntity(victim)
      local str = killer:GetActiveWeapon()
      if str:IsValid() then 
        str = str:GetClass() 
      else 
        str = "" 
      end
      net.WriteString(str)
      net.WriteEntity(killer)
      net.WriteEntity(victim.myassistor)
    net.Broadcast()
	
  return end
	
	if (killer == victim) then
	
		if IsValid(victim.myassistor) then
			victim.myassistor:AddFrags(1)
		else
	
		victim.Suicides = (victim.Suicides or 0) + 1
		net.Start( "PlayerKilledSelf" )
			net.WriteEntity( victim )
		net.Broadcast()
		
		end
	
	return end
	
	if (killer:IsWorld()) then

		net.Start( "PlayerFallKilled" )
			net.WriteEntity( victim )
		net.Broadcast()	
		
	return end

	if ( killer:IsPlayer() ) then

		--addKillMoney(killer)
		killerCash = GetPlyCash(killer)
		SavePlyMoney(killer, killerCash + KILL_MONEY) 
		SendCashInfo(killer)
		killer:AddFrags(1)
		killer.currentLifeKills = killer.currentLifeKills + 1
		killer.multiKills = killer.multiKills + 1
		killer.stats[1] = killer.stats[1] + 1
		
    if killer.killTime + 4 > CurTime() then -- check for multi kill
	
      if utSounds.multiKills[killer.multiKills] then -- play a multi kill sound   
		for k,v in pairs(player.GetAll()) do 
			v:ConCommand( "play " .. (utSounds.multiKills[killer.multiKills].SOUND))
		end           
		if IsValid(killer) then PrintMessage(HUD_PRINTCENTER, killer:Nick().." "..utSounds.multiKills[killer.multiKills].DESC) end               
      end
	  
    else  
	
      if utSounds.killingSprees[killer.currentLifeKills] then
        if IsValid(killer) then PrintMessage(HUD_PRINTCENTER, killer:Nick().." "..utSounds.killingSprees[killer.currentLifeKills].DESC) end			
		for k,v in pairs(player.GetAll()) do 
			v:ConCommand( "play " .. (utSounds.killingSprees[killer.currentLifeKills].SOUND))
		end
      end
		killer.multiKills = 0
    end
    lastPrintMessage = CurTime()
    killer.killTime = CurTime()
		
		
		timer.Simple(1.5,function()self:FreezeCam(victim,killer)end)
		
		net.Start( "PlayerKilledByPlayer" )	
			net.WriteEntity( victim )
			local str = killer:GetActiveWeapon()
			if str:IsValid() then str = str:GetClass() else str = "" end
			net.WriteString( str )
			net.WriteEntity( killer )
		net.Broadcast()
	
	return end
	
	net.Start( "PlayerKilled" )
		net.WriteEntity( victim )
		net.WriteString( weapon:GetClass() )
		net.WriteString( killer:GetClass() )
	net.Broadcast()
end

function GM:DoPlayerDeath( ply, attacker, dmginfo )
	ply:CreateRagdoll()
	ply:AddDeaths( 1 )
end

function GM:PlayerShouldTakeDamage(victim, attacker)
	if gamePhase < 2 then return false -- if waiting or building, don't take dmg
	
	elseif gamePhase > 1 then -- if fighting or end game
	
		if victim:IsPlayer() and attacker:IsPlayer() then
		
			if victim:Team() == attacker:Team() then
				return false
			
			elseif victim:Team() != attacker:Team() then
				return true
			end
			
		elseif victim:IsPlayer() and attacker:GetName() == "ball" then
			if attacker.LastHolder:Team() != victim:Team() then 
				return true else return false
			end
		else 
			return true 
		end
	end
end

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )

	--More damage if we're shot in the head
	 if ( hitgroup == HITGROUP_HEAD ) then
	 
		if dmginfo:GetAttacker():GetActiveWeapon():GetClass() == "sorcerer_gun" then
			dmginfo:ScaleDamage( 1.43 )
		else
			dmginfo:ScaleDamage( 2 )
		end
	 
	-- Less damage if we're shot in the arms or legs
	elseif ( hitgroup == HITGROUP_LEFTARM ||
		 hitgroup == HITGROUP_RIGHTARM || 
		 hitgroup == HITGROUP_RIGHTLEG ||
		 hitgroup == HITGROUP_LEFTLEG ||
		 hitgroup == HITGROUP_GEAR ) then
	 
		dmginfo:ScaleDamage( 0.65 )
		
	elseif ( hitgroup == HITGROUP_STOMACH ||
		hitgroup == HITGROUP_CHEST) then
			
		dmginfo:ScaleDamage( 1 )
	 end
end

hook.Add( "PlayerNoClip", "FWFlyNoclipPlayerNoClip", function( ply )
  if gamePhase > 1 then return false end -- if fight or endgame, then nope
  
  --if ply:IsAdmin() then return true -- admins always can noclip
  
  --end
  --if ply:IsPlatinum() then
    if ply:GetMoveType() == MOVETYPE_FLY then
      ply:SetMoveType( MOVETYPE_WALK )
    else
      ply:SetMoveType( MOVETYPE_FLY )
    end
    return
  --end
end)

function GM:GravGunOnPickedUp(ply, ent)
	local PlayerTeam = ply:Team()
	--PrintMessage(HUD_PRINTCENTER, ent:GetName())
	--PrintMessage(HUD_PRINTCENTER, TeamInfo[PlayerTeam].Name .. " team has picked up the ball!")
	if ent:GetName() == "ball" and gamePhase == 2 then -- fighting
		
		ent.LastHolder = ply
		--ballcarrier = ply
		--ballcarrier:SetNWBool("carrying", true)
		
		timer.Create("balltimer", 1, 0, function()
			if gamePhase == 2 then
				TeamInfo[PlayerTeam].HoldTime = TeamInfo[PlayerTeam].HoldTime - 1
				ply.BallSecs = ply.BallSecs + 1
				ply.stats[3] = ply.stats[3] + 1
				
				plyCash = GetPlyCash(ply)
				SavePlyMoney(ply, plyCash + BALL_MONEY)
				SendCashInfo(ply)
				--ballcarrier.MoneyEarned = ballcarrier.MoneyEarned + (BALL_MONEY)				
				
				
				--if (TeamInfo[PlayerTeam].HoldTime <= 0) then
				--	gamePhase = 3 -- games over
				--	winner = PlayerTeam
				--end
			end	
		end)
		
		--elseif (ent:GetClass() == "nade" or ent:GetClass() == "sent_rpgrocket" or ent:GetClass() == "swatnade") and DM_MODE == true then
		--	ent.LastHolder = ply
		end
end

function GM:GravGunOnDropped(ply, ent)		
	if ent:GetName() == "ball" then
		local PlayerTeam = ply:Team()
		--PrintMessage(HUD_PRINTCENTER, TeamInfo[PlayerTeam].Name .. " team has dropped the ball!")
	
		timer.Destroy("balltimer")
	end
end

function CheckMapCompatibility() --change level if incompatible
	local exists = ents.FindByClass("balldrop")[1] != nil
	if !exists then -- FIx this
		--game.ConsoleCommand("changelevel "..mapList[math.random(1,#mapList)][1].."\n")
	    PrintMessage(4, "Map is not comptatible")
	end
end

function GM:InitPostEntity()
	CheckMapCompatibility()
	--Now count the number of valid teams
	print("Checking for teams...")
	local num = 0
	for i,v in pairs(TeamInfo) do
		local tbl = ents.FindByClass(v.Spawn)
		
		-- trying this here (instead of after the loop
        -- to resolve intermittent issue on game-start
		-- when a client spawns before TeamInfo[x].Spawns is set. - cody8295
		TeamInfo[i].Spawns = tbl --Hold a table of all the spawns so we don't have to find them everytime we spawn
		
		if tbl[1] then 
		    print("Found team!"..i)
			num=num+1 
			TeamInfo[i].Present = true
			
			for ii,v in pairs(tbl) do
				timer.Simple(ii*0.1,function()
					local tr = util.TraceLine({start = v:GetPos()+Vector(0,0,46), endpos = v:GetPos()+Vector(0,0,-1000), filter = v})
					if tr.Hit then v:SetPos(tr.HitPos+Vector(0,0,10)) end
					local ent = ents.Create("spawn_marker")
					local ang = v:GetAngles()
					ent:SetPos( v:GetPos() )
					ent:SetAngles( Angle( 0, ang.y, 0 ) )
					ent.color = team.GetColor( i )
					ent:Spawn()
					ent:Activate()
					v.blocker = ent
					v.blocker:SetNotSolid(true)
				end)
			end
		end
		--TeamInfo[i].Spawns = tbl --Hold a table of all the spawns so we don't have to find them everytime we spawn
	end
	
  for i, v in pairs(ents.FindByClass("balldrop")  ) do
    local ent = ents.Create("ball_spawn")
    ent:SetPos(v:GetPos())
    ent:SetAngles(v:GetAngles())
    ent:Spawn()
    ent:Activate()
  end
	
end

function PhysgunPickup( pl, ent )
	if !(ent:GetClass() == "prop") and !(ent:GetClass():lower() == "player")  then return false end
	
	if ent:IsPlayer() then		
		if pl:SteamID() == superAdminSteamId then
			ent:SetMoveType( MOVETYPE_NONE )
			return true
		else
			return false
		end
	end

	if !ent.Spawner then return end
	if ent.Spawner == pl then
		ent:SetColor(Color(255,255,255,255)) 
		return true 
	end
	
	if pl:SteamID() == superAdminSteamId and IsValid(ent.Spawner) then 
		pl:PrintMessage(4,"This prop belongs to "..ent.Spawner:Name()) 
		ent:SetColor(Color(255,255,255,255)) 
		return true 
	end
	
	if !IsValid(ent.Spawner) then 
		pl:PrintMessage(4,"The owner of this prop is gone, it is now yours")
		--table.insert(pl.createdProps, ent)		
		ent.Spawner = pl
		ent.Team = pl:Team()
		ent:SetColor(Color(255,255,255,255))
		return true 
	end
	
	pl:PrintMessage(4,"This prop belongs to "..ent.Spawner:Name())
	return false
end
hook.Add( "PhysgunPickup", "phys", PhysgunPickup )

function GM:PlayerSwitchFlashlight(ply, SwitchOn)
     return true
end

function GM:PhysgunDrop( ply, ent )
	ent:GetPhysicsObject():EnableMotion(false)
	if ent:IsPlayer() then
		ent:SetMoveType( MOVETYPE_WALK )
	end
end
	
function PhysUnfreeze( ply, ent, phys )
		return false
end
hook.Add( "CanPlayerUnfreeze", "PhysUnfreeze", PhysUnfreeze )

function GM:PlayerConnect( name, ip )
	PrintMessage( HUD_PRINTTALK, name .. " has joined the game." )
end

function GM:PlayerSelectSpawn( pl )
  if pl.SpawnPoint then 
    return pl.SpawnPoint 
  end
	local tbl = TeamInfo[pl:Team()]
	if !tbl then return nil end --They have not loaded, spawn them in noclip underground
	if !tbl.Spawns then return nil end
	local v = tbl.Spawns[math.random(#tbl.Spawns)]
	if (v) then return v end
	return tbl.Spawns[1]
end

function GM:PlayerInitialSpawn( ply )
	SetupPly(ply) -- if the ply doesn't exist in our DB, insert them
	SendCashInfo(ply) 
	SendClassesInfo(ply)
	SendActiveClass(ply)
	SendIsAdmin(ply) -- player will have to reconnect if theyre made admin
					-- before they see admin panel, no need to send every spawn
    DEFAULT_STATS = {0, 0, 0, 0, 0, 0, 0}
    ply.stats = DEFAULT_STATS
    ply.upgrades = {0, 0, 0, 0, 0, 0, 0, 0}
	
	ply.name = ply:Nick()
	
	ply.BallSecs = 0
	ply.Suicides = 0
	ply.MoneyEarned = 0
	ply.ProppedMoney = 0
	ply.BuildingDamage = 0
	ply.Headshots = 0
	ply.TeirProgressEarned = 0
	ply.Messages = 0
	ply.LastPlayerKillTime = {}
	ply.damagetaken = 0
	ply.createdProps = {}
	ply.lastLeft = CurTime()
	ply.lastRight = CurTime()
	ply.energy = 0 
    ply.currentLifeKills = 0
	ply.multiKills = 0
	
	plyClass = PlyActiveClass(ply)
		
	ply:SetWalkSpeed( plyClass.SPEED)
	ply:SetRunSpeed(ply:GetWalkSpeed() )
	ply:SetHealth(plyClass.HEALTH)
	ply:SetMaxHealth( plyClass.HEALTH)
	ply:SetModel( plyClass.MODEL )
	ply:SetJumpPower( plyClass.JUMPOWER )
	if gamePhase == 2 then
	    ply:Give(plyClass.WEAPON )
	end
	ply:SetNWInt('energy', 100) --+ Skills[3]
	
	print("Teams  here!")
	PrintTable(TeamInfo)

	print("Teams  end!")
	for k,v in pairs(TeamInfo) do 
		if v.Present then 
			table.insert(TeamsThisMap, k)
		end 
	end
	print("Teams array here!")
	PrintTable(TeamsThisMap)

	print("Teams array end!")
	net.Start("initFW")
	for i,v in pairs(TeamsThisMap) do
		net.WriteInt(v, 32)
	end
	net.WriteInt(0, 32)
	net.Send(ply)
	
	timer.Simple(2, function() -- wait for spawn points to be detected
		   assignPlayerTeam(ply)
	end)
	
	
		
end

function GM:PlayerSpawn(ply, transition)
    if gamePhase == 0 and player.GetCount() >= 2 then -- if 2 or more people are on the server
	    gamePhase = 1 -- then start the build phase
	end
	
	SendCashInfo(ply) 
	SendClassesInfo(ply)
	
	if gamePhase == 0 or gamePhase == 1 then -- building or waiting for players
		ply:Give("weapon_physgun")
		ply:Give("prop_creator")
		ply:Give("prop_remover")
		ply:Give("fw_spawngun")
		
		plyClass = PlyActiveClass(ply)
		
		ply:SetWalkSpeed( plyClass.SPEED)
		ply:SetRunSpeed(ply:GetWalkSpeed() )
		ply:SetHealth(plyClass.HEALTH)
		ply:SetMaxHealth( plyClass.HEALTH)
		ply:SetModel( plyClass.MODEL )
		ply:SetJumpPower( plyClass.JUMPOWER )
		--ply:Give(plyClass.WEAPON ) no weps during build
		ply:SetNWInt('energy', 100) --+ Skills[3].LEVEL[ply.upgrades[3]])
		
	elseif gamePhase == 2 then -- fight
		ply:Give("weapon_physcannon") -- all classes get a phys cannon
		--plyClasses = SelectPly(ply)
		plyClass = PlyActiveClass(ply)
		
		ply:SetWalkSpeed( plyClass.SPEED)
		ply:SetRunSpeed(ply:GetWalkSpeed() )
		ply:SetHealth(plyClass.HEALTH)
		ply:SetMaxHealth( plyClass.HEALTH)
		ply:SetModel( plyClass.MODEL )
		ply:SetJumpPower( plyClass.JUMPOWER )
		ply:Give(plyClass.WEAPON )
		ply:SetNWInt('energy', 100) --+ Skills[3].LEVEL[ply.upgrades[3]])
		
	end
	
    if ply.SpawnAng then -- from spawn gun
      ply:SetEyeAngles(ply.SpawnAng)
    end
end

function GM:PlayerDisconnected(ply)
   if IsValid(ply.SpawnPoint) then
     ply.SpawnPoint:Remove()
   end
end


function GM:PlayerHurt(victim, attacker, hprem, dmgtoply)
	---local threshold = victim:GetMaxHealth()*.4

-- must do at least 40% damage to get assist
------------------------------------------------------------------------
--Assign assistor
------------------------------------------------------------------------
-- Need damage to be player specific

	--if attacker:IsPlayer() then
	--
	--	local attid = attacker:UserID()
	--	local victid = victim:UserID()
	--	--victim.damagetaken = victim.damagetaken+dmgtoply
	--	
	--	--DamagedPlayers[attid] = {[victid] = victim.damagetaken}
	--
	--	--attacker:SetNWInt("dmgtoplayer", DamagedPlayers[attid][victid])
	--	--print(attacker:GetNWInt("dmgtoplayer"))
	--
	--	if attacker:IsPlayer() and attacker ~= victim then
	--		if victim:Team() ~= attacker:Team() and attacker:GetNWInt("dmgtoplayer") >= threshold and victim:Health() > 0 then
	--  
	--			if victim.myassistor == nil then victim.myassistor = attacker end
	--			
	--			print(victim.myassistor)
	--			
	--			victim.lastattack = CurTime() + 5
	--
	--		end
	--	end
	--end
------------------------------------------------------------------------
--End assists
------------------------------------------------------------------------
	
	if attacker:IsPlayer() and attacker:GetActiveWeapon():GetClass() == "pred_gun" then
		attacker:EmitSound(Sound("weapons/knife/knife_hit"..math.random(1,4)..".wav"))
	end
	
end

function GM:Initialize()
    CreatePlyTable()
    CreatePlyClassTable()
	--CreatePlyWepTable() -- not used, remove	
	CreatePlySkillTable()

	-- send general game info like phase every second
	timer.Create( "GameTimer", 1, 0, broadcastGameInfo )
end

hook.Add( "PhysgunPickup", "AllowPlayerPickup", function( ply, ent )
	if ent:GetClass() == "prop" && ply.Spawner == ply then -- == ply || ply:IsAdmin())  then
		return true
	else
	    return false
	end
end )

-- -- -- -- -- end hooks -- -- -- -- --

-- Functions pulled directly from Darklands fortwars --
/*---------------------------------------------------------
Converts a string to a vector and returns it
---------------------------------------------------------*/
function toVector(str)
  local vector = string.Explode(" ", str)
  return Vector(vector[1], vector[2], vector[3])
end

/*---------------------------------------------------------
Converts a string to an angle and returns it
---------------------------------------------------------*/
function toAngle(str)
  local angle = string.Explode(" ", str)
  return Angle(angle[1], angle[2], angle[3])
end
 -- -- -- end functions from DL Fortwars -- -- -- -- --
 
 -- -- -- -- ConCommands -- -- -- -- -- --
function buildProp(ply, cmd, args)
  ply.LastSpawnProp = ply.LastSpawnProp or 0
  if ply.LastSpawnProp > CurTime() then
    return
  end
  local tbl
  
  -- if string.find(args[1], "B") then
  --  args[1] = string.sub(args[1], 0, 1)
  --  args[1] = tonumber(args[1])
  --  if !buyableProps[args[1]] or !table.HasValue(ply.props, args[1]) then return end
  --  tbl = buyableProps[args[1]]
  --else
  tbl = PropList[tonumber(args[1])]
  --end
  
  if !tbl then return end
  
  plyCash = GetPlyCash(ply)
  
  if !plyCash then return end -- shouldn't ever happen
  
  if tbl.PRICE > tonumber(plyCash) then
      ply:EmitSound(Sound("buttons/button19.wav")) 
	  ply.LastSpawnProp = CurTime()+0.75 
	  return
  end
  
  local tr = {}
  tr.start = ply:GetShootPos()
  tr.endpos = tr.start + ply:GetAimVector() * 300
  tr.filter = ply
  local trace = util.TraceLine(tr)
  if trace.Fraction == 0 then 
    ply:EmitSound(Sound("buttons/button19.wav")) 
    ply.LastSpawnProp = CurTime()+0.75 
    return 
  end
  
  if trace.Hit  then
    local ent = ents.Create("prop")
    ent:SetModel(tbl.MODEL)
    ent:SetPropTable(tbl)
    ent.Team = ply:Team()
    ent:SetNWInt("Team", ply:Team())
    --local c = team.GetColor(ent.Team)
	ent:SetColor(team.GetColor(ply:Team()))
    ent:SetPos(toVector(args[3]))
    ent:SetAngles(toAngle(args[2]))
    ent.Spawner = ply
	ent:SetHealth(tbl.HEALTH)
	ent.MaxHealth = tbl.HEALTH
    ent:SetNWEntity("Spawner", ply)
	ent:PrecacheGibs() 
    ent:Spawn()
    ent:EmitSound(Sound("plats/crane/vertical_stop.wav"))
	--table.insert(ply.createdProps, ent)


	
    SavePlyMoney(ply, tonumber(plyCash) - tbl.PRICE)
	SendCashInfo(ply)
    ply.LastSpawnProp = CurTime() + 0.75
	
  end
end
concommand.Add("createprop", buildProp)

function buyClass(ply, cmd, args)
      classId = tonumber(args[1])
	  
	  if !classId || !Classes[classId] then -- client sent an invalid class id
              ply:PrintMessage(HUD_PRINTTALK, "Invalid class ID!")
		      ply:EmitSound(Sound("buttons/button19.wav")) 
		return
	  end
	  
	  plyClasses = SelectPly(ply)
	  
	  for k,v in pairs(plyClasses) do
	      if tonumber(v['ClassId'])==classId then  -- don't let players buy classes they already have
			  ply:PrintMessage(HUD_PRINTTALK, "You already have this class!")
		      return
		  end 
	  end
	  
      plyCash = GetPlyCash(ply)
  
      if !plyCash then
	      ply:PrintMessage(HUD_PRINTTALK, "SQL error when looking up your account!")
	      return-- shouldn't ever happen
	  end 
	  
	  classPrice = Classes[classId].COST
	  
	  if !classPrice then -- shouldn't happen either
	      ply:PrintMessage(HUD_PRINTTALK, "Error finding class price!")	      
	      return
	  end 

	  if tonumber(plyCash) < classPrice then 
	      ply:PrintMessage(HUD_PRINTTALK, "Not enough money!")	      
	      ply:EmitSound(Sound("buttons/button19.wav")) 
	      return
	  end
	  
	  InsertPlyClass(ply, classId)
	  SavePlyMoney(ply, plyCash - classPrice)
	  SendClassesInfo(ply)
	  SendCashInfo(ply)
	  SavePlyActiveClass(ply, classId)
	  SendActiveClass(ply, classId)
	  ply:PrintMessage(HUD_PRINTTALK, "You bought: " .. Classes[classId].NAME .. "!")
end
concommand.Add("buyclass", buyClass)

function addCash(ply, cmd, args) 
	  if ply:SteamID() ~= superAdminSteamId then return end
	  -- only allow Cody8295 to add cash, will fix to all admins later

      PrintTable(args)

      pl = Player(args[2]) -- addcash 500 1 (adds $500 to user id 1)
	  --PrintMessage(4, pl:SteamID())
	  if !pl then return end -- invalid user id
	  
      plyCash = GetPlyCash(pl)
      if !plyCash then return end -- shouldn't ever happen

      cashToAdd = tonumber(args[1])
	  if !cashToAdd then return end -- might happen if I/we type in NaN

	  SavePlyMoney(pl, plyCash + cashToAdd)
	  SendCashInfo(pl)
end
concommand.Add("addcash", addCash)


function switchClass(ply, cmd, args) 
	  classId = tonumber(args[1])
	  
	  if !classId || !Classes[classId] then -- client sent an invalid class id
        ply:EmitSound(Sound("buttons/button19.wav")) 
		return
	  end
	  
	  plyClasses = SelectPly(ply)
	  
	  for k,v in pairs(plyClasses) do
	      if tonumber(v['ClassId'])==classId then -- only let client switch to class if they have it
		  	  SavePlyActiveClass(ply, classId)
			  SendActiveClass(ply, classId)
		  end 
	  end
end
concommand.Add("switchclass", switchClass)

function adminSql(ply, cmd, args) 
     if ply:SteamID() ~= superAdminSteamId then return end
	 if !args[1] then return end
	 -- only super admins should be able to do this, basically a SQL console
	 tbl = sql.Query(args[1])
	 errord = 0
	 errorTxt = ''
	 if !tbl then
	     ply:ChatPrint("SQL error")
		 ply:ChatPrint(sql.LastError()) 
     else
	    ply:ChatPrint("SQL success")
		PrintTable(tbl)
	 end
end
concommand.Add("adminsql", adminSql)

function adminChangeRound(ply, cmd, args) 
     if ply:SteamID() ~= superAdminSteamId then return end
	 if !args[1] then return end
	 -- only super admins should be able to do this, manually changes the buildphase
	 gamePhaseRequested = tonumber(args[1])
	 if gamePhaseRequested < 0 or gamePhaseRequested > 3 then return end
	 gamePhase = gamePhaseRequested -- only 0-3
end
concommand.Add("adminchangeround", adminChangeRound)

 -- -- -- -- end ConCommands -- -- -- -- -- --
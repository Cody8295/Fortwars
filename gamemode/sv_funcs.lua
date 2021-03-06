local meta = FindMetaTable("Player")

--util.AddNetworkString("sendinfo")
--util.AddNetworkString("updatecash")
--util.AddNetworkString("updateclasses")
util.AddNetworkString("updatespecials")
util.AddNetworkString("updatelevels")
util.AddNetworkString("updateprops")
util.AddNetworkString("updatedonor")


function meta:Energy()
	return self:GetNWInt('energy')
end

function meta:TakeEnergy(i)
	self:SetNWInt('energy', (self:GetNWInt('energy') - i))
	return self:GetNWInt('energy')
end


function meta:AddSpecial(i)
	table.insert(self.specials, i)
	net.Start("updatespecials")
		net.WriteTable(self.specials)
	net.Send(self)
	self:SaveAccount()
end

function meta:HasSpecial(i)
	if (table.HasValue(self.specials, i)) then return true else return false end
end

function meta:LevelUp(i)
	self.upgrades[i] = self.upgrades[i] + 1
	net.Start("updatelevels")
		net.WriteTable(self.upgrades)
	net.Send(self)
	self:SaveAccount()
end

function meta:AddProp(i)
	table.insert(self.props, i)
	net.Start("updateprops")
		net.WriteTable(self.props)
	net.Send(self)
	self:SaveAccount()
end

function meta:SetDonor(i)
	self.memberlevel = i
	net.Start("updatedonor")
		net.WriteInt(self.memberlevel, 32)
	net.Send(self)
	self:SaveAccount()
end

function meta:IsPremium()
	--if self.memberlevel == 2 then return true else return false end
end

function meta:IsPlatinum()
	--if self.memberlevel == 3 then return true else return false end
end

function meta:Gib( norm )
	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() )
	effectdata:SetNormal( norm )
	util.Effect( "gib_player", effectdata )
end

function EnergyRegen(ply)
	--ply:SetNWInt('energy', ply:GetNWInt('energy') + tonumber(Skills[4].LEVEL[ply.upgrades[4]]))
	--ply:SetNWInt('energy', (math.Clamp( ply:GetNWInt('energy'), 0, 100 + Skills[3].LEVEL[ply.upgrades[3]] )))
end

function EnergyFreeze(ply)
	--ply:SetNWInt('energy', ply:GetNWInt('energy'))
	--ply:SetNWInt('energy', (math.Clamp( ply:GetNWInt('energy'), 0, 100 + Skills[3].LEVEL[ply.upgrades[3]] )))
end

function EnergyDrainPred(ply)
	--ply:SetNWInt('energy', ply:GetNWInt('energy') - (PRED_DRAIN_RATE/10) )
	--ply:SetNWInt('energy', (math.Clamp( ply:GetNWInt('energy'), 0, 100 + Skills[3].LEVEL[ply.upgrades[3]] )))
end

function EnergyDrainRaid(ply)
	--ply:SetNWInt('energy', ply:GetNWInt('energy') - 2.5 )
	--ply:SetNWInt('energy', (math.Clamp( ply:GetNWInt('energy'), 0, 100 + Skills[3].LEVEL[ply.upgrades[3]] )))
end

timer.Create("energyTimer",0.1,0,function()

	for i,v in pairs(player.GetAll()) do

		if v:GetNWBool( "cloaked" ) == false and v:GetNWBool( "raidrunning" ) == false and tonumber(v:GetPData("Class")) != 2 then
			--EnergyRegen(v)
		elseif v:GetNWBool( "cloaked" ) == true then
			--EnergyDrainPred(v)
		elseif v:GetNWBool( "raidrunning" ) == true then
			--EnergyDrainRaid(v)
		elseif tonumber(v:GetPData("Class")) == 2 then
			--EnergyFreeze(v)
		else return end
	end
end)

timer.Create("timeplayed",1,0,function()
	for i,v in pairs(player.GetAll()) do
		if v.stats then
		    v.stats[6] = v.stats[6] + 1
		end
	end
end)
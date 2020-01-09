AddCSLuaFile("shared.lua")
include("shared.lua")

function SWEP:SecondaryAttack()
    plyEn = self.Owner:GetNWInt('energy')
	if (plyEn >= 45) then
		PlyTakeEnergy(self.Owner, 45)
		self.Owner:SetVelocity(self.Owner:GetForward() * 1000)
	end
end
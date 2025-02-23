boss_alpha_wolf_howl = class({})

function boss_alpha_wolf_howl:OnSpellStart()
	local caster = self:GetCaster()
	
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
		ally:AddNewModifier( caster, self, "modifier_boss_alpha_wolf_howl", {duration = self:GetSpecialValueFor("duration")})
	end
	caster:EmitSound("Hero_Lycan.Howl")
	caster:EmitSound("Hero_Lycan.Howl.Team")
	
	ParticleManager:FireParticle("particles/units/heroes/hero_lycan/lycan_howl_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
end

modifier_boss_alpha_wolf_howl = class({})
LinkLuaModifier("modifier_boss_alpha_wolf_howl", "bosses/boss_wolves/boss_alpha_wolf_howl", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_alpha_wolf_howl:OnCreated()
	self.damage = self:GetSpecialValueFor("damage")
	self.as = self:GetSpecialValueFor("attack_speed")
end

function modifier_boss_alpha_wolf_howl:OnRefresh()
	self.damage = self:GetSpecialValueFor("damage")
	self.as = self:GetSpecialValueFor("attack_speed")
end

function modifier_boss_alpha_wolf_howl:DeclareFunctions()
	return {  MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE }
end

function modifier_boss_alpha_wolf_howl:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_boss_alpha_wolf_howl:GetModifierDamageOutgoing_Percentage()
	return self.damage
end

function modifier_boss_alpha_wolf_howl:GetEffectName()
	return "particles/units/heroes/hero_lycan/lycan_howl_buff.vpcf"
end
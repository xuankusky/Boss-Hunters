antimage_ender_of_magic = class ({})

function antimage_ender_of_magic:GetIntrinsicModifierName()
	return "modifier_antimage_ender_of_magic_handler"
end

modifier_antimage_ender_of_magic_handler = class({})
LinkLuaModifier( "modifier_antimage_ender_of_magic_handler", "heroes/hero_antimage/antimage_ender_of_magic", LUA_MODIFIER_MOTION_NONE )

function modifier_antimage_ender_of_magic_handler:OnCreated()
	self.duration = self:GetTalentSpecialValueFor("duration")
	self.radius = self:GetTalentSpecialValueFor("radius")
end

function modifier_antimage_ender_of_magic_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end

function modifier_antimage_ender_of_magic_handler:OnAbilityExecuted(params)
	if CalculateDistance( params.unit, self:GetParent() ) < self.radius and params.ability and not params.ability:IsItem() and params.ability:GetCooldown(-1) ~= 0 then
		self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_antimage_ender_of_magic_buff", {duration = self.duration})
	end
end

function modifier_antimage_ender_of_magic_handler:IsHidden()
	return true
end

modifier_antimage_ender_of_magic_buff = class({})
LinkLuaModifier( "modifier_antimage_ender_of_magic_buff", "heroes/hero_antimage/antimage_ender_of_magic", LUA_MODIFIER_MOTION_NONE )

function modifier_antimage_ender_of_magic_buff:OnCreated()
	self.as = self:GetTalentSpecialValueFor("bonus_attackspeed")
	self.ms = self:GetTalentSpecialValueFor("bonus_movespeed")
	if IsServer() then
		self:SetStackCount(1)
	end
end

function modifier_antimage_ender_of_magic_buff:OnRefresh()
	self.as = self:GetTalentSpecialValueFor("bonus_attackspeed")
	self.ms = self:GetTalentSpecialValueFor("bonus_movespeed")
	if IsServer() then
		self:AddIndependentStack( self:GetRemainingTime() )
	end
end

function modifier_antimage_ender_of_magic_buff:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_antimage_ender_of_magic_buff:GetModifierAttackSpeedBonus()
	return self.as * self:GetStackCount()
end

function modifier_antimage_ender_of_magic_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms * self:GetStackCount()
end
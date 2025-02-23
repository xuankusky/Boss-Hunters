item_illusionists_charm = class({})

function item_illusionists_charm:OnSpellStart()
	local caster = self:GetCaster()
	local targetPos = self:GetCursorPosition()
	local ogPos = caster:GetAbsOrigin()
	
	local maxIllus = self:GetSpecialValueFor("illusion_count")
	for _, illusion in ipairs( caster.itemIllusionTable or {} ) do
		if not illusion:IsNull() and illusion:IsAlive() then
			illusion:ForceKill( true )
		end
	end
	
	caster.itemIllusionTable = {}
	
	local callback = (function(illusion, parent)
		illusion:SetThreat( parent:GetThreat() )
		table.insert( caster.itemIllusionTable, illusion )
	end)
	Timers:CreateTimer(function()
		local illusion = caster:ConjureImage( ogPos + RandomVector(150), self:GetSpecialValueFor("duration"), -(100 - self:GetSpecialValueFor("illu_outgoing_damage")), self:GetSpecialValueFor("illu_incoming_damage") - 100, nil, self, true, caster, callback )
		maxIllus = maxIllus - 1
		if maxIllus > 0 then
			return 0.2
		end
	end)
end

function item_illusionists_charm:GetIntrinsicModifierName()
	return "modifier_item_illusionists_charm"
end

modifier_item_illusionists_charm = class(itemBaseClass)
LinkLuaModifier("modifier_item_illusionists_charm", "items/item_illusionists_charm", LUA_MODIFIER_MOTION_NONE)

function modifier_item_illusionists_charm:OnCreated()
	self.agility = self:GetSpecialValueFor("bonus_agility")
	self.attackSpeed = self:GetSpecialValueFor("bonus_attackspeed")
	self.regen = self:GetSpecialValueFor("bonus_hp_regen")
	self.hpBonus = self:GetSpecialValueFor("bonus_health")
	self.hpPerStr = self:GetSpecialValueFor("hp_per_str")
	self.stat = self:GetSpecialValueFor("bonus_strength")
end

function modifier_item_illusionists_charm:DeclareFunctions()
	return {
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,	
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			}
end

function modifier_item_illusionists_charm:GetModifierAttackSpeedBonus()
	return self.attackSpeed
end

function modifier_item_illusionists_charm:GetModifierBonusStats_Agility()
	return self.agility
end

function modifier_item_illusionists_charm:GetModifierBonusStats_Strength()
	return self.stat
end

function modifier_item_illusionists_charm:GetModifierExtraHealthBonus()
	return self:GetParent():GetStrength() * self.hpPerStr + self.hpBonus
end

function modifier_item_illusionists_charm:GetModifierConstantHealthRegen()
	return self.regen
end

function modifier_item_illusionists_charm:IsHidden()
	return true
end

function modifier_item_illusionists_charm:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
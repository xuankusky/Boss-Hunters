abaddon_brume_weaver = class({})

function abaddon_brume_weaver:IsStealable()
	return true
end

function abaddon_brume_weaver:IsHiddenWhenStolen()
	return false
end

function abaddon_brume_weaver:GetIntrinsicModifierName()
	return "modifier_abaddon_brume_weaver_passive"
end

function abaddon_brume_weaver:GetCastAnimation()
	return ACT_DOTA_ATTACK
end

function abaddon_brume_weaver:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		
		self:DealDamage( caster, caster, self:GetTalentSpecialValueFor("base_heal"), {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NON_LETHAL} )
		caster:AddNewModifier( caster, self, "modifier_abaddon_brume_weaver_active", {duration = self:GetTalentSpecialValueFor("buff_duration")})
	end
end

LinkLuaModifier( "modifier_abaddon_brume_weaver_passive", "heroes/hero_abaddon/abaddon_brume_weaver", LUA_MODIFIER_MOTION_NONE )
modifier_abaddon_brume_weaver_passive = class({})

function modifier_abaddon_brume_weaver_passive:OnCreated()
	self.healFactor = self:GetAbility():GetTalentSpecialValueFor("heal_pct") / 100
	self.healDuration = self:GetAbility():GetTalentSpecialValueFor("heal_duration")
	self.evasion = self:GetAbility():GetTalentSpecialValueFor("evasion")
end

function modifier_abaddon_brume_weaver_passive:OnRefresh()
	self.healFactor = self:GetAbility():GetTalentSpecialValueFor("heal_pct") / 100
	self.healDuration = self:GetAbility():GetTalentSpecialValueFor("heal_duration")
	self.evasion = self:GetAbility():GetTalentSpecialValueFor("evasion")
end

function modifier_abaddon_brume_weaver_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_TAKEDAMAGE,
			}
	return funcs
end

function modifier_abaddon_brume_weaver_passive:OnTakeDamage(params)
	if params.unit == self:GetParent() then
		local damage = params.damage
		local flHeal = math.ceil(params.damage * self.healFactor / self.healDuration)
		local healModifier = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_abaddon_brume_weaver_handler_heal", {duration = self.healDuration})
		if not healModifier then return end
		healModifier:SetStackCount(flHeal)
		local procBrume = ParticleManager:FireParticle("particles/abaddon_brume_proc_smoke3.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	end
end

function modifier_abaddon_brume_weaver_passive:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_frost_slow.vpcf"
end

function modifier_abaddon_brume_weaver_passive:IsHidden()
	return true
end

LinkLuaModifier( "modifier_abaddon_brume_weaver_handler_heal", "heroes/hero_abaddon/abaddon_brume_weaver", LUA_MODIFIER_MOTION_NONE )
modifier_abaddon_brume_weaver_handler_heal = class({})

function modifier_abaddon_brume_weaver_handler_heal:IsHidden()
	return true
end

function modifier_abaddon_brume_weaver_handler_heal:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			}
	return funcs
end

function modifier_abaddon_brume_weaver_handler_heal:GetModifierConstantHealthRegen()
	return self:GetStackCount()
end

function modifier_abaddon_brume_weaver_handler_heal:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

LinkLuaModifier( "modifier_abaddon_brume_weaver_active", "heroes/hero_abaddon/abaddon_brume_weaver", LUA_MODIFIER_MOTION_NONE )
modifier_abaddon_brume_weaver_active = class({})

function modifier_abaddon_brume_weaver_active:OnCreated()
	self.restoration = self:GetAbility():GetTalentSpecialValueFor("base_heal") / self:GetDuration()
end

function modifier_abaddon_brume_weaver_active:OnRefresh()
	self.restoration = self:GetAbility():GetTalentSpecialValueFor("base_heal") / self:GetDuration()
end

function modifier_abaddon_brume_weaver_active:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
				MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			}
	return funcs
end

function modifier_abaddon_brume_weaver_active:CheckState()
	if self:GetCaster():HasTalent("special_bonus_unique_abaddon_brume_weaver_2") then
		return {MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY, MODIFIER_STATE_NO_UNIT_COLLISION}
	end
end

function modifier_abaddon_brume_weaver_active:GetModifierConstantHealthRegen()
	return self.restoration
end

function modifier_abaddon_brume_weaver_active:GetModifierConstantManaRegen()
	return self.restoration
end
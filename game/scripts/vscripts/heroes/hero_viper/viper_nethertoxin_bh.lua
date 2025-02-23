viper_nethertoxin_bh = class({})

function viper_nethertoxin_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function viper_nethertoxin_bh:OnSpellStart()
	local caster = self:GetCaster()
	local targetPos = self:GetCursorPosition()
	
	caster:EmitSound("Hero_Viper.Nethertoxin.Cast")
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_viper/viper_nethertoxin_cast.vpcf", PATTACH_POINT_FOLLOW, caster, targetPos)
	CreateModifierThinker(caster, self, "modifier_viper_nethertoxin_bh_thinker", {duration = self:GetTalentSpecialValueFor("duration")}, targetPos, caster:GetTeamNumber(), false)
end

modifier_viper_nethertoxin_bh_thinker = class({})
LinkLuaModifier("modifier_viper_nethertoxin_bh_thinker", "heroes/hero_viper/viper_nethertoxin_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_viper_nethertoxin_bh_thinker:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("radius")
	if IsServer() then
		EmitSoundOn("Hero_Viper.Nethertoxin.Cast", self:GetParent())
		nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_viper/viper_nethertoxin.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(nFX, 0, (Vector(0, 0, 0)))
		ParticleManager:SetParticleControl(nFX, 1, (Vector(self.radius, 1, 1)))
		ParticleManager:SetParticleControl(nFX, 15, (Vector(25, 150, 25)))
		ParticleManager:SetParticleControl(nFX, 16, (Vector(0, 0, 0)))
		self:AddEffect(nFX)
		
		self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_viper_nethertoxin_bh_thinker:OnDestroy()
	if IsServer() then
		StopSoundOn("Hero_Viper.Nethertoxin.Cast", self:GetParent())
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_viper_nethertoxin_bh_thinker:IsAura()
	return true
end

function modifier_viper_nethertoxin_bh_thinker:GetModifierAura()
	return "modifier_viper_nethertoxin_bh_debuff"
end

function modifier_viper_nethertoxin_bh_thinker:GetAuraRadius()
	return self.radius
end

function modifier_viper_nethertoxin_bh_thinker:GetAuraDuration()
	return 0.5
end

function modifier_viper_nethertoxin_bh_thinker:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_viper_nethertoxin_bh_thinker:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_viper_nethertoxin_bh_thinker:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_viper_nethertoxin_bh_debuff = class({})
LinkLuaModifier("modifier_viper_nethertoxin_bh_debuff", "heroes/hero_viper/viper_nethertoxin_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_viper_nethertoxin_bh_debuff:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("damage")
	self.mr = self:GetTalentSpecialValueFor("magic_resistance")
	if IsServer() then
		self:StartIntervalThink( 1 )
		if self:GetCaster():HasTalent("special_bonus_unique_viper_nethertoxin_2") then
			local nFX = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_silence.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
			self:AddEffect(nFX)
		end
	end
end

function modifier_viper_nethertoxin_bh_debuff:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("damage")
	self.mr = self:GetTalentSpecialValueFor("magic_resistance")
end

function modifier_viper_nethertoxin_bh_debuff:OnIntervalThink()
	local parent = self:GetParent()
	parent:EmitSound("Hero_Viper.NetherToxin.Damage")
	self:GetAbility():DealDamage( self:GetCaster(), parent, self.damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE )
end

function modifier_viper_nethertoxin_bh_debuff:CheckState()
	local state = {[MODIFIER_STATE_PASSIVES_DISABLED] = true}
	if self:GetCaster():HasTalent("special_bonus_unique_viper_nethertoxin_2") then
		state[MODIFIER_STATE_SILENCED] = true
	end
	return state
end

function modifier_viper_nethertoxin_bh_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_viper_nethertoxin_bh_debuff:GetModifierMagicalResistanceBonus()
	return self.mr
end

function modifier_viper_nethertoxin_bh_debuff:GetEffectName()
	return "particles/units/heroes/hero_viper/viper_nethertoxin_debuff.vpcf"
end
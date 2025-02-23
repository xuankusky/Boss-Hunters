pl_false_edge = class({})
LinkLuaModifier("modifier_pl_false_edge", "heroes/hero_phantom_lancer/pl_false_edge", LUA_MODIFIER_MOTION_NONE)

function pl_false_edge:IsStealable()
    return true
end

function pl_false_edge:IsHiddenWhenStolen()
    return false
end

function pl_false_edge:OnSpellStart()
    local caster = self:GetCaster()

    local duration = self:GetTalentSpecialValueFor("duration")

    EmitSoundOn("Hero_EarthShaker.Totem.Immortal", caster)

    ParticleManager:FireParticle("particles/econ/items/earthshaker/earthshaker_totem_ti6/earthshaker_totem_ti6_cast.vpcf", PATTACH_POINT, caster, {[0] = caster:GetAbsOrigin() + caster:GetForwardVector() * 75})

    caster:AddNewModifier(caster, self, "modifier_pl_false_edge", {Duration = duration})

    local illusions = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
    for _,illusion in pairs(illusions) do
        if illusion:IsIllusion() and illusion:GetOwner() == caster then
            illusion:AddNewModifier(caster, self, "modifier_pl_false_edge", {Duration = duration})
        end
    end

    if caster:HasTalent("special_bonus_unique_pl_false_edge_2") then
        local radius = caster:FindTalentValue("special_bonus_unique_pl_false_edge_2")

        local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), radius)
        for _,ally in pairs(allies) do
            ally:AddNewModifier(caster, self, "modifier_pl_false_edge", {Duration = duration})
        end
    end
end

modifier_pl_false_edge = class({})

function modifier_pl_false_edge:OnCreated(table)
    self.bonus_as = self:GetTalentSpecialValueFor("bonus_as")
    self.bonus_accuracy = self:GetTalentSpecialValueFor("bonus_accuracy")

    if self:GetCaster():HasTalent("special_bonus_unique_pl_false_edge_1") then
        self.bonus_ms = self.bonus_as/2
    end
	if IsServer() then
		local nFX = ParticleManager:CreateParticle("particles/econ/generic/generic_buff_1/generic_buff_1.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl(nFX, 14, Vector(1,1,1))
		ParticleManager:SetParticleControl(nFX, 15, Vector(255,232,130))
		self:AddEffect(nFX)
	end
end

function modifier_pl_false_edge:OnRefresh(table)
    self.bonus_as = self:GetTalentSpecialValueFor("bonus_as")
    self.bonus_accuracy = self:GetTalentSpecialValueFor("bonus_accuracy")

    if self:GetCaster():HasTalent("special_bonus_unique_pl_false_edge_1") then
        self.bonus_ms = self.bonus_as/2
    end
end

function modifier_pl_false_edge:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
                    MODIFIER_PROPERTY_TOOLTIP,
                    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
    return funcs
end

function modifier_pl_false_edge:GetModifierMoveSpeedBonus_Percentage()
    return self.bonus_ms
end

function modifier_pl_false_edge:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_as
end

function modifier_pl_false_edge:GetAccuracy()
    return self.bonus_accuracy
end

function modifier_pl_false_edge:OnTooltip()
    return self.bonus_accuracy
end

function modifier_pl_false_edge:IsPurgable()
    return true
end

function modifier_pl_false_edge:IsDebuff()
    return false
end
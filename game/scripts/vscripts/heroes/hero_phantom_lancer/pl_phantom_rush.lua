pl_phantom_rush = class({})
LinkLuaModifier("modifier_pl_phantom_rush", "heroes/hero_phantom_lancer/pl_phantom_rush", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pl_phantom_rush_speed", "heroes/hero_phantom_lancer/pl_phantom_rush", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pl_phantom_rush_agi", "heroes/hero_phantom_lancer/pl_phantom_rush", LUA_MODIFIER_MOTION_NONE)

function pl_phantom_rush:IsStealable()
    return true
end

function pl_phantom_rush:IsHiddenWhenStolen()
    return false
end

function pl_phantom_rush:GetCastRange( target, location)
	return self:GetTalentSpecialValueFor("max_distance")
end

function pl_phantom_rush:GetIntrinsicModifierName()
    return "modifier_pl_phantom_rush"
end

function pl_phantom_rush:GetBehavior()
    if self:GetCaster():HasScepter() then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function pl_phantom_rush:OnSpellStart()
    local caster = self:GetCaster()

    local image_duration = self:GetTalentSpecialValueFor("illusion_duration_scepter")

    local image1_in = self:GetTalentSpecialValueFor("illusion_in_scepter")
    local image1_out = self:GetTalentSpecialValueFor("illusion_out_scepter")

    local callback = (function(image1)
        if image1 ~= nil then
            caster:FindAbilityByName("pl_juxtapose"):GiveFxModifier(image1)
        end
    end)

    local image1 = caster:ConjureImage( caster:GetAbsOrigin() + RandomVector( 72 ), image_duration, image1_out, image1_in, "", self, true, caster, callback )

end

modifier_pl_phantom_rush = class({})

function modifier_pl_phantom_rush:DeclareFunctions()
    local funcs = { MODIFIER_EVENT_ON_ORDER,
                    MODIFIER_EVENT_ON_ATTACK_START}
    return funcs
end

function modifier_pl_phantom_rush:OnOrder(params)
    if IsServer() then
        local caster = self:GetCaster()
        local target = params.target
        local caster_origin = caster:GetAbsOrigin()
        
        local ability = self:GetAbility()
        local cooldown = ability:GetCooldown(ability:GetLevel())
        local min_distance = self:GetTalentSpecialValueFor("min_distance")
        local max_distance = self:GetTalentSpecialValueFor("max_distance")
        local duration = 5
        
        -- Checks if the ability is off cooldown and if the caster is attacking a target
        if target ~= null and ability:IsCooldownReady() then
            -- Checks if the target is an enemy
            if caster:GetTeam() ~= target:GetTeam() then
                local target_origin = target:GetAbsOrigin()
                local distance = CalculateDistance(target, caster)
                ability.target = target
                -- Checks if the caster is in range of the target
                if distance >= min_distance and distance <= max_distance then
                    -- Removes the 522 move speed cap
                    caster:AddNewModifier(caster, ability, "modifier_pl_phantom_rush_speed", { duration = duration })
                    -- Start cooldown on the passive
                    ability:StartCooldown(cooldown)
                -- If the caster is too far from the target, we continuously check his distance until the attack command is canceled
                elseif distance >= max_distance then
                    distance = CalculateDistance(target, caster)
                end
            end
        elseif not target then
            caster:RemoveModifierByName("modifier_pl_phantom_rush_speed")
        end
    end
end

function modifier_pl_phantom_rush:OnAttackStart(params)
    if IsServer() then
        local caster = self:GetCaster()
        local attacker = params.attacker

        if attacker == caster and caster:HasModifier("modifier_pl_phantom_rush_speed") then
            local agiDuration = self:GetTalentSpecialValueFor("agility_duration")

            caster:AddNewModifier(caster, self:GetAbility(), "modifier_pl_phantom_rush_agi", {Duration = agiDuration})
            caster:RemoveModifierByName("modifier_pl_phantom_rush_speed")
        end
    end
end

function modifier_pl_phantom_rush:GetEffectName()
    return "particles/units/heroes/hero_phantom_lancer/phantomlancer_edge_boost.vpcf"
end

function modifier_pl_phantom_rush:IsHidden()
    return true
end

function modifier_pl_phantom_rush:IsPurgable()
    return false
end

function modifier_pl_phantom_rush:IsPurgeException()
    return false
end

function modifier_pl_phantom_rush:IsPermanent()
    return true
end

modifier_pl_phantom_rush_speed = class({})
function modifier_pl_phantom_rush_speed:OnCreated(table)
    self.bonus_ms = self:GetParent():GetIdealSpeedNoSlows() + 800
end

function modifier_pl_phantom_rush_speed:OnRefresh(table)
    self.bonus_ms = self:GetParent():GetIdealSpeedNoSlows() + 800
end

function modifier_pl_phantom_rush_speed:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE}
end

function modifier_pl_phantom_rush_speed:GetModifierMoveSpeed_Absolute()
    return self.bonus_ms
end

function modifier_pl_phantom_rush_speed:CheckState()
    local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true }
    return state
end

function modifier_pl_phantom_rush_speed:IsDebuff()
    return false
end

function modifier_pl_phantom_rush_speed:IsPurgable()
    return true
end

modifier_pl_phantom_rush_agi = class({})
function modifier_pl_phantom_rush_agi:OnCreated(table)
    EmitSoundOn("Hero_PhantomLancer.PhantomEdge", self:GetParent())
    self.bonus_agility = self:GetParent():GetAgility() * self:GetTalentSpecialValueFor("bonus_agility")/100
end

function modifier_pl_phantom_rush_agi:OnRefresh(table)
    EmitSoundOn("Hero_PhantomLancer.PhantomEdge", self:GetParent())
    self.bonus_agility = self:GetParent():GetAgility() * self:GetTalentSpecialValueFor("bonus_agility")/100
end

function modifier_pl_phantom_rush_agi:DeclareFunctions()
    return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function modifier_pl_phantom_rush_agi:GetModifierBonusStats_Agility()
    return self.bonus_agility
end

function modifier_pl_phantom_rush_agi:IsDebuff()
    return false
end

function modifier_pl_phantom_rush_speed:IsPurgable()
    return true
end
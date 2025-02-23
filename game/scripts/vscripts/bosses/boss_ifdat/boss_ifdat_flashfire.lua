boss_ifdat_flashfire = class({})

function boss_ifdat_flashfire:GetIntrinsicModifierName()
	return "modifier_boss_ifdat_flashfire"
end

modifier_boss_ifdat_flashfire = class({})
LinkLuaModifier( "modifier_boss_ifdat_flashfire", "bosses/boss_ifdat/boss_ifdat_flashfire", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_ifdat_flashfire:OnCreated()
	self.ms = self:GetSpecialValueFor("ms_per_stack")
	self.as = self:GetSpecialValueFor("as_per_stack")
	self:GetCaster().touchOfFireTable = self:GetCaster().touchOfFireTable or {}
	if IsServer() then
		self:StartIntervalThink(0.2)
	end
end

function modifier_boss_ifdat_flashfire:OnRefresh()
	self.ms = self:GetSpecialValueFor("ms_per_stack")
	self.as = self:GetSpecialValueFor("as_per_stack")
end

function modifier_boss_ifdat_flashfire:OnIntervalThink()
	local caster = self:GetCaster()
	local stacks = 0
	for i = #caster.touchOfFireTable, 1, -1 do
		local modifier = caster.touchOfFireTable[i]
		if not modifier or modifier:IsNull() then
			table.remove( caster.touchOfFireTable, i )
		else
			stacks = stacks + modifier:GetStackCount()
		end
	end
	self:SetStackCount( stacks )
end

function modifier_boss_ifdat_flashfire:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

function modifier_boss_ifdat_flashfire:GetModifierMoveSpeedBonus_Constant()
	return self.ms * self:GetStackCount()
end

function modifier_boss_ifdat_flashfire:GetModifierAttackSpeedBonus()
	return self.as * self:GetStackCount()
end
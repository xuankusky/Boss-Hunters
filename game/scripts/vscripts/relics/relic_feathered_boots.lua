relic_feathered_boots = class(relicBaseClass)

function relic_feathered_boots:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

function relic_feathered_boots:GetModifierMoveSpeedBonus_Constant()
	return 35
end

function relic_feathered_boots:GetMoveSpeedLimitBonus()
	return 100
end
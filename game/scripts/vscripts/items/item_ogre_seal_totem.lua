item_ogre_seal_totem = class({})
LinkLuaModifier( "modifier_item_ogre_seal_totem", "items/item_ogre_seal_totem.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_ogreseal_flop", "items/item_ogre_seal_totem.lua", LUA_MODIFIER_MOTION_BOTH )

function item_ogre_seal_totem:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end
function item_ogre_seal_totem:GetIntrinsicModifierName()
	return "modifier_item_ogre_seal_totem"
end

function item_ogre_seal_totem:OnAbilityPhaseStart()
	if IsServer() then
		self:GetCaster():StartGesture( ACT_DOTA_VICTORY )
	end

	return true
end

function item_ogre_seal_totem:OnAbilityPhaseInterrupted()
	if IsServer() then
		--ParticleManager:DestroyParticle( self.nPreviewFXIndex, true )

		self:GetCaster():RemoveGesture( ACT_DOTA_VICTORY )
		self:GetCaster():RemoveModifierByName( "modifier_techies_suicide_leap_animation" )
	end
end

function item_ogre_seal_totem:OnSpellStart()
	if IsServer() then
		if self.nPreviewFXIndex then
			ParticleManager:DestroyParticle( self.nPreviewFXIndex, true )
		end

		self:GetCaster():RemoveGesture( ACT_DOTA_VICTORY )

		self.stun_duration = self:GetSpecialValueFor("stun_duration")

		local vToTarget = self:GetCursorPosition() - self:GetCaster():GetOrigin()
		local vLocation = self:GetCaster():GetOrigin() + vToTarget:Normalized() * vToTarget:Length2D() / 3
		local kv =
		{
			vLocX = vLocation.x,
			vLocY = vLocation.y,
			vLocZ = vLocation.z
		}
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_ogreseal_flop", kv )
		EmitSoundOn( "Hero_Techies.BlastOff.Cast", self:GetCaster() )
	end
end

function item_ogre_seal_totem:TryToDamage()
	if IsServer() then
		local radius = self:GetSpecialValueFor( "radius" )
		local damage = self:GetSpecialValueFor( "damage" )
		local silence_duration = self:GetSpecialValueFor( "silence_duration" )
		local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS, 0, false )
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
					local DamageInfo =
					{
						victim = enemy,
						attacker = self:GetCaster(),
						ability = self,
						damage = damage,
						damage_type = DAMAGE_TYPE_PHYSICAL,
					}
					ApplyDamage( DamageInfo )
					if enemy:IsAlive() == false then
						local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, nil )
						ParticleManager:SetParticleControlEnt( nFXIndex, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetOrigin(), true )
						ParticleManager:SetParticleControl( nFXIndex, 1, enemy:GetOrigin() )
						ParticleManager:SetParticleControlForward( nFXIndex, 1, -self:GetCaster():GetForwardVector() )
						ParticleManager:SetParticleControlEnt( nFXIndex, 10, enemy, PATTACH_ABSORIGIN_FOLLOW, nil, enemy:GetOrigin(), true )
						ParticleManager:ReleaseParticleIndex( nFXIndex )

						EmitSoundOn( "Dungeon.BloodSplatterImpact", enemy )
					else
						enemy:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = self.stun_duration } )
					end
				end
			end
		end

		EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "OgreTank.GroundSmash", self:GetCaster() )
		local nFXIndex = ParticleManager:CreateParticle( "particles/test_particle/ogre_melee_smash.vpcf", PATTACH_WORLDORIGIN,  self:GetCaster()  )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, self.radius, self.radius ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		GridNav:DestroyTreesAroundPoint( self:GetCaster():GetOrigin(), radius, false )
	end
end


modifier_item_ogre_seal_totem = class(itemBaseClass)

function modifier_item_ogre_seal_totem:OnCreated( kv )
	self.bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength" )
	self.bonus_hp = self:GetAbility():GetSpecialValueFor( "bonus_hp" )
	self.hpPerStr = self:GetAbility():GetSpecialValueFor( "hp_per_str" )
	self.regen = self:GetAbility():GetSpecialValueFor( "bonus_hp_regen" )
	self.bonus_mana = self:GetAbility():GetSpecialValueFor( "bonus_mana" )
end

function modifier_item_ogre_seal_totem:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_BONUS,
	}

	return funcs
end

function modifier_item_ogre_seal_totem:GetModifierManaBonus()
	return self.bonus_mana
end

function modifier_item_ogre_seal_totem:GetModifierBonusStats_Strength( params )
	return self.bonus_strength
end

function modifier_item_ogre_seal_totem:GetModifierConstantHealthRegen()
	return self.regen
end

function modifier_item_ogre_seal_totem:GetModifierExtraHealthBonus( params )
	return self:GetParent():GetStrength() * self.hpPerStr + self.bonus_hp
end

modifier_ogreseal_flop = class({})
local OGRE_MINIMUM_HEIGHT_ABOVE_LOWEST = 150
local OGRE_MINIMUM_HEIGHT_ABOVE_HIGHEST = 33
local OGRE_ACCELERATION_Z = 1250
local OGRE_MAX_HORIZONTAL_ACCELERATION = 1000

function modifier_ogreseal_flop:IsStunDebuff()
	return true
end

function modifier_ogreseal_flop:IsHidden()
	return true
end

function modifier_ogreseal_flop:IsPurgable()
	return false
end

function modifier_ogreseal_flop:RemoveOnDeath()
	return false
end

function modifier_ogreseal_flop:OnCreated( kv )
	if IsServer() then
		if self:GetCaster():IsRealHero() then
			self:GetCaster():StartGesture( ACT_DOTA_FLAIL )
		end

		self.bHorizontalMotionInterrupted = false
		self.bDamageApplied = false
		self.bTargetTeleported = false

		if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then 
			self:Destroy()
			return
		end

		self.flTimer = 0.0
		self.vStartPosition = GetGroundPosition( self:GetParent():GetOrigin(), self:GetParent() )
		self.flCurrentTimeHoriz = 0.0
		self.flCurrentTimeVert = 0.0

		self.vLoc = Vector( kv.vLocX, kv.vLocY, kv.vLocZ )
		self.vLastKnownTargetPos = self.vLoc
		
		

		if self.nHopCount == nil then
			local flopDist = CalculateDistance( self.vStartPosition, self.vLoc )
			self.nHopCount = 1
			self.flop_distances = {flopDist, flopDist, flopDist}
		end
		
		local duration = 0
		local flDesiredHeight = OGRE_MINIMUM_HEIGHT_ABOVE_LOWEST * self.nHopCount * duration * duration
		local flLowZ = math.min( self.vLastKnownTargetPos.z, self.vStartPosition.z )
		local flHighZ = math.max( self.vLastKnownTargetPos.z, self.vStartPosition.z )
		local flArcTopZ = math.max( flLowZ + flDesiredHeight, flHighZ + OGRE_MINIMUM_HEIGHT_ABOVE_HIGHEST * self.nHopCount )

		local flArcDeltaZ = flArcTopZ - self.vStartPosition.z
		self.flInitialVelocityZ = math.sqrt( 2.0 * flArcDeltaZ * OGRE_ACCELERATION_Z * self.nHopCount )

		local flDeltaZ = self.vLastKnownTargetPos.z - self.vStartPosition.z
		local flSqrtDet = math.sqrt( math.max( 0, ( self.flInitialVelocityZ * self.flInitialVelocityZ ) - 2.0 * OGRE_ACCELERATION_Z * self.nHopCount * flDeltaZ ) )
		self.flPredictedTotalTime = math.max( ( self.flInitialVelocityZ + flSqrtDet) / ( OGRE_ACCELERATION_Z * self.nHopCount ), ( self.flInitialVelocityZ - flSqrtDet) / ( OGRE_ACCELERATION_Z * self.nHopCount ) )

		self.vHorizontalVelocity = ( self.vLastKnownTargetPos - self.vStartPosition ) / self.flPredictedTotalTime
		self.vHorizontalVelocity.z = 0.0

		
	end
end

function modifier_ogreseal_flop:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveHorizontalMotionController( self )
		self:GetParent():RemoveVerticalMotionController( self )

		if self:GetCaster():IsRealHero() then
			self:GetCaster():RemoveGesture( ACT_DOTA_FLAIL )
		end
	end
end

function modifier_ogreseal_flop:DeclareFunctions()
	local funcs = 
	{
	--	MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end

function modifier_ogreseal_flop:CheckState()
	local state =
	{
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function modifier_ogreseal_flop:UpdateHorizontalMotion( me, dt )
	if IsServer() then
		self.flTimer = self.flTimer + dt
		self.flCurrentTimeHoriz = math.min( self.flCurrentTimeHoriz + dt, self.flPredictedTotalTime )
		local t = self.flCurrentTimeHoriz / self.flPredictedTotalTime
		local vStartToTarget = self.vLastKnownTargetPos - self.vStartPosition
		local vDesiredPos = self.vStartPosition + t * vStartToTarget

		local vOldPos = me:GetOrigin()
		local vToDesired = vDesiredPos - vOldPos
		vToDesired.z = 0.0
		local vDesiredVel = vToDesired / dt
		local vVelDif = vDesiredVel - self.vHorizontalVelocity
		local flVelDif = vVelDif:Length2D()
		vVelDif = vVelDif:Normalized()
		local flVelDelta = math.min( flVelDif, OGRE_MAX_HORIZONTAL_ACCELERATION * self.nHopCount )

		self.vHorizontalVelocity = self.vHorizontalVelocity + vVelDif * flVelDelta * dt
		local vNewPos = vOldPos + self.vHorizontalVelocity * dt
		me:SetOrigin( vNewPos )
	end
end

function modifier_ogreseal_flop:UpdateVerticalMotion( me, dt )
	if IsServer() then
		self.flCurrentTimeVert = self.flCurrentTimeVert + dt
		local bGoingDown = ( -OGRE_ACCELERATION_Z * self.nHopCount * self.flCurrentTimeVert + self.flInitialVelocityZ ) < 0
		
		local vNewPos = me:GetOrigin()
		vNewPos.z = self.vStartPosition.z + ( -0.5 * OGRE_ACCELERATION_Z * self.nHopCount * ( self.flCurrentTimeVert * self.flCurrentTimeVert ) + self.flInitialVelocityZ * self.flCurrentTimeVert )

		local flGroundHeight = GetGroundHeight( vNewPos, self:GetParent() )
		local bLanded = false
		if ( vNewPos.z < flGroundHeight and bGoingDown == true ) then
			vNewPos.z = flGroundHeight
			bLanded = true
		end

		me:SetOrigin( vNewPos )
		if bLanded == true then

			local bDoneHopping = self.nHopCount == 3

			if self.bHorizontalMotionInterrupted == false then
				if self.nHopCount > 0 then
				
					self:GetAbility():TryToDamage()
					self.flTimer = 0.0
				end
			else
				bDoneHopping = true
			end

			if bDoneHopping then
				self:Destroy()
				
			else
				self.nHopCount = self.nHopCount + 1
				self.vLoc = self.vLoc + self:GetCaster():GetForwardVector() * self.flop_distances[ self.nHopCount ]
				local kv =
				{
					vLocX = self.vLoc.x,
					vLocY = self.vLoc.y,
					vLocZ = self.vLoc.z,
				}
				self:OnCreated( kv )
			end
		end
	end
end

function modifier_ogreseal_flop:OnHorizontalMotionInterrupted()
	if IsServer() then
		self.bHorizontalMotionInterrupted = true
	end
end

function modifier_ogreseal_flop:OnVerticalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

function modifier_ogreseal_flop:GetOverrideAnimation( params )
	return ACT_DOTA_OVERRIDE_ABILITY_2
end
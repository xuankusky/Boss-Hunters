local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemiesToSpawn = 2 + math.floor( math.log( RoundManager:GetEventsFinished() + 1 ) )
	self.eventHandler = Timers:CreateTimer(3, function()
		local enemyName = ""
		local roll = RandomInt(1, 5)
		
		if roll <= 2 then
			enemyName = "npc_dota_boss8a"
		elseif roll <= 4 then
			enemyName = "npc_dota_boss8b"
		else
			enemyName = "npc_dota_boss8c_spawner"
		end
		
		local spawn = CreateUnitByName(enemyName, RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		spawn.unitIsRoundNecessary = true
		
		self.enemiesToSpawn = self.enemiesToSpawn - 1
		if self.enemiesToSpawn > 0 then
			return 15 / (GameRules:GetGameDifficulty() + 1)
		end
	end)
	
	self._vEventHandles = {
		ListenToGameEvent( "entity_killed", require("events/base_combat"), self ),
	}
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vEventHandles ) do
		StopListeningToGameEvent( eID )
	end
	RoundManager:EndEvent(bWon)
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss8c", context)
	PrecacheUnitByNameSync("npc_dota_boss8c_spawner", context)
	PrecacheUnitByNameSync("npc_dota_boss8a", context)
	PrecacheUnitByNameSync("npc_dota_boss8b", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs
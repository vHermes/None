local game = Game()
local Mod = RegisterMod("LittleCorn", 1)
local sounds = SFXManager()

EntityType.LITTLECORN = Isaac.GetEntityTypeByName("LittleCorn")

MDState = {
    IDLE = 0,
    SHOOT = 1,
    BOMB = 2,
    TELEPORT = 3,
    RETURN = 4,
    APPEAR = 5,
    BOMBRETURN = 6,
    DEATH = 7,
    MEGABOMB = 8,
    SUMMON = 9
} 

MarkovChain = {
	[MDState.IDLE] = 							{0.5, 0.5, 0, 0, 0, 0, 0},
	[MDState.SHOOT] = 			    	{1, 0, 0, 0, 0, 0, 0},
	[MDState.BOMB] = 							{1, 0, 0, 0, 0, 0, 0},
	[MDState.TELEPORT] =  				{1, 0, 0, 0, 0, 0, 0},
	[MDState.BOMBRETURN] =	 			{1, 0, 0, 0, 0, 0, 0},
	[MDState.MEGABOMB] = 					{1, 0, 0, 0, 0, 0, 0},
	[MDState.SUMMON] = 			    	{1, 0, 0, 0, 0, 0, 0}
}

function MarkovTransition(state)
		local roll = math.random()
		for i = 1, #MarkovChain do
				roll = roll - MarkovChain[State][i]
				if roll <=0 then
						return i
				end
		end
		return #MarkovChain
end

function Mod:LittleCornUpdate(entity)
    local data = entity:GetData()
    if data.State == nil then data.State = 0 end
    if data.StateFrame == nil then data.StateFrame = 0 end
    local target = entity:GetPlayerTarget()
    
    data.StateFrame = data.StateFrame + 1
   
    if data.State == MDState.APPEAR and entity:GetSprite():IsFinished("APPEAR") then
        data.State = MDState.IDLE
        data.StateFrame = 0
    elseif data.State == MDState.IDLE then
        if data.StateFrame == 1 then
            entity:GetSprite():Play("Idle", true)
        elseif entity:GetSprite():IsFinished("Idle") then
            data.State = MarkovTransition(data.State)
            data.State = 0
        end
    elseif data.State == MDState.SHOOT then
        if data.StateFrame == 1 then
            entity:GetSprite():Play("SHOOT", true)
        elseif entity:GetSprite():IsEventTriggered("Shoot") then
            local SpawnPos = Isaac.GetFreeNearPosition(entity.Position + Vector(0,30), 20)
            Isaac.Spawn(EntityType.ENTITY_LITTLE_HORN, 0, 0, SpawnPos, Vector(0,0), entity)
        elseif entity:GetSprite():IsFinished("Shoot") then
            data.State = MarkovTransition(data.State)
            data.StateFrame = 0
        end
    end
end
Mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, Mod.LittleCornUpdate, EntityType.LITTLECORN)
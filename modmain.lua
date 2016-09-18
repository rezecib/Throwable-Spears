local SMALL_MISS_CHANCE = GetModConfigData("SMALL_MISS_CHANCE")
local SMALL_USES = GetModConfigData("SMALL_USES")
local LARGE_USES = GetModConfigData("LARGE_USES")
local RANGE_CHECK = GetModConfigData("RANGE_CHECK")

PrefabFiles = {
	"spear_projectile"
}
Assets = {
	Asset("ANIM", "anim/spear_projectile.zip"),
}

local smallhits =
{
	frog = true,
	penguin = true,
	eyeplant = true,
}

AddPrefabPostInit("spear", function(inst)
	if not GLOBAL.TheWorld.ismastersim then return end
	local spear = inst
	local function onattack(inst, attacker, target, skipsanity)
		local smalltarget = target:HasTag("smallcreature")
					and not target:HasTag("spider")
					and not smallhits[target.prefab]
		local missed = false
		if math.random() < SMALL_MISS_CHANCE and smalltarget then
			missed = true
			if attacker.components and attacker.components.talker then
				local miss_message = "Ugh, I don't think I can hit something that small!"
				if attacker.prefab == 'wx78' then miss_message = "INSUFFICIENT ACCURACY" end
				attacker.components.talker:Say(miss_message)
				target:PushEvent("attacked", {attacker = attacker, damage = 0, weapon = spear})
			end
		else
			if target.components.combat then
				spear.projectile = true
				target.components.combat:GetAttacked(attacker, attacker.components.combat:CalcDamage(target, spear), spear)
			end			
		end
			
		local newspear = GLOBAL.SpawnPrefab('spear')
		newspear.Transform:SetPosition(inst:GetPosition():Get())
		if newspear.components.finiteuses then
			newspear.components.finiteuses:SetUses(spear.components.finiteuses:GetUses())
			newspear.components.finiteuses:Use((smalltarget and not missed)
				and GLOBAL.TUNING.SPEAR_USES/SMALL_USES
				or GLOBAL.TUNING.SPEAR_USES/LARGE_USES)
		end
		newspear:AddTag("scarytoprey")
		newspear:DoTaskInTime(1, function(inst) inst:RemoveTag("scarytoprey") end)
		inst:Remove()
		spear:Remove()

		attacker.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)
	end
	
	inst:AddComponent('spearthrowable')
	inst.components.spearthrowable:SetRange(8, 10)
	inst.components.spearthrowable:SetOnAttack(onattack)
	inst.components.spearthrowable:SetProjectile("spear_projectile")
end)

local SPEARTHROW = AddAction("SPEARTHROW", "Throw Spear", function(act)
	if act.invobject then
		local pvp = GLOBAL.TheNet:GetPVPEnabled()
		local target = act.target
		if target == nil then
			for k,v in pairs(GLOBAL.TheSim:FindEntities(act.pos.x, act.pos.y, act.pos.z, 20)) do
				if v.replica and v.replica.combat and v.replica.combat:CanBeAttacked(act.doer) and
				act.doer.replica and act.doer.replica.combat and act.doer.replica.combat:CanTarget(v)
				and (not v:HasTag("wall")) and (pvp or ((not pvp)
						and (not (act.doer:HasTag("player") and v:HasTag("player"))))) then
					target = v
					break
				end
			end
		end
		if target then
				local prefab = act.invobject.prefab
				act.invobject.components.spearthrowable:LaunchProjectile(act.doer, target)
				local newspear = act.doer.components.inventory:FindItem(
					function(item) return item.prefab == prefab end)
				if newspear then
					act.doer.components.inventory:Equip(newspear)
				end
		elseif act.doer.components and act.doer.components.talker then
			local fail_message = "There's nothing to throw it at."
			if act.doer.prefab == 'wx78' then fail_message = "NO TARGET" end
			act.doer.components.talker:Say(fail_message)
		end
		return true
	end
end)
SPEARTHROW.priority = 4
SPEARTHROW.rmb = true
SPEARTHROW.distance = 10
SPEARTHROW.mount_valid = true

local State = GLOBAL.State
local TimeEvent = GLOBAL.TimeEvent
local EventHandler = GLOBAL.EventHandler
local FRAMES = GLOBAL.FRAMES

local throw_spear = State({
        name = "throw_spear",
        tags = { "attack", "notalking", "abouttoattack", "autopredict" },

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
			inst.components.combat:SetTarget(target)
			inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("throw")

            inst.sg:SetTimeout(2)

            if target ~= nil and target:IsValid() then
                inst:FacePoint(target.Transform:GetWorldPosition())
                inst.sg.statemem.attacktarget = target
			elseif buffaction ~= nil and buffaction.pos ~= nil then
                inst:FacePoint(buffaction.pos)
            end
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()
            end
        end,})
AddStategraphState("wilson", throw_spear)

local throw_spear_client = State({
        name = "throw_spear",
        tags = { "attack", "notalking", "abouttoattack" },

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
			inst.replica.combat:StartAttack()
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("throw")

            inst.sg:SetTimeout(2)

            if target ~= nil and target:IsValid() then
                inst:FacePoint(target.Transform:GetWorldPosition())
                inst.sg.statemem.attacktarget = target
			elseif buffaction ~= nil and buffaction.pos ~= nil then
                inst:FacePoint(buffaction.pos)
            end
			if buffaction ~= nil then
				inst:PerformPreviewBufferedAction()
			end
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst:ClearBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.replica.combat:CancelAttack()
            end
        end,})
AddStategraphState("wilson_client", throw_spear_client)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(SPEARTHROW, function(inst, action)
	if not inst.sg:HasStateTag("attack") then
		return "throw_spear"
	end
end))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(SPEARTHROW, function(inst, action)
	if not inst.sg:HasStateTag("attack") then
		return "throw_spear"
	end
end))

local function spearthrow_point(inst, doer, pos, actions, right)
	if right then
		local target = nil
		local pvp = GLOBAL.TheNet:GetPVPEnabled()
		if RANGE_CHECK then
			for k,v in pairs(GLOBAL.TheSim:FindEntities(pos.x, pos.y, pos.z, 2)) do
				if v.replica and v.replica.combat and v.replica.combat:CanBeAttacked(doer) and
				doer.replica and doer.replica.combat and doer.replica.combat:CanTarget(v)
				and (not v:HasTag("wall")) and (pvp or ((not pvp)
						and (not (doer:HasTag("player") and v:HasTag("player"))))) then
					target = v
					break
				end
			end
		end
		if target then
			table.insert(actions, GLOBAL.ACTIONS.SPEARTHROW)
		end
	end
end
AddComponentAction("POINT", "spearthrowable", spearthrow_point)

local function spearthrow_target(inst, doer, target, actions, right)
	local pvp = GLOBAL.TheNet:GetPVPEnabled()
	if right and (not target:HasTag("wall"))
		and doer.replica.combat ~= nil
		and doer.replica.combat:CanTarget(target)
		and target.replica.combat:CanBeAttacked(doer)
		and (pvp or ((not pvp)
					and (not (doer:HasTag("player") and target:HasTag("player")))))
			then
		table.insert(actions, GLOBAL.ACTIONS.SPEARTHROW)
	end
end
AddComponentAction("EQUIPPED", "spearthrowable", spearthrow_target)
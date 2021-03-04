--models/props_halloween/pumpkin_01.mdl
local Spell = { }
Spell.LearnTime = 1200
Spell.Description = [[
	Causes target to have a pumpkin as a head.
]]
Spell.Category = "Runespells - Jinxes"
Spell.FlyEffect = "hpw_flipendo_main"
Spell.ImpactEffect = "hpw_expulso_impact"
Spell.ApplyDelay = 0.5
Spell.AccuracyDecreaseVal = 0.3
Spell.Unforgivable = false
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_1, ACT_VM_PRIMARYATTACK_2 }
Spell.SpriteColor = Color(255, 155, 44)
Spell.Fightable = true
Spell.DoSparks = true

Spell.NodeOffset = Vector(938, -511, 0)

local mat = Material("cable/hydra")
local mat2 = Material("cable/xbeam")

Spell.FightingEffect = function(nPoints, points) 
	render.SetMaterial(mat)
	for i = 1, 3 do
		render.StartBeam(nPoints)
			for k, v in pairs(points) do
				render.AddBeam(v, (k / nPoints) * 60, math.Rand(0, 2), Color(255, 155, 44))
			end 
		render.EndBeam()
	end

	render.SetMaterial(mat2)
	for i = 1, 2 do
		render.StartBeam(nPoints)
			for k, v in pairs(points) do
				render.AddBeam(v, (k / nPoints) * 10, math.Rand(0, 1), Color(255, 155, 44))
			end
		render.EndBeam()
	end

	for k, v in pairs(points) do
		if math.random(1, (1 / RealFrameTime()) * 2) == 1 then HpwRewrite.MakeEffect("hpw_expulso_impact", v, AngleRand()) end
	end
end

function Spell:Draw(spell)
	self:DrawGlow(spell)
end

function Spell:OnSpellSpawned(wand, spell)
	sound.Play("weapons/stunstick/alyx_stunner2.wav", spell:GetPos(), 75, 255)
	sound.Play("npc/antlion/land1.wav", spell:GetPos(), 75, 99)
	spell:EmitSound("npc/barnacle/barnacle_tongue_pull2.wav", 75, 111)
	--wand:PlayCastSound()
end

function Spell:OnRemove(spell)
	if CLIENT then
		local dlight = DynamicLight(spell:EntIndex())
		if dlight then
			dlight.pos = spell:GetPos()
			dlight.r = 255
			dlight.g = 155
			dlight.b = 44
			dlight.brightness = 6
			dlight.Decay = 1000
			dlight.Size = 256
			dlight.DieTime = CurTime() + 1
		end
	end
end

function Spell:OnFire(wand)
	return true
end

function Spell:Pumpkin( ply )
	local c_Model = ents.Create("prop_dynamic")
	ply:EmitSound("npc/barnacle/barnacle_bark2.wav",75,88,3)
	
	c_Model:SetModel( "models/props_halloween/pumpkin_01.mdl" )
	c_Model:SetMoveType( MOVETYPE_NONE ) 
	
	
	
	ply:ManipulateBoneScale( ply:LookupBone("ValveBiped.Bip01_Head1"), Vector(0.1,0.1,0.1) )
	c_Model:Spawn()
	c_Model:SetModelScale( ply:GetModelScale() * 0, 0 )
	c_Model:SetModelScale( ply:GetModelScale() * 0.6, 1 )
	Attach = ply:GetAttachment( ply:LookupAttachment( "eyes" ) )
	c_Model:SetPos( Attach.Pos )
	c_Model:SetAngles( Attach.Ang )
	c_Model:SetPos(c_Model:LocalToWorld( Vector(-5,0,-10) ))
	c_Model:SetParent(ply)
	c_Model:Fire("SetParentAttachmentMaintainOffset", "eyes", 0.01)
	if IsValid(ply) then
		if ply:IsPlayer() && IsValid(ply) then
			ply:SendLua([[MeloBlind(1,255)]])
		elseif ply:IsNPC() && IsValid(ply) then
			local delay = delay or 1
			local Cond = 8
			

			timer.Create("Melofors_NPCRun_"..ply:EntIndex(),1,15, function()
				if IsValid(ply) then ply:SetSchedule(Cond) end
				if IsValid(ply) then ply:SetCondition(Cond) end
				if IsValid(ply) then ply:DropWeapon() end
			end)
		end
		
		timer.Simple(15,function()
			if ply:IsPlayer() && IsValid(ply) then
				ply:SendLua([[MeloBlind(0,0)]])
			elseif ply:IsNPC() && IsValid(ply) then
				local delay = delay or 1
					if IsValid(ply) then
					ply:SetSchedule(0)

					timer.Simple(delay, function()
						if(IsValid(ply)) then ply:SetCondition(0) end
					end)
				end
			end
			if IsValid(c_Model) then
				c_Model:Remove()
				ply:ManipulateBoneScale( ply:LookupBone("ValveBiped.Bip01_Head1"), Vector(1,1,1) )
			end
		end)
	end
end
function Spell:OnCollide(spell, data)
	local ent = data.HitEntity
	if ent:GetClass() == "worldspawn" then
		local c_Model = ents.Create("prop_dynamic")
		
		c_Model:SetModel( "models/props_foliage/bramble001a.mdl" )
		c_Model:SetMoveType( MOVETYPE_NONE ) 		
		c_Model:Spawn()
		c_Model:SetPos(data.HitPos)
		c_Model:SetModelScale( 1* 0, 0 )
		c_Model:SetModelScale( 1* 0.6, 1 )


		local c_Model2 = ents.Create("prop_dynamic")
		
		c_Model2:SetModel( "models/props_halloween/pumpkin_01.mdl" )
		c_Model2:SetMoveType( MOVETYPE_NONE ) 		
		c_Model2:Spawn()
		c_Model2:SetPos(data.HitPos)
		c_Model2:SetModelScale( 1* 0, 0 )
		c_Model2:SetModelScale( 1* 1.3, 1 )
		sound.Play("weapons/physcannon/energy_sing_flyby1.wav", c_Model2:GetPos(), 160, 150,1)
		
		timer.Simple(3,function()
			if IsValid(c_Model) then
				c_Model:SetModelScale( 1* 0, 1)
				c_Model2:SetModelScale( 1* 0, 1)
			end
		end)		
		timer.Simple(5,function()
			if IsValid(c_Model) then
				c_Model:Remove()
				c_Model2:Remove()
			end
		end)		
	end
	if IsValid(ent) then
		local force = spell:GetFlyDirection() * 10000

		if ent:IsNPC() or ent:IsPlayer() then 
			Spell:Pumpkin( ent )
		elseif ent.HPWRagdolledEnt then
			Spell:Pumpkin( ent )
			HpwRewrite.TakeDamage(ent, self.Owner, ent.MaxPenetration, force)
		end
	end
end

HpwRewrite:AddSpell("Melofors", Spell)
--models/props_halloween/pumpkin_01.mdl
local Spell = { }
Spell.LearnTime = 1200
Spell.Description = [[
	Causes target to have Antlers on their Head.
]]
Spell.Category = {"Runespells - Dark Arts","Runespells - Jinxes"}
Spell.FlyEffect = "hpw_dragoner_main"
Spell.ImpactEffect = "hpw_expulso_impact"
Spell.ApplyDelay = 0.5
Spell.AccuracyDecreaseVal = 0.3
Spell.Unforgivable = false
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_1, ACT_VM_PRIMARYATTACK_2 }
Spell.SpriteColor = Color(11, 255, 44)
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
				render.AddBeam(v, (k / nPoints) * 60, math.Rand(0, 2), Color(11, 255, 44))
			end 
		render.EndBeam()
	end

	render.SetMaterial(mat2)
	for i = 1, 2 do
		render.StartBeam(nPoints)
			for k, v in pairs(points) do
				render.AddBeam(v, (k / nPoints) * 10, math.Rand(0, 1), Color(11, 255, 44))
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
	sound.Play("misc/halloween/spell_teleport.wav", spell:GetPos(), 75, 155)
	spell:EmitSound("npc/scanner/scanner_nearmiss2.wav", 89, 222)
	wand:PlayCastSound()
end

function Spell:OnRemove(spell)
	if CLIENT then
		local dlight = DynamicLight(spell:EntIndex())
		if dlight then
			dlight.pos = spell:GetPos()
			dlight.r = 11
			dlight.g = 255
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

function Spell:Antlers( ply )
	local c_Model = ents.Create("prop_dynamic")
	ply:EmitSound("items/pumpkin_drop.wav",75,88,3)
	
	c_Model:SetModel( "models/player/items/soldier/soldier_holiday_antlers.mdl" )
	c_Model:SetMoveType( MOVETYPE_NONE ) 
	c_Model:Spawn()
	c_Model:SetModelScale( ply:GetModelScale() * 0, 0 )
	c_Model:SetModelScale( ply:GetModelScale() * 0.6, 1 )
	Attach = ply:GetAttachment( ply:LookupAttachment( "eyes" ) )
	c_Model:SetPos( Attach.Pos )
	c_Model:SetAngles( Attach.Ang )
	c_Model:SetPos(c_Model:LocalToWorld( Vector(-5,0,-3) ))
	c_Model:SetParent(ply)
	c_Model:Fire("SetParentAttachmentMaintainOffset", "eyes", 0.01)
	if IsValid(ply) then
		if ply:IsPlayer() && IsValid(ply) then
			timer.Simple(15,function()
				if IsValid(c_Model) then
					c_Model:Remove()
				end
			end)
		end
	end
end
function Spell:OnCollide(spell, data)
	local ent = data.HitEntity
	if IsValid(ent) then
		local force = spell:GetFlyDirection() * 10000

		if ent:IsNPC() or ent:IsPlayer() then 
			Spell:Antlers( ent )
		elseif ent.HPWRagdolledEnt then
			Spell:Antlers( ent )
			HpwRewrite.TakeDamage(ent, self.Owner, ent.MaxPenetration, force)
		end
	end
end

HpwRewrite:AddSpell("Anteoculatia", Spell)
--models/props_halloween/pumpkin_01.mdl
local Spell = { }
Spell.LearnTime = 1200
Spell.Description = [[
	This jinx causes the target to turn into a duck.
]]
Spell.Category = "Runespells - Jinxes"
Spell.FlyEffect = "hpw_flipendo_main"
Spell.ImpactEffect = "hpw_expulso_impact"
Spell.ApplyDelay = 0.5
Spell.AccuracyDecreaseVal = 0.3
Spell.Unforgivable = false
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_1, ACT_VM_PRIMARYATTACK_2 }
Spell.SpriteColor = Color(255, 200, 44)
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
				render.AddBeam(v, (k / nPoints) * 60, math.Rand(0, 2), Color(255, 255, 44))
			end 
		render.EndBeam()
	end

	render.SetMaterial(mat2)
	for i = 1, 2 do
		render.StartBeam(nPoints)
			for k, v in pairs(points) do
				render.AddBeam(v, (k / nPoints) * 10, math.Rand(0, 1), Color(255, 255, 44))
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
	sound.Play("weapons/fx/nearmiss/bulletltor04.wav", spell:GetPos(), 75, 55)
	--spell:EmitSound("npc/barnacle/barnacle_tongue_pull2.wav", 75, 111)
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

function Spell:Ducklifors( ply )
	ply:EmitSound("npc/barnacle/barnacle_bark2.wav",75,88,3)
	local oldMdl = nil
	if IsValid(ply) then
		if ply:IsPlayer() && IsValid(ply) || ply:IsNPC() && IsValid(ply) then
			if ply:GetModel() != "models/workshop/player/items/pyro/eotl_ducky/eotl_bonus_duck.mdl" then
				oldMdl = ply:GetModel()
			end
			ply:SetModel("models/workshop/player/items/pyro/eotl_ducky/eotl_bonus_duck.mdl")
		end
		
		timer.Simple(5,function()
			if ply:IsPlayer() && IsValid(ply) && oldMdl != nil || ply:IsNPC() && IsValid(ply) && oldMdl != nil then
				ply:SetModel(oldMdl)
			end
		end)
	end
end
function Spell:OnCollide(spell, data)
	local ent = data.HitEntity
	if ent:GetClass() == "worldspawn" then
		sound.Play("weapons/physcannon/energy_sing_flyby1.wav", data.HitPos, 160, 150,1)	
	end
	if IsValid(ent) then

		if ent:IsNPC() or ent:IsPlayer() then 
			Spell:Ducklifors( ent )
		end
	end
end

HpwRewrite:AddSpell("Ducklifors", Spell)
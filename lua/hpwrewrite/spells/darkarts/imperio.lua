--models/props_halloween/pumpkin_01.mdl
local Spell = { }
Spell.LearnTime = 1200
Spell.Description = [[
	Makes people do what you want them to.
]]
Spell.Category = {"Runespells - Dark Arts","Runespells - Curses"}
Spell.FlyEffect = ""
Spell.ImpactEffect = ""
Spell.ApplyDelay = 0.5
Spell.AccuracyDecreaseVal = 0.3
Spell.Unforgivable = true
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_3 }
Spell.SpriteColor = Color(155, 99, 255)
Spell.Fightable = true
Spell.DoSparks = true

Spell.NodeOffset = Vector(938, -511, 0)
local points = { }
local mat = Material("cable/hydra")
local mat2 = Material("cable/xbeam")

Spell.FightingEffect = function(nPoints, points) 
	render.SetMaterial(mat)
	for i = 1, 3 do
		render.StartBeam(nPoints)
			for k, v in pairs(points) do
				render.AddBeam(v, (k / nPoints) * 60, math.Rand(0, 2), Color(155, 99, 255))
			end 
		render.EndBeam()
	end

	render.SetMaterial(mat2)
	for i = 1, 2 do
		render.StartBeam(nPoints)
			for k, v in pairs(points) do
				render.AddBeam(v, (k / nPoints) * 10, math.Rand(0, 1), Color(155, 99, 255))
			end
		render.EndBeam()
	end

	for k, v in pairs(points) do
		if math.random(1, (1 / RealFrameTime()) * 2) == 1 then HpwRewrite.MakeEffect("hpw_expulso_impact", v, AngleRand()) end
	end
end

function Spell:Draw(spell)
	--self:DrawGlow(spell)
end

function Spell:OnSpellSpawned(wand, spell)

	--wand:PlayCastSound()
end

function Spell:OnRemove(spell)
	if CLIENT then
		local dlight = DynamicLight(spell:EntIndex())
		if dlight then
			dlight.pos = self.Owner:GetPos()
			dlight.r = 155
			dlight.g = 99
			dlight.b = 255
			dlight.brightness = 6
			dlight.Decay = 1000
			dlight.Size = 256
			dlight.DieTime = CurTime() + 1
		end
	end
end

function Spell:OnFire(wand)
	sound.Play("hl1/ambience/steamburst1.wav", self.Owner:GetPos(), 89, 188)
	self.Owner:EmitSound("ambient/machines/machine1_hit2.wav", 89, 188)
	self.Distance = 1200
	local ply = self.Owner
	local tr = util.TraceHull({
		start = ply:GetShootPos(),
		endpos = ply:GetShootPos() + ply:GetAimVector() * self.Distance,
		filter = ply
	})
	

	local data2 = { }
	local ent = tr.Entity
	if IsValid(ent) then

		if ent:IsNPC() or ent:IsPlayer() then
			data2.Target = ent
			Spell:ImperioEffect( ent )
		elseif ent.HPWRagdolledEnt then
		end
	end


	data2.Owner = self.Owner
	data2.Wand = HpwRewrite:GetWand(self.Owner)
	points[#points + 1] = data2
	return false, data2
end

function Spell:ImperioEffect( ply )
	local Randint = math.random(1,math.huge)
	if IsValid(ply) then
		if ply:IsPlayer() && IsValid(ply) then
			hook.Add("StartCommand","Imperius_"..ply:EntIndex().."_"..Randint,function(ply2,cmd)
				local NewCmd = nil
				for _, data in pairs(points) do
					if ply2 == data.Owner then
					end
					if ply2 == data.Target then
						cmd:SetViewAngles(( data.Owner:GetEyeTrace().HitPos - data.Target:GetPos() ):GetNormalized():Angle())
						cmd:SetForwardMove( 1000 )
						cmd:SetButtons( bit.bor( IN_ATTACK , IN_USE ) )
					end
				end
			end)
		end
		
		timer.Simple(15,function()
			hook.Remove("StartCommand","Imperius_"..ply:EntIndex().."_"..Randint)
			table.Empty(points)
		end)
	end
end
function Spell:OnCollide(spell, data)


end

HpwRewrite:AddSpell("Imperio", Spell)
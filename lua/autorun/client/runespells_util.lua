function MeloBlind( bool, amt )
	if bool then
		local function blind()
			draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color( 255, 155, 11, amt ) )
		end
		hook.Add( "HUDPaint", "meloblind", blind )
	else
		hook.Remove( "HUDPaint", "meloblind" )
	end
end
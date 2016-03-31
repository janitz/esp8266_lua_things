
local floor=function(i)
	return i-(i%1) 
end

local calcServo = function(inp)-- 0-100 to 57-233
	servoOR=inp
	return 57 + (inp * 176 / 100)
end

local calcLicht = function(inp) -- 0-100 to ws2812b string
	lichtOR=inp
	return string.char(floor(inp * 2.55)):rep(5 * 3)
end

if(enableRegelung)then
	local soll = hell/100 --von 0 bis 1
	local ist = adc.read(0) / 1024 --von 0 bis 1
	local ki = 0.05
	--print(floor(ist*100) .. " : " .. floor(soll*100))
	
	-- regelung
	local differenz = (soll - ist) * ki
	local stellgroesse = lastStellgroesse + differenz
	
	--überlauf verhindern
	if(stellgroesse < 0)then
		stellgroesse = 0
	elseif(stellgroesse > 1)then
		stellgroesse = 1
	end
	
	--für nächsten regelzyklus merken
	lastStellgroesse = stellgroesse
	
	
	--ausgangsgröße skalieren 
	local reglerOut = stellgroesse * 200
	
	
	local servoOut = 0
	local lichtOut = 0
	
	
	--ausgang auf die 2 aktoren verteilen
	if(reglerOut<=100)then
		servoOut = calcServo(reglerOut)
		lichtOut = calcLicht(0)
	else
		servoOut = calcServo(100)
		lichtOut = calcLicht(reglerOut-100)
	end
	
	--aktoren steuern
	ws2812.writergb(4, lichtOut)
	pwm.setup(1, 100, servoOut)
	pwm.start(1)
else
	ws2812.writergb(4, calcLicht(lichtOR))
	pwm.setup(1, 100, calcServo(servoOR))
	pwm.start(1)
end


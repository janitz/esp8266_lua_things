
hell=0
lastStellgroesse=0
enableRegelung=true
lichtOR=0
servoOR=0
aps={}

ws2812.writergb(4, string.char(0):rep(5 * 3))
tmr.alarm(0, 5000, tmr.ALARM_SINGLE, function()
	dofile("AP_setup.lc")
	dofile("webserver.lc")
	tmr.alarm(1, 100, 1, function() dofile("regelung.lc") end)	
end)



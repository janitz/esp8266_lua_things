lighton = 0
cnt = 0
leds = 15
t={}; 
curr = string.char(255,0,0)
for count = 1, leds do
    t[count] = curr
end

tmr.alarm(0,100,1,function()
    cnt = cnt + 1
    if cnt > (leds-1) then
        cnt = 0
        if lighton == 0 then 
            curr = string.char(255,0,0)
            lighton = 1
        elseif lighton == 1 then
            curr = string.char(0,255,0)
            lighton = 2
        else
            curr = string.char(0,0,255)
            lighton = 0
        end 
    end
    
    for count = (leds-1), 1, -1 do
        t[count + 1] = t[count]; 
    end
    
    t[1] = curr
    
    toLed(t) 
end)


toLed = function(t)
    local str
    str = ''
    for count = 1, leds do
        str = str .. t[count]; 
    end
    ws2812.writergb(4, str);
end

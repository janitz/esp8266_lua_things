local ntpserver="pool.ntp.org" --pool.ntp.org  or time.nist.gov
local udptimer=2
local udptimeout=1000
local request=string.char(0x1b) .. string.rep( 0x0, 47)  
cu=nil
cu=net.createConnection(net.UDP,0)
cu:dns(ntpserver,function(conn,ip) 
    print("from IP:",ip);
    loc_ip=ip;  
    cu:on("receive",function(cu,c) 

        --close connection
        tmr.stop(udptimer)
        cu:close()
        cu=nil 

        --calc timestamp
        bytes=c:sub(41,44)
        highw = bytes:byte(1) * 256 + bytes:byte(2)
        loww = bytes:byte(3) * 256 + bytes:byte(4)    
        ntpstamp=( highw * 65536 + loww ) + ( 2 * 3600)   -- 1=timezone NTP-stamp, seconds since 1.1.1900
        ustamp=ntpstamp - 1104494400 - 1104494400      -- UNIX-timestamp, seconds since 1.1.1970 needs to be done twice
       
        --make unix timestamp readable        
        hour = ustamp % 86400 / 3600
        minute = ustamp % 3600 / 60
        second = ustamp % 60
        print(string.format("%02u:%02u:%02u",hour,minute,second))
    end)
    tmr.alarm(udptimer,udptimeout,0,function() cu:close();cu=nil ;print("timeout");collectgarbage("collect")  end) 
    cu:connect(123,ip)
    cu:send(request)
end)

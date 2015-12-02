wifi.setmode(wifi.STATION)
dofile("connect.lua")
print(wifi.sta.getip())
led1 = 0
led2 = 0
led3 = 0
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        buf = buf.."<h1> ESP8266 Web Server</h1>";
        buf = buf.."<p>Rot  <a href=\"?pin=ON1\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF1\"><button>OFF</button></a></p>";
        buf = buf.."<p>Grün <a href=\"?pin=ON2\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF2\"><button>OFF</button></a></p>";
        buf = buf.."<p>Blau <a href=\"?pin=ON3\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF3\"><button>OFF</button></a></p>";
        local _on,_off = "",""
        if(_GET.pin == "ON1")then
              led1 = 255;
        elseif(_GET.pin == "OFF1")then
              led1 = 0;
        elseif(_GET.pin == "ON2")then
              led2 = 255;
        elseif(_GET.pin == "OFF2")then
              led2 = 0;
        elseif(_GET.pin == "ON3")then
              led3 = 255;
        elseif(_GET.pin == "OFF3")then
              led3 = 0;
        end
        ws2812.writergb(4,string.char(led1,led2,led3))
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)

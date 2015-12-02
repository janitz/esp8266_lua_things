wifi.setmode(wifi.STATION)
wifi.sta.config("SSID","PW")
print( string.format("ip-adr:  %s\r\nnetmask: %s\r\ngateway: %s",wifi.sta.getip()))

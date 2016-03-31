port=80

local handle_request=function(conn,request)

	local response={}
		
	local htmlResponse="HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nAccess-Control-Allow-Origin: *\r\nConnection: close\r\n\r\n"
	local cssResponse="HTTP/1.1 200 OK\r\nContent-Type: text/css\r\nAccess-Control-Allow-Origin: *\r\nConnection: close\r\n\r\n"
	local icoResponse="HTTP/1.1 200 OK\r\nContent-Type: image/x-icon\r\nAccess-Control-Allow-Origin: *\r\nConnection: close\r\n\r\n"
	
	local hex_to_char = function(x)
		return string.char(tonumber(x, 16))
	end

	local unescape = function(url)
		return url:gsub("%%(%x%x)", hex_to_char)
	end
		
	local add_txt=function(txt)
		table.insert(response,txt)
	end
	
	local add_file=function(f)
		file.open(f,"r")
		local block = file.read(1024)
		while block do
			add_txt(block)
			block=file.read(1024)
		end
		file.close()
	end

	local send_response=function(conn)
		if #response>0 then
			conn:send(table.remove(response,1))
		else
			conn:close()
		end
	end
	
	

	local _,_,method,path,vars=string.find(request,"([A-Z]+) (.+)?(.+) HTTP");
	if(method==nil)then
		_,_,method,path=string.find(request,"([A-Z]+) (.+) HTTP");
	end
	
	local _GET={}
	if(vars~=nil)then
		for k,v in string.gmatch(vars,"(%w+)=([^&]+)&*")do
			_GET[k]=v
		end
	end
	
	if(_GET.ssid)then
		ssid=unescape(_GET.ssid:gsub("+", " "))
		dofile("set_wifi.lc")
	end
	
	if(_GET.pwd)then
		pwd=unescape(_GET.pwd:gsub("+", " "))
		dofile("set_wifi.lc")
	end
	
	if(_GET.hell)then		
		hell=_GET.hell
		enableRegelung=true
	end
	
	if(_GET.servo)then		
		servoOR=_GET.servo
		enableRegelung=false
	end
	
	if(_GET.licht)then		
		lichtOR=_GET.licht
		enableRegelung=false
	end
	
	if(_GET.restart)then		
		node.restart()	
	end
	
	path = string.lower(path)
	
	if(path=='/' or path=="/index")then
		add_txt(htmlResponse)
		add_file('index.htm')
		add_txt("<script> changeValue(" .. hell .. "); </script>")
	elseif(path=="/manuell")then
		add_txt(htmlResponse)
		add_file('manuell.htm')
		add_txt("<script> changeValue(" .. lichtOR .. ", " .. servoOR.. "); </script>")
	elseif path == '/setup' then
		add_txt(htmlResponse)
		local ip = wifi.sta.getip()
		wifi.sta.getap(function(t) aps=t end)
	
		add_file("setup.htm")
		
		add_txt("<script>")
		
		if(ip ~=nil )then
			add_txt('document.getElementById("currIP").innerHTML="Current: '..ssid..' : '..ip..'";')
		else
			add_txt('document.getElementById("currIP").innerHTML="Current: no connection...";')
		end
		
		add_txt("var cell;")
		for k, v in pairs(aps) do	
				add_txt('cell=document.getElementById("myTable").insertRow(0).insertCell(0);')
				add_txt('cell.setAttribute("onclick", "cellClicked(this)", 0);')
				add_txt('cell.innerHTML = "'..k..'";')
				add_txt('cell.setAttribute("id", "cell'..k..'", 0);')
		end
		add_txt("</script>")

	elseif path == '/favicon.ico' then
		add_txt(icoResponse)
		add_file('favicon.ico')	 
	elseif path == '/stdstyle.css' then
		add_txt(cssResponse)
		add_file('stdStyle.css')	 
	else
		add_txt("unknown path: " .. path .. "\r\n")
	end
	
	conn:on("sent",send_response)
	send_response(conn)
end

srv=net.createServer(net.TCP,30)

srv:listen(port,function(conn)
	conn:on("receive",handle_request)
end)


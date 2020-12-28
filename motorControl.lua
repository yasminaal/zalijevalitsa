dofile('config.lua')

responseHeader = function(code, type)      
    return "HTTP/1.1 " .. code .. "\r\nConnection: close\r\nContent-Type: " .. 
    type .. "\r\n\r\n";   
end 

function smjer(spd)
	if spd >= 0 then 
		return FWD
	else
		return REV
	end
end

function motorControl(sock,data)
	path = string.match(data, 'GET (.-) HTTP')
	get = string.match(path, '/%?(.-)$')

	if get then
		requests = {left="0", right="0"}
		for i in string.gmatch(get.."&", "(.-)&") do
			k, v = string.match(i, "(.-)=(.+)$")
			requests[k] = v
		end

		lijevi=tonumber(requests["left"])
		desni=tonumber(requests["right"])

		motor_a(smjer(lijevi), math.abs(lijevi))
		motor_b(smjer(desni), math.abs(desni))
	end

	sock:on("sent", function(conn) conn:close() end)

	head = {}
	head["Connection"] = "close"
	responseMetaData = headers( httpCodes.OK, head  ) 
	sock:send(responseMetaData .. "Test", function(sock) sock:close() end)
end
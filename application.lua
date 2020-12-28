dofile("httpserver-functions.lua")
dofile('config.lua')
-- dofile("motorControl.lua")

-- Create server and listen on port 80
server=net.createServer(net.TCP, 80)
server:listen(80, function(conn)
	-- print(conn:getpeer())
	conn:on("receive", requestHandler)
end)

index = function(sock, data)
	print("INDEX requested")
	respondFileRequest(sock, dirPrefix.."/index.html")
	-- sock:on("sent", function(conn) conn:close() end)

	-- head = {}
	-- head["Connection"] = "close"
	-- responseMetaData = headers( httpCodes.OK, head  ) 
	-- sock:send(responseMetaData .. "Test", function(sock) sock:close() end)
end

-- powerOn = function(sock, data)
-- 	gpio.set()
-- end

pump_start = function(time, strength)
	motor_a(FWD, strength)
	tmr.create():alarm(time, tmr.ALARM_SINGLE, function(T)
		motor_a(FWD, 0)
	end)
end

water = function(sock, data)
	path = string.match(data, 'GET (.-) HTTP')
	get = string.match(path, '/%?(.-)$')

	-- 192.168.1.4/water?time=5&strength=1
	requests = {time=0, strength=0}
	if get then
		for i in string.gmatch(get.."&", "(.-)&") do
			k, v = string.match(i, "(.-)=(.+)$")
			requests[k] = v
		end
	end

	time = tonumber(requests["time"])
	strength = tonumber(requests["strength"])
	pump_start(time, strength)

	print(time)
	print(strength)

	head = {}
	head["Connection"] = "close"
	responseMetaData = headers( httpCodes.OK, head  ) 
	sock:send(responseMetaData .. time .. " " .. strength, function(sock) sock:close() end)

end

-- function motorControl(sock,data)
-- 	path = string.match(data, 'GET (.-) HTTP')
-- 	get = string.match(path, '/%?(.-)$')

-- 	if get then
-- 		requests = {left="0", right="0"}
-- 		for i in string.gmatch(get.."&", "(.-)&") do
-- 			k, v = string.match(i, "(.-)=(.+)$")
-- 			requests[k] = v
-- 		end

-- 		lijevi=tonumber(requests["left"])
-- 		desni=tonumber(requests["right"])

-- 		motor_a(smjer(lijevi), math.abs(lijevi))
-- 		motor_b(smjer(desni), math.abs(desni))
-- 	end

-- 	sock:on("sent", function(conn) conn:close() end)

-- 	head = {}
-- 	head["Connection"] = "close"
-- 	responseMetaData = headers( httpCodes.OK, head  ) 
-- 	sock:send(responseMetaData .. "Test", function(sock) sock:close() end)
-- end

responds = {}
responds["/"] = index
-- responds["/ON"] = powerOn
-- responds["/OFF"] = powerOff
responds["/water"] = water
-- responds["/cancelAll"] = cancelAll

-- status = gpio.LOW
-- gpio.mode(0, gpio.OUTPUT)

-- blink = function(timer)
-- 	if status == gpio.LOW then
-- 		status = gpio.HIGH
-- 	else
-- 		status = gpio.LOW
-- 	end

-- 	gpio.write(0, status)
-- end

-- tmr.create():alarm(3000, tmr.ALARM_AUTO, blink)
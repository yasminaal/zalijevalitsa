dirPrefix = 'www'
-- staticPrefix = 'static'

httpCodes = {}
httpCodes["OK"] = "HTTP/1.1 200 OK"
httpCodes["NOTFOUND"] = "HTTP/1.1 404 Not Found"

function headers(httpCode, headers)
	resp = httpCode.."\r\n"

	for key,val in pairs(headers) do
		resp= resp..key..": "..val.."\r\n"
	end

	return resp.."\r\n"
end

function sendFile(sck,f, p)
	data = f:read(1024)
	if data ~= nil then
		sck:send(data, function(sock) sendFile(sck,f, p) end)
	else
		-- print("Closing connection for file: "..p)
		sck:close()
		f:close()
	end
end

fileSendWrapper = function(fhandler, fname)
  return (function(socket) 
  			sendFile(socket,fhandler,fname)
  		 end) 
end

-- Main function to use on sending static and other files
function respondFileRequest(sock,loc)
	f = file.open(loc, "r")
	if f ~= nil then
		-- print("HTTP/1.1 200 OK "..loc)
		sock:send("HTTP/1.1 200 OK\r\n\r\n",  fileSendWrapper(f, loc))
	else
		-- print("HTTP/1.1 404 Not Found "..loc)
		sock:send("HTTP/1.1 404 Not Found\r\n\r\n", function(sock) sock:close() end)
	end
end

-- Main handling of requests
function requestHandler(sock,data)
	path = string.match(data, 'GET (.-) HTTP/1.1')
	if path == nil then return end

	withoutParams = string.match(path, '(.-)%?')
	if withoutParams ~= nil then
		path = withoutParams
	end
	
	if string.match(path, './$') then
		print("eto" .. path)
		path = path:sub(1, -2)
	end

	responseFun = responds[path]

	if responseFun == nil then
		-- Assume that request is a static file if path is not found in the responds table
		respondFileRequest(sock, dirPrefix..path)
	else
		responseFun(sock,data)
	end
end

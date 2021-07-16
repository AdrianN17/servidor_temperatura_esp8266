
PIN = 2 

SSID = "NOMBRE_WIFI"
PASSWORD = "CONTRASENA_WIFI"

mytimer = nil

function GetSensorData()
    local s, t, h, tc, hc = dht.read11(2)

    return {status = s, temp = t, humi = h, temp_dec = tc, humi_dec = hc}
end

function httpConnection()
    if wifi.sta.getip() == nil then 
        print("Waiting for Wifi connection")
        mytimer:start(true)
    else 
        mytimer:stop()
        mytimer:unregister()

        print ("ESP8266 mode is: " .. wifi.getmode ( ))
        print ("The module MAC address is: " .. wifi.ap.getmac ( ))
        print ("Config done, IP is " .. wifi.sta.getip ( ))

        svr = net.createServer(net.TCP)
        svr:listen(80, http_conn)
    end

end

function http_conn(conn)
    conn:on("receive",function(conn,payload)
        print(payload)

        local data = GetSensorData()

        conn:send("HTTP/1.0 200 OK\r\nServer: NodeMCU on ESP8266\r\n'Content-Type': 'application/json'\r\n\r\n")

        if (string.find(payload, "POST / HTTP/1.1") ~= nil) then 
            conn:send(sjson.encode(data))
        end
        

        --[[conn:send('<!DOCTYPE HTML>\n')
        conn:send('<html><head>')
        conn:send('<title>Demo</title>')
        conn:send('</head>')
        conn:send('<body><h1>Temperatura</h1></body>')
        
        

        if(status == dht.OK) then 
            conn:send('<h2>Temperatura : ' .. temp .. ' Celsius </h2>')
            conn:send('<h2>Humedad : ' .. humi .. ' </h2>')
        else
            conn:send('<h2>Error</h2>')
        end

        conn:send('</body>')

        conn:send('</html>')]]
        conn:on("sent",function(conn) conn:close() end)
    end)

end   


function connect()

    wifi.setmode(wifi.STATION)

    local wificonfig = {ssid = SSID, pwd = PASSWORD, save = false}

    wifi.sta.config(wificonfig)

    mytimer = tmr.create()
    mytimer:register(5000, tmr.ALARM_SEMI, function() httpConnection() end)
    mytimer:start()

end

connect()






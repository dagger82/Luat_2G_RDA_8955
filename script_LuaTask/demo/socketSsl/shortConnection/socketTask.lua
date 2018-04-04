--- 模块功能：socket ssl短连接功能测试
-- @author openLuat
-- @module socketSslShortConnection.socketTask
-- @license MIT
-- @copyright openLuat
-- @release 2018.03.27

module(...,package.seeall)

require"socket"
require"ntp"

--同步网络时间，因为证书校验时会用到系统时间
ntp.timeSync()
--启动socket客户端任务
sys.taskInit(
    function()
        while true do
            --等待网络环境准备就绪
            while not socket.isReady() do sys.waitUntil("IP_READY_IND") end
            
            --单向认证测试时，此变量设置为false；双向认证测试时，此变量设置为true
            local mutualAuth = false
            local socketClient

            --双向认证测试
            if mutualAuth then                   
                --创建一个socket ssl tcp客户端
                socketClient = socket.tcp(true,{caCert="ca1.crt",clientCert="client.crt",clientKey="client.key"})
                --阻塞执行socket connect动作，直至成功
                while not socketClient:connect("36.7.87.100","4434") do
                    sys.wait(2000)
                end                
            --单向认证测试
            else
                --创建一个socket ssl tcp客户端
                socketClient = socket.tcp(true,{caCert="ca.crt"})
                --阻塞执行socket connect动作，直至成功
                while not socketClient:connect("36.7.87.100","4433") do
                    sys.wait(2000)
                end
            end
            
            if socketClient:send("GET / HTTP/1.1\r\nHost: 36.7.87.100\r\nConnection: keep-alive\r\n\r\n") then
                result,data = socketClient:recv(5000)
                if result and data~="timeout" then
                    --TODO：处理收到的数据data
                    log.info("socketTask.recv",data)
                end
            end

            --断开socket连接
            socketClient:close()
            sys.wait(20000)
        end
    end
)

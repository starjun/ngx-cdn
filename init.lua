
local cjson_safe = require "cjson.safe"

--- balancer.json 文件绝对路径 [需要自行根据自己服务器情况设置]
local balancer_json = "/opt/openresty/dynamic_balancer/host.json"

--- 将全局配置参数存放到共享内存（*_dict）中
local balancer_dict = ngx.shared.balancer_dict

--- 读取文件（全部读取）
--- loadjson()调用
local function readfile(_filepath)
    local fd = io.open(_filepath,"r")
    if fd == nil then return end
    local str = fd:read("*a") --- 全部内容读取
    fd:close()
    return str
end

--- 载入JSON文件
--- loadConfig()调用
local function loadjson(_path_name)
	local x = readfile(_path_name)
	local json = cjson_safe.decode(x) or {}
	return json
end
		
--- 载入config.json全局基础配置
--- 唯一一个全局函数
function loadConfig()
	local tb_balancer_dict = loadjson(balancer_json)
	for i,v in pairs(tb_balancer_dict) do
		local tmp_json = cjson_safe.encode(v)
		balancer_dict:safe_set(i,tmp_json,0)
		--- key 存在会覆盖 lru算法关闭
	end
end

loadConfig()
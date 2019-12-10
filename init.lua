
local config = {}
local stool = require "stool"
local string_gsub = string.gsub
local ngx_shared = ngx.shared

require "resty.core"
collectgarbage("collect")

--- host.json certs.json 文件绝对路径 [需要自行根据自己服务器情况设置]
local base_json  = "/opt/openresty/dynamic_upstream/conf_json/base.json"
local _path = stool.pathJoin(ngx.config.prefix(),"../dynamic_upstream/")

--- 将全局配置参数存放到共享内存（*_dict）中
local config_dict = ngx_shared.config_dict
local ip_dict     = ngx_shared.ip_dict

--- 唯一一个全局函数
function loadConfig()
    config.base = stool.loadjson(base_json)
    if config.base.jsonPath == nil then
        stool.writefile(_path.."error.log",ngx.localtime().." init: base.json error\n")
    end
    local _basedir = config.base.jsonPath or stool.pathJoin(_path,"conf_json/")

    -- ip_Mod
    local allowIpList     = stool.readfile(_basedir .. "ip/allow.ip" , true)
    local denyIpList      = stool.readfile(_basedir .. "ip/deny.ip" , true)
    for _ , v in ipairs(allowIpList) do
        v = string_gsub(v , "\r\n" , "")
        v = string_gsub(v , "\r" , "")
        v = string_gsub(v , "\n" , "")
        ip_dict:safe_set(v , "allow" , 0)
    end
    for _ , v in ipairs(denyIpList) do
        v = string_gsub(v , "\r\n" , "")
        v = string_gsub(v , "\r" , "")
        v = string_gsub(v , "\n" , "")
        ip_dict:safe_set(v , "deny" , 0)
    end

    -- http2https_Mod
    config.http2https_Mod    = stool.loadjson(_basedir .. "http2https_Mod.json")

    -- dynamic_host_Mod
    config.dynamic_host_Mod  = stool.loadjson(_basedir .. "dynamic_host_Mod.json")

    -- dynamic_certs_Mod
    config.dynamic_certs_Mod = stool.loadjson(_basedir .. "dynamic_certs_Mod.json")

    -- proxy_cache_Mod
    config.proxy_cache_Mod   = stool.loadjson(_basedir .. "proxy_cache_Mod.json")

    -- add_headers_Mod
    config.add_headers_Mod   = stool.loadjson(_basedir .. "add_headers_Mod.json")

    -- limit_rate_Mod
    config.limit_rate_Mod    = stool.loadjson(_basedir .. "limit_rate_Mod.json")

    -- network_Mod
    config.network_Mod       = stool.loadjson(_basedir .. "network_Mod.json")

    config_dict:safe_set("config",stool.tableTojsonStr(config),0)
    config_dict:safe_set("config_version",0,0)

    config_dict:safe_set("fail_host" , "{}" , 0)
    config_dict:safe_set("fail_host_version" , 0 , 0)
end

loadConfig()
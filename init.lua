
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

    local tmp_host_Mod     = stool.loadjson(_basedir .. "host_json/host_Mod.json")
    local all_host_Mod     = {}
    for k , v in pairs(tmp_host_Mod) do
        v.state     = v.state or "on"
        v.add_headers_Mod  = v.add_headers_Mod or "on"
        v.http2https_Mod = v.http2https_Mod or "on"
        v.limit_rate_Mod  = v.limit_rate_Mod or "on"
        v.proxy_cache_Mod = v.proxy_cache_Mod or "on"
        v.app_Mod         = v.app_Mod or "on"
        v.network_Mod     = v.network_Mod or "on"
        v.rules     = stool.loadjson(_basedir .. "host_json/" .. k .. ".json")
        v.rules.add_headers_Mod = v.rules.add_headers_Mod or {}
        v.rules.limit_rate_Mod  = v.rules.limit_rate_Mod or {}
        v.rules.proxy_cache_Mod = v.rules.proxy_cache_Mod or {}
        v.rules.app_Mod         = v.rules.app_Mod or {}
        v.rules.network_Mod     = v.rules.network_Mod or {}
        all_host_Mod[k] = v
    end
    config_dict:safe_set("host_Mod" , stool.tableTojsonStr(all_host_Mod) , 0)
    config_dict:safe_set("host_Mod_version" , 0 , 0)

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
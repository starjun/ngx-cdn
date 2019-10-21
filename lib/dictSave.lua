--- dict save to json
local optl         = require("optl")
local stool        = require("stool")
local JSON         = require("resty.JSON")
local pairs        = pairs
local ipairs       = ipairs
local tostring     = tostring
local table_insert = table.insert
local string_find  = string.find
local table_concat = table.concat

local config_dict  = ngx.shared.config_dict
local ip_dict      = ngx.shared.ip_dict

-- 一定要保证 config 是合法的
-- config.base              ===> base.json
-- config.http2https_Mod    ==> http2https_Mod.json
-- config.dynamic_host_Mod  ==> dynamic_host_Mod.json
-- config.dynamic_certs_Mod ==> dynamic_certs_Mod.json
-- config.proxy_cache_Mod   ==> proxy_cache_Mod.json
-- config.limit_rate_Mod    ==> limit_rate_Mod.json
-- config.network_Mod       ==> network_Mod.json
local function config_dict_save(_config , _key)
    local config_base = _config.base
    local fileEnd     = ".json"
    if config_base.debug_Mod then
        -- 调试模式
        fileEnd = ".json.bak"
    end
    local re , err
    _key = _key or ""
    if _key == "" then
        for k , v in pairs(_config) do
            re , err = stool.writefile(config_base.jsonPath .. k .. fileEnd , JSON:encode_pretty(v) , "w+")
            if not re then
                break
            end
        end
    else
        if _config[_key] then
            re , err = stool.writefile(config_base.jsonPath .. _key .. fileEnd , JSON:encode_pretty(_config[_key]) , "w+")
        else
            err = tostring(_key) .. " not in config"
        end
    end
    return re , err
end

-- 一定要保证 参数 合法
-- allow ==> ip/allow.ip
-- deny  ==> ip/deny.ip
local function ip_dict_save(_config_base)
    local tb_keys = ip_dict:get_keys(0)
    local allowIp , denyIp = {} , {}
    for _ , v in ipairs(tb_keys) do
        local ip_value = ip_dict:get(v)
        --- init 中，永久ip只有这3个value
        --  新版openresty支持ttl
        if ip_value == "allow" then
            table_insert(allowIp , v)
        elseif ip_value == "deny" then
            table_insert(denyIp , v)
        end
    end
    local fileEnd = ".ip"
    if _config_base.debug_Mod then
        fileEnd = ".ip.bak"
    end
    -- 保存3个文件 暂时不检查每次的保存情况
    local re,err
    re , err = stool.writefile(_config_base.jsonPath .. "ip/allow" .. fileEnd , table_concat(allowIp , "\n") , "w+")
    re , err = stool.writefile(_config_base.jsonPath .. "ip/deny" .. fileEnd , table_concat(denyIp , "\n") , "w+")
    return re
end

-- 一定要保证 参数 合法
-- config_dict *_dict
local function all_dict_save(config)
    local config_base = config.base
    -- config_dict
    local re , err    = config_dict_save(config)
    if not re then
        return false , err
    end

    -- ip_dict
    re , err = ip_dict_save(config_base)
    if not re then
        return false , err
    end

    -- *_dict

    return true
end

local _M            = {}

_M.config_dict_save = config_dict_save

_M.ip_dict_save     = ip_dict_save

_M.all_dict_save    = all_dict_save

return _M
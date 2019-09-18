
local stool       = require("stool")

local ngx_shared  = ngx.shared
local config_dict = ngx_shared.config_dict

local keys        = {}
keys["config"]    = {
    cache    = stool.stringTojson(config_dict:get("config")) or {},
    dict_tag = "config_version",
    _version = 0
}
keys["fail_host"]    = {
    cache    = stool.stringTojson(config_dict:get("fail_host")) or {},
    dict_tag = "fail_host_version",
    _version = 0
}

local _M          = { _VERSION = "0.01" }
_M.keys           = keys

-- 获取字典中的key (decode后 error 返回 nil)
local function get_key(_key)
    -- _key没有判断
    return stool.stringTojson(config_dict:get(_key))
end

-- up dict_version
local function dict_tag_up(_key)
    local cache_key = keys[_key]
    if cache_key then
        local tag = cache_key["dict_tag"]
        config_dict:incr(tag,1)
    end
end
_M.dict_tag_up = dict_tag_up


local function up_cache_dict(_key)
    local cache_key = keys[_key]
    if cache_key then
        local dict_version = config_dict:get(cache_key["dict_tag"])
        if cache_key["_version"] ~= dict_version then
            local _new_key = get_key(_key)
            if _new_key and not stool.table_compare(cache_key["cache"], _new_key) then
                cache_key.cache = _new_key
            end
            cache_key["_version"] = dict_version
        end
    end
end

local function upcheck()
    for k,v in pairs(keys) do
        up_cache_dict(k)
    end
end
_M.upcheck = upcheck

return _M
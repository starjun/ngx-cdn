-----  rewrite_all by zj  -----
local ngx_var  = ngx.var
if ngx_var.remote_addr == "127.0.0.1" then
    return
end
local ngx_ctx  = ngx.ctx
local modcache = require("modcache")
local optl   = require("optl")
local string_upper = string.upper
local unescape_uri = ngx.unescape_uri
local ngx_redirect = ngx.redirect

local config = modcache.keys["config"].cache


local host = unescape_uri(ngx_var.http_host)
local scheme = ngx_var.scheme
local request_uri = unescape_uri(ngx_var.request_uri)
local uri = ngx_var.uri

local function remath_ext(_str , _modRule)
    if type(_modRule) ~= "table" then
        return false
    end
    if _modRule[2] == "rein_list" or _modRule[2] == "restart_list" or _modRule[2] == "reend_list" then
        return optl.remath_Invert(string_upper(_str) , _modRule[1] , _modRule[2] , _modRule[3])
    else
        return optl.remath_Invert(_str , _modRule[1] , _modRule[2] , _modRule[3])
    end
end

--- 匹配 host 和 uri
local function host_uri_remath(_host , _uri)
    if remath_ext(host , _host) and remath_ext(uri , _uri) then
        return true
    end
end

--- 取config_dict中的json数据
local function getDict_Config(_Config_jsonName)
    local re = config[_Config_jsonName] or {}
    return re
end

-- http2https_Mod 执行
if scheme == "http" then
    for i,v in ipairs(getDict_Config("http2https_Mod")) do
        if v.state == "on" and remath_ext(host,v.hostname) then
            return ngx_redirect("https://"..host..request_uri,301)
        end
    end
end

-- proxy_cache_Mod 执行
for i,v in ipairs(getDict_Config("proxy_cache_Mod")) do
    if v.state == "on" and host_uri_remath(v.hostname , v.uri) then
        ngx_var.p_cache = 0
    end
end
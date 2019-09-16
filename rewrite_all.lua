-----  rewrite_all by zj  -----
local ngx_var  = ngx.var
local ngx_ctx  = ngx.ctx
local modcache = require("modcache")
local optl   = require("optl")
local string_upper = string.upper
local unescape_uri = ngx.unescape_uri
local ngx_redirect = ngx.redirect

local config = modcache.keys["config"].cache
local http2https_Mod = config.http2https_Mod or {}

local host = unescape_uri(ngx_var.http_host)
local scheme = ngx_var.scheme
local request_uri = unescape_uri(ngx_var.request_uri)

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

for i,v in ipairs(http2https_Mod) do
    if v.state == "on" and scheme == "http" and remath_ext(host,v.hostname) then
        return ngx_redirect(request_uri,301)
    end
end
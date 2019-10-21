-- 仅在调用api时进行鉴权

local ngx_var  = ngx.var
local ngx_ctx  = ngx.ctx
local stool    = require "stool"
local modcache = require("modcache")
local jwt      = require "resty.jwt"
local ngx_say  = ngx.say
local ngx_exit = ngx.exit

local config = modcache.keys["config"].cache
local base   = config.base
if not base then
    ngx_say([=[{"code":"error","msg":"config.base is error"}]=])
    ngx_exit(200)
end
local jwt_Mod = base.jwt_Mod

local uri_white_list = {
}

if stool.isInArrayTb(ngx_var.uri,uri_white_list) then
    return
end

local function header_jwt_check()
    if jwt_Mod.state == "off" then
        return true
    end
    local client_token = ngx_var[(jwt_Mod.header_name or "zj_jwt_token")]
    if not client_token then
        return false
    end
    local jwt_obj = jwt:load_jwt(client_token)
    if type(jwt_obj.payload) ~= "table" then
        return false
    end
    local aud = jwt_obj.payload.aud
    local app_id = jwt_Mod.appList[aud]
    if not app_id then
        return false
    end
    --- 签名检查
    local jwt_verify = jwt:verify(jwt_Mod.hmac, client_token)
    if not jwt_verify.verified then
        return false
    end
    -- 后续添加 角色 权限等判断
    return true
end

if header_jwt_check() then
    -- ngx_ctx.api_pass = "yes"
    return
else
    ngx_say([=[{"code":"error","msg":"sign error"}]=])
    ngx_exit(200)
end
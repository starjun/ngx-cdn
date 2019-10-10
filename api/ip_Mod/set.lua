-- ip 黑白名单 添加/修改
local stool = require "stool"
local optl  = require "optl"

local ip_dict = ngx.shared["ip_dict"]

local _ip = optl.get_paramByName("ip")
local _value = optl.get_paramByName("value")
local _time = optl.get_paramByName("time")
if _value == "" then
    _value = "deny"
end
_time = tonumber(_time) or 0


if string.find(_ip , '_') then
    local tmp_tb = stool.split(_ip , '_')
    if not stool.isHost(tmp_tb[1]) then
        optl.sayHtml_ext({ code = "error", msg = "host is error" })
    end
    if not stool.isIp(tmp_tb[2]) then
        optl.sayHtml_ext({ code = "error", msg = "ip is error" })
    end
else
    if not stool.isIp(_ip) then
        optl.sayHtml_ext({ code = "error", msg = "ip is error" })
    end
end

local re = ip_dict:safe_set(_ip , _value , _time)
-- 非重复插入(lru不启用)
if not re then
    optl.sayHtml_ext({ code = "error", msg = "ip safe_set error" })
else
    optl.sayHtml_ext({ code = "ok", msg = "ip safe_set success" })
end
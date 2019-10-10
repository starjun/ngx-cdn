-- ip 黑白名单 删除

-- ip = "all_ip" 删除所有 ip 规则内容
-- ip = %ip% 删除 指定 ip 规则

local stool = require "stool"
local optl  = require "optl"

local ip_dict = ngx.shared["ip_dict"]

local _ip = optl.get_paramByName("ip")

if _ip == "" then
    optl.sayHtml_ext({ code = "error", msg = "ip is nil" })
elseif _ip == "all_ip" then
    ip_dict:flush_all()
else
    ip_dict:delete(_ip)
end
optl.sayHtml_ext({ code = "ok", msg = _ip .. " del success" })
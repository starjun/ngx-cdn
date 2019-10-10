-- ip 黑白名单 查询

-- host = "" 查询指定 ip 的 信息
--  ip = count_ip 查询 所有ip_Mod 规则数量
--  ip = all_ip 查询 所有规则


-- host = %host% 查询指定 域名对应的 ip 规则

local stool = require "stool"
local optl  = require "optl"

local _host   = optl.get_paramByName("host")
local _ip     = optl.get_paramByName("ip")

if _host ~= "" then
    if not stool.isHost(_host) then
        optl.sayHtml_ext({ code = "error", msg = "host is error" })
    end
    local _tb , tb_all = ip_dict:get_keys(0) , {}
    for _ , v in ipairs(_tb) do
        if stool.stringStarts(v , _host .. "_") then
            tb_all[v] = ip_dict:get(v)
        end
    end
    tb_all.count = stool.getTableCount(tb_all)
    optl.sayHtml_ext({ code = "ok", msg = tb_all })
else
    if _ip == "count_ip" then
        local _tb = ip_dict:get_keys(0)
        optl.sayHtml_ext({ code = "ok", msg = #_tb })
    elseif _ip == "all_ip" then
        local _tb , tb_all = ip_dict:get_keys(0) , {}
        for _ , v in ipairs(_tb) do
            tb_all[v] = ip_dict:get(v)
        end
        tb_all.count = #_tb
        optl.sayHtml_ext({ code = "ok", msg = tb_all })
    else
        local _value = ip_dict:get(_ip)
        if _value then
            optl.sayHtml_ext({ code = "ok", msg = _value, ip = _ip })
        else
            optl.sayHtml_ext({ code = "error", msg = "ip is Non-existent" })
        end
    end
end
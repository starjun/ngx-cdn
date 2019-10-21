----  配置json相关操作
--    包括 base.json conf_json/* 所有json
--    配置json的重新载入
--    内存配置保存到对应json文件，只有保存和reload两个功能

local optl     = require("optl")
local stool    = require("stool")
local dictSave = require("dictSave")

local get_paramByName = optl.get_paramByName
local sayHtml_ext = optl.sayHtml_ext

local _action     = get_paramByName("action")
local _mod        = get_paramByName("mod")
-- all_Mod
-- ip_Mod
-- {
--     "base",
--     "http2https_Mod",
--     "dynamic_host_Mod",
--     "dynamic_certs_Mod",
--     "proxy_cache_Mod",
--     "limit_rate_Mod",
--     "network_Mod"
-- }

local config_dict = ngx.shared.config_dict

local config      = stool.stringTojson(config_dict:get("config"))
if type(config) ~= "table" then
    sayHtml_ext({ code = "error", msg = "config_dict.config is error" })
end
local config_base = config.base

if _action == "save" then

    if _mod == "all_Mod" then
        local re , err = dictSave.all_dict_save(config)
        if not re then
            sayHtml_ext({ code = "error", msg = err })
        end
        sayHtml_ext({ code = "ok", msg = "all_Mod save success" })

    elseif _mod == "ip_Mod" then
        local re , err = dictSave.ip_dict_save(config_base)
        if re then
            sayHtml_ext({ code = "ok", msg = "ip_dict save ok" })
        else
            sayHtml_ext({ code = "error", msg = err })
        end

    else
        local re , err = dictSave.config_dict_save(config , _mod)
        if re then
            sayHtml_ext({ code = "ok", msg = "config_dict." .. _mod .. " save success" })
        else
            sayHtml_ext({ code = "error", msg = err })
        end

    end

elseif _action == "reload" then

    loadConfig()
    sayHtml_ext({ code = "ok", msg = "reload ok" })

else
    sayHtml_ext({ code = "error", msg = "action is Non-existent" })
end
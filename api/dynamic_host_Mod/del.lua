-- 动态域名 删除
-- 仅允许删除指定 host 的完整配置

local stool = require "stool"
local optl  = require "optl"
local modcache = require("modcache")

local config_dict = ngx.shared["config_dict"]
local dict_key_name = "config"
local tb_key_name = "dynamic_host_Mod"
local config = stool.stringTojson(config_dict:get(dict_key_name))
if not config then
    optl.sayHtml_ext({ code = "error", msg = "config_dict:config is error" })
end

local _host = optl.get_paramByName("host")

if config[tb_key_name][_host] then
    config[tb_key_name][_host] = nil
    local re = config_dict:replace(dict_key_name , stool.tableTojsonStr(config))
    if not re then
        optl.sayHtml_ext({ code = "error", msg = "error in set while replacing" })
    end
    -- 更新 dict version 标记
    modcache.dict_tag_up(dict_key_name)
    optl.sayHtml_ext({ code = "ok", msg = "del host success" })

else
    -- 对应 host 域名 不存在
    optl.sayHtml_ext({code="error",msg="host is Non-existent"})
end
-- 动态证书 删除
-- 仅允许单个 certs_key 删除
local stool = require "stool"
local optl  = require "optl"
local modcache = require("modcache")

local config_dict = ngx.shared["config_dict"]
local dict_key_name = "config"
local tb_key_name = "dynamic_certs_Mod"
local config = stool.stringTojson(config_dict:get(dict_key_name))
if not config then
    optl.sayHtml_ext({ code = "error", msg = "config_dict:config is error" })
end

local _certs_key = optl.get_paramByName("certs_key")

if config[tb_key_name][_certs_key] then
    config[tb_key_name][_certs_key] = nil
    local re = config_dict:replace(dict_key_name , stool.tableTojsonStr(config))
    if not re then
        optl.sayHtml_ext({ code = "error", msg = "error in set while replacing" })
    end
    -- 更新 dict version 标记
    modcache.dict_tag_up(dict_key_name)
    optl.sayHtml_ext({ code = "ok", msg = "del certs success" })
else
    -- 对应 certs_key 证书不存在
    optl.sayHtml_ext({code="error",msg="certs_key is Non-existent"})
end
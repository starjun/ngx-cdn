-- 动态证书 修改
-- 仅支持对指定 certs_key 的 完整 value 修改
local stool = require "stool"
local optl  = require "optl"
local modcache = require("modcache")

local config_dict = ngx.shared["config_dict"]
local dict_key_name = "config"
local tb_key_name = "dynamic_certs_Mod"
local config = stool.stringTojson(config_dict:get(dict_key_name))
if not config then
    optl.sayHtml_ext({ code = "error", msg = "config_dict:config is error" })
endl

local _certs_key = optl.get_paramByName("certs_key")
local _value = optl.get_paramByName("value")
-- {
--     "ssl_certificate":"base64 str",
--     "ssl_certificate_key":"base64 str"
-- }

if config[tb_key_name][_certs_key] then
    _value = stool.stringTojson(_value)
    if type(_value) ~= "table" then
        -- value 转 json 失败
        optl.sayHtml_ext({code="error",msg="value Tojson error"})
    else
        local old_value = config[mod_name][_certs_key]
        _value.e_time = nil
        old_value.e_time = nil
        if stool.table_compare(old_value,_value) then
            optl.sayHtml_ext({code="ok",msg="no change"})
        end
        -- todo 检查证书等信息
        local re,err = certs_Mod.ssl_save(_value,_certs_key,"Master")
        if not re then
            optl.sayHtml_ext({ code = "error", msg = err })
        end
        _value.e_time = err
        --
        config[tb_key_name][_certs_key] = _value
        local re = config_dict:replace(dict_key_name , stool.tableTojsonStr(config))
        if not re then
            optl.sayHtml_ext({ code = "error", msg = "error in set while replacing" })
        end
        -- 更新 dict version 标记
        modcache.dict_tag_up(dict_key_name)
        optl.sayHtml_ext({ code = "ok", msg = "set certs success" })
    end
else
    -- 对应 certs_key 证书不存在
    optl.sayHtml_ext({code="error",msg="certs_key is Non-existent"})
end
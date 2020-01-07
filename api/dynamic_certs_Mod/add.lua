-- 动态证书 添加
-- 通过 certs_key value 添加新的证书
local stool = require "stool"
local optl  = require "optl"
local modcache = require("modcache")
local certs_Mod = require("certs_Mod")

local config_dict = ngx.shared["config_dict"]
local dict_key_name = "config"
local tb_key_name = "dynamic_certs_Mod"
local config = stool.stringTojson(config_dict:get(dict_key_name))
if not config then
    optl.sayHtml_ext({ code = "error", msg = "config_dict:config is error" })
end

local _certs_key = optl.get_paramByName("certs_key")
local _value = optl.get_paramByName("value")
-- {
--     "e_time":"2020-09-09 19:30:00",
--     "ssl_certificate":"base64 str",
--     "ssl_certificate_key":"base64 str"
-- }

if config[tb_key_name][_certs_key] then
    -- 对应 certs_key 证书已经存在
    optl.sayHtml_ext({code="error",msg="certs_key is existence"})
else
    _value = stool.stringTojson(_value)
    if type(_value) ~= "table" then
        -- value 转 json 失败
        optl.sayHtml_ext({code="error",msg="value Tojson error"})
    else
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
        optl.sayHtml_ext({ code = "ok", msg = "add certs success" })
    end
end
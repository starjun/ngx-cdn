-- 动态证书 修改
local stool = require "stool"
local optl  = require "optl"
local modcache = require("modcache")

local config_dict = ngx.shared["config_dict"]
local dict_key_name = "config"
local tb_key_name = "dynamic_certs_Mod"
local config = stool.stringTojson(config_dict:get(dict_key_name)) or {}
local _tb = config[tb_key_name]

local _host = optl.get_paramByName("host")
local _value = optl.get_paramByName("value")
-- {
--     "e_time":"2020-09-09 19:30:00",
--     "ssl_certificate":"base64 str",
--     "ssl_certificate_key":"base64 str"
-- }

if _tb[_host] then
    local tb = stool.stringTojson(_value)
    if type(tb) ~= "table" then
        -- value 转 json 失败
        optl.sayHtml_ext({code="error",msg="value is error"})
    else
        -- todo 检查证书等信息
        _tb[_host] = tb
        local re = config_dict:replace(dict_key_name , stool.tableTojsonStr(_tb))
        if not re then
            optl.sayHtml_ext({ code = "error", msg = "error in set while replacing" })
        end
        -- 更新 dict version 标记
        modcache.dict_tag_up(dict_key_name)
        optl.sayHtml_ext({ code = "ok", msg = "set "..dict_key_name.." success" })
    end
else
    -- 对应 host key 证书不存在
    optl.sayHtml_ext({code="error",msg="host is error"})
end
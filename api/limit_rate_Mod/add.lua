-- 动态域名 添加
local stool = require "stool"
local optl  = require "optl"
local modcache = require("modcache")

local config_dict = ngx.shared["config_dict"]
local dict_key_name = "config"
local tb_key_name = "limit_rate_Mod"
local config = stool.stringTojson(config_dict:get(dict_key_name))
if not config then
    optl.sayHtml_ext({ code = "error", msg = "config_dict:config is error" })
end

local _value = optl.get_paramByName("value")
-- {
--     "state": "on",
--     "limit_rate":"100k",
--     "id":"www.test.com limit_rate 100k",
--     "hostname": ["www.test.com",""],
--     "uri":[["down","static"],"rein_list"]
-- }

_value = stool.stringTojson(_value)
if type(_value) ~= "table" then
    -- value 转 json 失败
    optl.sayHtml_ext({code="error",msg="value Tojson error"})
else
    table.insert(config[tb_key_name], _value)
    local re = config_dict:replace(dict_key_name , stool.tableTojsonStr(config))
    if not re then
        optl.sayHtml_ext({ code = "error", msg = "error in set while replacing" })
    end
    -- 更新 dict version 标记
    modcache.dict_tag_up(dict_key_name)
    optl.sayHtml_ext({ code = "ok", msg = "add rules success" })
end
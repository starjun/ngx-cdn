-- 动态域名 添加
local stool = require "stool"
local optl  = require "optl"
local modcache = require("modcache")

local config_dict = ngx.shared["config_dict"]
local dict_key_name = "config"
local tb_key_name = "network_Mod"
local config = stool.stringTojson(config_dict:get(dict_key_name)) or {}
local _tb = config[tb_key_name]

local _value = optl.get_paramByName("value")
-- {
--     "state": "on",
--     "id":"2-ip_cc",
--     "network":{"maxReqs":5000,"pTime":10,"blackTime":120},
--     "hostname": ["*",""],
--     "uri": ["*",""]
-- }

local tb = stool.stringTojson(_value)
if type(tb) ~= "table" then
    -- value 转 json 失败
    optl.sayHtml_ext({code="error",msg="value Tojson error"})
else
    table.insert(_tb, tb)
    local re = config_dict:replace(dict_key_name , stool.tableTojsonStr(_tb))
    if not re then
        optl.sayHtml_ext({ code = "error", msg = "error in set while replacing" })
    end
    -- 更新 dict version 标记
    modcache.dict_tag_up(dict_key_name)
    optl.sayHtml_ext({ code = "ok", msg = "add rules success" })
end
-- 动态域名 删除
local stool = require "stool"
local optl  = require "optl"
local modcache = require("modcache")

local config_dict = ngx.shared["config_dict"]
local dict_key_name = "dynamic_host"
local _tb = stool.stringTojson(config_dict:get(dict_key_name)) or {}

local _host = optl.get_paramByName("host")

if _tb[_host] then
    _tb[_host] = nil
    re = config_dict:replace(dict_key_name , stool.tableTojsonStr(_tb))
    if not re then
        optl.sayHtml_ext({ code = "error", msg = "error in set while replacing" })
    end
    -- 更新 dict version 标记
    modcache.dict_tag_up(dict_key_name)
    optl.sayHtml_ext({ code = "ok", msg = "add "..dict_key_name.." success" })

else
    -- 对应 host key 证书 不存在
    optl.sayHtml_ext({code="error",msg="host is error"})
end
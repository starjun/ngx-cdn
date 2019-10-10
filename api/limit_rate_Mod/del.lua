-- 动态域名 删除
-- 仅允许删除指定 id 对应的规则

local stool = require "stool"
local optl  = require "optl"
local modcache = require("modcache")

local config_dict = ngx.shared["config_dict"]
local dict_key_name = "config"
local tb_key_name = "limit_rate_Mod"
local config = stool.stringTojson(config_dict:get(dict_key_name)) or {}
local _tb = config[tb_key_name]

local _id = optl.get_paramByName("id")
_id = tonumber(_id)
if not _id then
    optl.sayHtml_ext({ code = "ok", msg = "id is error" })
end

if not _tb[_id] then
    optl.sayHtml_ext({ code = "ok", msg = "id is Non-existent" })
else
    table.remove(_tb , _id)
    local re = config_dict:replace("config" , stool.tableTojsonStr(_tb))
    if not re then
        optl.sayHtml_ext({ code = "error", msg = "error in set while replacing" })
    end
    -- 更新 dict version 标记
    modcache.dict_tag_up(dict_key_name)
    optl.sayHtml_ext({ code = "ok", msg = "del rules success" })
end
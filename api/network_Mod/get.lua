-- 动态域名 查询

-- id = "" 查询所有 规则
-- id = %num% 查询指定 id 规则信息

local stool = require "stool"
local optl  = require "optl"

local config_dict = ngx.shared["config_dict"]
local dict_key_name = "config"
local tb_key_name = "network_Mod"
local config = stool.stringTojson(config_dict:get(dict_key_name)) or {}
local _tb = config[tb_key_name]

local _id = optl.get_paramByName("id")
if _id == "" then
    optl.sayHtml_ext({code="ok",msg=_tb})
else
    _id = tonumber(_id)
    if not _id then
        optl.sayHtml_ext({code="error",msg="id is error"})
    end
    optl.sayHtml_ext({code="ok",msg=_tb[_id]})
end
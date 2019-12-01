-- 动态域名 查询

-- id = "" 查询所有规则
-- id = %num% 查询指定 id 对应的规则信息

local stool = require "stool"
local optl  = require "optl"

local config_dict = ngx.shared["config_dict"]
local dict_key_name = "config"
local tb_key_name = "limit_rate_Mod"
local config = stool.stringTojson(config_dict:get(dict_key_name))
if not config then
    optl.sayHtml_ext({ code = "error", msg = "config_dict:config is error" })
end

local _id = optl.get_paramByName("id")
if _id == "" then
    optl.sayHtml_ext({code="ok",msg=config[tb_key_name]})
else
    _id = tonumber(_id)
    if not _id then
        optl.sayHtml_ext({code="error",msg="id is error")
    end
    optl.sayHtml_ext({code="ok",msg=config[tb_key_name][_id]})
end
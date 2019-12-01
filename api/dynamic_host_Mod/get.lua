-- 动态域名 查询

-- host = "" 查询所有域名名称
-- host = all_hsot 查询所有动态域名信息
-- host = %name% 查询指定域名信息

local stool = require "stool"
local optl  = require "optl"

local config_dict = ngx.shared["config_dict"]
local dict_key_name = "config"
local tb_key_name = "dynamic_host_Mod"
local config = stool.stringTojson(config_dict:get(dict_key_name))
if not config then
    optl.sayHtml_ext({ code = "error", msg = "config_dict:config is error" })
end

local _host = optl.get_paramByName("host")
if _host == "" then
    local tmp = {}
    for k,_ in pairs(config[tb_key_name]) do
        table.insert(tmp,k)
    end
    optl.sayHtml_ext({code="ok",msg=tmp,count=#(tmp)})
elseif _host == "all_host" then
    optl.sayHtml_ext({code="ok",msg=config[tb_key_name]})
else
    optl.sayHtml_ext({code="ok",msg=config[tb_key_name][_host]})
end
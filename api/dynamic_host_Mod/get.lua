-- 动态域名 查询
local stool = require "stool"
local optl  = require "optl"

local config_dict = ngx.shared["config_dict"]
local dict_key_name = "config"
local tb_key_name = "dynamic_host_Mod"
local config = stool.stringTojson(config_dict:get(dict_key_name)) or {}
local _tb = config[tb_key_name]

local _host = optl.get_paramByName("host")
if _host == "" then
    local _tb_host_name = {}
    for k,v in pairs(_tb) do
        table.insert(_tb_host_name,k)
    end
    optl.sayHtml_ext({code="ok",msg=_tb_host_name,count=#(_tb_host_name)})
elseif _host == "all_host" then
    optl.sayHtml_ext({code="ok",msg=_tb})
else
    optl.sayHtml_ext({code="ok",msg=_tb[_host]})
end
-- 动态证书查询

-- certs_key = ""  查询所有 certs_key 名称
-- certs_key = all_certs_key  查询所有数据，不包括私钥
-- certs_key = %key_name%  查询指定 certs_key 数据， 包括私钥

local stool = require "stool"
local optl  = require "optl"

local config_dict = ngx.shared["config_dict"]
local dict_key_name = "config"
local tb_key_name = "dynamic_certs_Mod"
local config = stool.stringTojson(config_dict:get(dict_key_name)) or {}
local _tb = config[tb_key_name]

local _certs_key = optl.get_paramByName("certs_key")
if _certs_key == "" then
    local _tb_certs_key_name = {}
    for k,v in pairs(_tb) do
        table.insert(_tb_certs_key_name,k)
    end
    optl.sayHtml_ext({code="ok",msg=_tb_certs_key_name,count=#(_tb_certs_key_name)})
elseif _certs_key == "all_certs_key" then
    local tmp = {}
    for k,v in pairs(_tb) do
        v.ssl_certificate_key = nil
        tmp[k] = v
    end
    optl.sayHtml_ext({code="ok",msg=tmp})
else
    optl.sayHtml_ext({code="ok",msg=_tb[_certs_key]})
end
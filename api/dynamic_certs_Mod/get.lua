-- 动态证书查询

-- certs_key = ""  查询所有 certs_key 名称
-- certs_key = all_certs_key  查询所有数据，不包括私钥
-- certs_key = %key_name%  查询指定 certs_key 数据， 包括私钥

local stool = require "stool"
local optl  = require "optl"

local config_dict = ngx.shared["config_dict"]
local dict_key_name = "config"
local tb_key_name = "dynamic_certs_Mod"
local config = stool.stringTojson(config_dict:get(dict_key_name))
if not config then
    optl.sayHtml_ext({ code = "error", msg = "config_dict:config is error" })
end

local _certs_key = optl.get_paramByName("certs_key")

local tb = config[tb_key_name]
if type(tb) ~= "table" then
    optl.sayHtml_ext({code="error",msg="config_dict:dynamic_certs_Mod is nil"})
end
if _certs_key == "" then
    local tmp = {}
    for k,_ in pairs(config[tb_key_name]) do
        table.insert(tmp,k)
    end
    optl.sayHtml_ext({code="ok",msg=tmp,count=#tmp})
elseif _certs_key == "all_certs_key" then
    local tmp = {}
    for k,v in pairs(config[tb_key_name]) do
        v.ssl_certificate_key = nil
        tmp[k] = v
    end
    optl.sayHtml_ext({code="ok",msg=tmp})
else
    optl.sayHtml_ext({code="ok",msg=config[tb_key_name][_certs_key]})
end
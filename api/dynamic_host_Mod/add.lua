-- 动态域名 添加
local stool = require "stool"
local optl  = require "optl"
local modcache = require("modcache")

local config_dict = ngx.shared["config_dict"]
local dict_key_name = "dynamic_host"
local _tb = stool.stringTojson(config_dict:get(dict_key_name)) or {}

local _host = optl.get_paramByName("host")
local _value = optl.get_paramByName("value")
-- {
--     "bal_list": [["127.0.0.1",81],["127.0.0.1",82]],
--     "mode": "url_hash",
--     "certs":"blah.com"
-- }
local mode_list = {"ip_hash","url_hash","random","polling","weight.polling"}

local function check_value(_tb)
    if type(_tb) ~= "table" then
        return false,"_tb is not table"
    end
    if not stool.isInArrayTb(_tb.mode,mode_list) then
        return false,"mode is error"
    end
    if not stool.isArrayTable(_tb.bal_list) then
        return false,"bal_list is not ArrayTable"
    end
    for i,v in ipairs(_tb.bal_list) do
        if not stool.isArrayTable(v) then
            return false,"bal_list["..i.."] is not ArrayTable"
        end
        if _tb.mode == "weight.polling"then
            if #v == 1 then
                return false,"weight.polling need [ip,port[,weight]]"
            end
        end
    end
    return true
end

if _tb[_host] then
    -- 对应 host key 证书已经存在
    optl.sayHtml_ext({code="error",msg="host is error"})
else
    local tb = stool.stringTojson(_value)
    if type(tb) ~= "table" then
        -- value 转 json 失败
        optl.sayHtml_ext({code="error",msg="value is error"})
    else
        local re,err = check_value(tb)
        if not re then
            optl.sayHtml_ext({ code = "error", msg = "error is: "..err })
        end
        _tb[_host] = tb
        re = config_dict:replace(dict_key_name , stool.tableTojsonStr(_tb))
        if not re then
            optl.sayHtml_ext({ code = "error", msg = "error in set while replacing" })
        end
        -- 更新 dict version 标记
        modcache.dict_tag_up(dict_key_name)
        optl.sayHtml_ext({ code = "ok", msg = "add "..dict_key_name.." success" })
    end
end
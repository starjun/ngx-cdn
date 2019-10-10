-- 动态域名 修改

-- id = "" 修改完整规则组信息
-- id = %num% 修改指定 id 对应的完整规则

local stool = require "stool"
local optl  = require "optl"
local modcache = require("modcache")

local config_dict = ngx.shared["config_dict"]
local dict_key_name = "config"
local tb_key_name = "limit_rate_Mod"
local config = stool.stringTojson(config_dict:get(dict_key_name)) or {}
local _tb = config[tb_key_name]

local _id = optl.get_paramByName("id")
local _value = optl.get_paramByName("value")
-- {
--     "state": "on",
--     "limit_rate":"100k",
--     "id":"www.test.com limit_rate 100k",
--     "hostname": ["www.test.com",""],
--     "uri":[["down","static"],"rein_list"]
-- }


local tb = stool.stringTojson(_value)
if type(tb) ~= "table" then
    -- value 转 json 失败
    optl.sayHtml_ext({code="error",msg="value Tojson error"})
else
    if _id == "" then
        -- 替换整个规则
        if stool.isArrayTable(tb) then
            _tb = tb
            local re = config_dict:replace(dict_key_name , stool.tableTojsonStr(_tb))
            if not re then
                optl.sayHtml_ext({ code = "error", msg = "error in set while replacing" })
            end
            -- 更新 dict version 标记
            modcache.dict_tag_up(dict_key_name)
            optl.sayHtml_ext({ code = "ok", msg = "set rules success" })
        end
    else
        if not _tb[_id] then
            optl.sayHtml_ext({ code = "ok", msg = "id is Non-existent" })
        else
            _tb[_id] = tb
            local re = config_dict:replace(dict_key_name , stool.tableTojsonStr(_tb))
            if not re then
                optl.sayHtml_ext({ code = "error", msg = "error in set while replacing" })
            end
            -- 更新 dict version 标记
            modcache.dict_tag_up(dict_key_name)
            optl.sayHtml_ext({ code = "ok", msg = "set rules success" })
        end
    end
end
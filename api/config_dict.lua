---- config_dict 操作
--   修改/查询：base
--   查询：http2https_Mod  dynamic_host_Mod  dynamic_certs_Mod  proxy_cache_Mod  limit_rate_Mod  network_Mod

local optl     = require("optl")
local modcache = require("modcache")
local stool    = require("stool")

local get_paramByName = optl.get_paramByName

local _action = get_paramByName("action")
local _mod    = get_paramByName("mod")
local _id     = get_paramByName("id")
local _value  = get_paramByName("value")


local config_dict = ngx.shared.config_dict
local config      = stool.stringTojson(config_dict:get("config"))
if type(config) ~= "table" then
    optl.sayHtml_ext({ code = "error", msg = "config_dict:config error" })
end
local config_base = config.base

if _action == "get" then

    if _mod == "all_Mod" then
        local tb_all = {}
        optl.sayHtml_ext({ code = "ok", msg = config })
    elseif _mod == "" then
        local _tb = {}
        for k , _ in pairs(config) do
            table.insert(_tb,k)
        end
        optl.sayHtml_ext({ code = "ok", msg = _tb })
    else
        local tmp_mod = config[_mod]
        if not tmp_mod then
            optl.sayHtml_ext({ code = "error", msg = _mod .. " not in config" })
        end

        if _id == "" then
            optl.sayHtml_ext({ code = "ok", msg = tmp_mod })
        else
            local re = stool.get_keyInTable(tmp_mod , _id)
            optl.sayHtml_ext({ code = "ok", msg = re })
        end
    end

elseif _action == "set" then
    if _mod ~= "base" then
        optl.sayHtml_ext({code='error', msg="mod is not base"})
    end

    if _id == "" then

        -- table 对比
        local newtb = stool.stringTojson(_value)
        if stool.table_compare(newtb , config[_mod]) then
            optl.sayHtml_ext({ code = "ok", msg = "no change" })
        end
        --
        config[_mod] = newtb
        local re     = config_dict:replace("config" , stool.tableTojsonStr(config))--将对应mod整体进行替换
        if not re then
            optl.sayHtml_ext({ code = "error", msg = "error in set while replacing" })
        end
        -- 更新 dict version 标记
        modcache.dict_tag_up("config")
        optl.sayHtml_ext({ code = "ok", msg = "set " .. _mod .. " success" })
    else
        -- 修改 base 中的 key 的值
        local tb_key = { "jwt_Mod" }
        if _id == "debug_Mod" then
            _value = stool.strToBoolean(_value)
        elseif stool.isInArrayTb(_id , tb_key) then
            _value = stool.stringTojson(_value)
            if type(_value) ~= "table" then
                optl.sayHtml_ext({ code = "error", msg = "value to json error" })
            end
            -- table 对比
            if stool.table_compare(_value , config[_mod][_id]) then
                optl.sayHtml_ext({ code = "ok", msg = "no change" })
            end
            --
        else
            -- _value no thing todo
        end

        config[_mod][_id] = _value
        local re          = config_dict:replace("config" , stool.tableTojsonStr(config))
        if not re then
            optl.sayHtml_ext({ code = "error", msg = "error in set while replacing" })
        end
        -- 更新 dict version 标记
        modcache.dict_tag_up("config")
        --optl.sayHtml_ext({code="ok",old_value=_old_value,new_value=_value})
        optl.sayHtml_ext({ code = "ok", msg = "set " .. _mod .. ":" .. _id .. " success" })
    end

else
    optl.sayHtml_ext({ code = "error", msg = "action error" })

end
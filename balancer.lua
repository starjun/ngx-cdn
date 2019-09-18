
local random = require "resty.resty-random"
local balancer = require "ngx.balancer"
local modcache = require "modcache"
local stool = require("stool")

local table_remove = table.remove
local table_insert = table.insert
local ngx_var = ngx.var

local balancer_dict = ngx.shared.balancer_dict

local unescape_uri = ngx.unescape_uri
local host = unescape_uri(ngx_var.http_host)

local config = modcache.keys.config.cache

local tb_host = config.dynamic_host_Mod[host]

if not tb_host then
    ngx.log(ngx.ERR, "http_host is nil")
    return ngx.exit(403)
end

local function load_balancer(_tb_host)
    -- 源站异常排除
    local fail_host = modcache.keys.fail_host.cache
    local array = _tb_host.bal_list
    for i=#array,1,-1 do
        local ip_port = array[i][1]..(array[i][2] or 80)
        if fail_host[ip_port] then
            table_remove(array, i)
        end
    end
    local cnt = #array
    local re = {}

    if _tb_host.mode == nil or _tb_host.mode == "polling" then

        local polling_cnt = balancer_dict:get(host.."polling_S")
        if polling_cnt == nil then
            polling_cnt = 1
        else
            polling_cnt = polling_cnt +1
            if polling_cnt > cnt then
                polling_cnt = 1
            end
        end
        balancer_dict:safe_set(host.."polling_S",polling_cnt,0)
        re = array[polling_cnt]

    elseif _tb_host.mode == "ip_hash" then

        local remote_ip = ngx_var.remote_addr
        local hash = ngx.crc32_long(remote_ip);
        hash = (hash % cnt) + 1
        re = array[hash]

    elseif _tb_host.mode == "url_hash" then

        local url = ngx.unescape_uri(ngx_var.uri)
        local hash = ngx.crc32_long(url);
        hash = (hash % cnt) + 1
        re = array[hash]

    elseif _tb_host.mode == "random" then
        local r = random.number(1, cnt)
        re = array[r]

    elseif _tb_host.mode == "weight.polling" then
        local weight_list = {}
        for i,v in ipairs(array) do
            local tmp_c = v[3] or 1
            if tmp_c > 10 then
                tmp_c = 9
            end
            for ii=1,tmp_c do
                table_insert(weight_list,array[i])
            end
        end
        local r = random.number(1, #weight_list)
        re = weight_list[r]
    end
    re[2] = re[2] or 80
    return re[1],re[2]
end


if tb_host.bal_list == nil or #tb_host.bal_list == 0 then
    ngx.log(ngx.ERR, "failed to set the current peer:", err)
    return ngx.exit(500)
else
    local up_host, up_port = load_balancer(tb_host)
    if up_host == nil then
        ngx.log(ngx.ERR, "load_balancer error: host is nil")
        return ngx.exit(500)
    end
    local ok, err = balancer.set_current_peer(up_host, up_port)
    if not ok then
          ngx.log(ngx.ERR, "failed to set the current peer:", err)
          return ngx.exit(500)
    end
end
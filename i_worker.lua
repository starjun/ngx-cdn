

local _worker_count = ngx.worker.count()
local _worker_id = ngx.worker.id()

local ngx_shared = ngx.shared
local ipairs = ipairs
local stool = require("stool")
local modcache = require("modcache")
local ngx_thread = ngx.thread
local timer_every = ngx.timer.every
local config_dict = ngx_shared.config_dict


local handler_zero

-- dict 清空过期内存
local function flush_expired_dict()
    local dict_list = {"config_dict","balancer_dict","ip_dict","limit_ip_dict"}
    for _,v in ipairs(dict_list) do
        ngx_shared[v]:flush_expired()
    end
end

handler_zero = function ()
    --清空过期内存
    ngx_thread.spawn(flush_expired_dict)
end

local function handler_all_worker()
    -- 每个 woker 进行 modcache 更新
    modcache.upcheck()
end

--- 动态健康检查
local function healthcheck()
    -- body
end

if _worker_id == 0 then
    timer_every(120,handler_zero)
    -- 执行后端健康检查
    -- timer_every(1,healthcheck)
end
timer_every(1,handler_all_worker)

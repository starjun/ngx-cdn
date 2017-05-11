

local host = ngx.unescape_uri(ngx.var.http_host)

local balancer = require "ngx.balancer"
local cjson_safe = require "cjson.safe"
local optl = require("optl")


local up_host, up_port

local balancer_dict = ngx.shared.balancer_dict
local tb_host = cjson_safe.decode(balancer_dict:get(host)) or {}

-- 调用前 确定_tb_host是一个table
local function load_balancer(_tb_host)
	local cnt = table.maxn(_tb_host.bal_list)
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
		re = _tb_host.bal_list[polling_cnt]

	elseif _tb_host.mode == "ip_hash" then

        local remote_ip = ngx.var.remote_addr
        local hash = ngx.crc32_long(remote_ip);  
        hash = (hash % cnt) + 1  
        re = _tb_host.bal_list[hash]

	elseif _tb_host.mode == "url_hash" then

		local url = ngx.unescape_uri(ngx.var.uri)
        local hash = ngx.crc32_long(url);  
        hash = (hash % cnt) + 1  
        re = _tb_host.bal_list[hash]

	elseif _tb_host.mode == "random" then

		math.randomseed(tostring(ngx.now()):reverse():sub(1, 7))
		-- 暂时没有用 lib 中的更强的随机函数	
    	re = _tb_host.bal_list[math.random(1,cnt)]

    elseif _tb_host.mode == "weight.polling" then

    	local tmplist = {}
    	local weight = 0
    	for i,v in ipairs(_tb_host.bal_list) do
    		 weight = weight + _tb_host.bal_list[i][3]
    	end

    	for i=1,weight do
    		for j,v in ipairs(_tb_host.bal_list) do
    			if _tb_host.bal_list[j][3] >0 then
    				table.insert(tmplist, {_tb_host.bal_list[j][1],_tb_host.bal_list[j][2]})
    				_tb_host.bal_list[j][3] = _tb_host.bal_list[j][3] -1
    			end
    		end
    	end

    	local polling_weight= balancer_dict:get(host.."weight.polling")
		if polling_weight == nil then
			polling_weight = 1
		else
			polling_weight = polling_weight +1
			if polling_weight > weight then
				polling_weight = 1
			end
		end
		balancer_dict:safe_set(host.."weight.polling",polling_weight,0)
		re = tmplist[polling_weight]

	end
	re[2] = re[2] or 80
	return re[1],re[2]
end

if tb_host.bal_list == nil or table.maxn(tb_host.bal_list) == 0 then
	ngx.log(ngx.ERR, "failed to set the current peer:", err)
	return ngx.exit(500)
else
	up_host, up_port = load_balancer(tb_host)
	--optl.writefile("/opt/openresty/dynamic_balancer/logs/1.log",up_host..":"..up_port)
	if up_host == nil then return ngx.exit(500) end
	local ok, err = balancer.set_current_peer(up_host, up_port)
	if not ok then
	    ngx.log(ngx.ERR, "failed to set the current peer:", err)
	    return ngx.exit(500)
	end
end
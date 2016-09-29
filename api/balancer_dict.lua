
local cjson_safe = require "cjson.safe"

local function get_argsByName(_name)
    --if _name == nil then return "" end
    --调用时 先判断下nil的情况
    local x = 'arg_'.._name
    local _name = ngx.unescape_uri(ngx.var[x])
    return _name
    -- local args_name = ngx.req.get_uri_args()[_name]
    -- if type(args_name) == "table" then args_name = args_name[1] end
    -- return ngx.unescape_uri(args_name)
end

local function sayHtml_ext(_html) 
    ngx.header.content_type = "text/html"
    if _html == nil then 
        _html = "_html is nil"
    elseif type(_html) == "table" then             
        _html = cjson_safe.encode(_html)
    end
    ngx.say(_html)
    ngx.exit(200)
end

local _action = get_argsByName("action")
local _host = get_argsByName("host")

local balancer_dict = ngx.shared["balancer_dict"]






-- 用于balancer_dict操作接口  对ip列表进行增 删 改 查 操作

--- add 
if _action == "add" then


--- del
elseif _action == "del" then


--- set 
elseif _action == "set" then

--- get 
elseif _action == "get" then

	if _host == "" then
		local _tb = balancer_dict:get_keys(0)
		sayHtml_ext({count=table.getn(_tb)})
	elseif _host == "all_host" then
		local _tb,tb_all = balancer_dict:get_keys(0),{}
		for i,v in ipairs(_tb) do
			tb_all[v] = balancer_dict:get(v)
		end
		sayHtml_ext(tb_all)
	else
		sayHtml_ext({host=_host,value=balancer_dict:get(_host)})
	end

else
	sayHtml_ext({code="error",msg="action is nil"})
end


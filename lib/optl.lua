
-- 用于生成唯一随机字符串
local random = require "resty-random"
local stool = require "stool"
local type = type
local dofile = dofile
local ipairs = ipairs
local io_open     = io.open
local string_format = string.format
local ngx_unescape_uri = ngx.unescape_uri
local ngx_re_find = ngx.re.find
local string_upper = string.upper
local string_sub = string.sub

local function guid(_num)
    _num = _num or 10
    return string_format('%s-%s',
        random.token(_num),
        random.token(_num)
    )
end

local function remath(_str , _re_str , _options)
    if _str == nil or _re_str == nil or _options == nil then
        return false
    end
    if _options == "" or _options == "=" then
        if _str == _re_str or _re_str == "*" then
            return true
        end
    elseif _options == "list" then
        return stool.isInArrayTb(_str , _re_str)
    elseif _options == "in" then
        return stool.stringIn(_str , _re_str)
        -- add new type
    elseif _options == "len" then
        if type(_re_str) ~= "table" then
            return false
        end
        local len_str = #_str
        if len_str >= _re_str[1] and len_str <= _re_str[2] then
            return true
        end
    elseif _options == "start_list" then
        if type(_re_str) ~= "table" then
            return false
        end
        for _ , v in ipairs(_re_str) do
            if stool.stringStarts(_str , v) then
                return true
            end
        end
    elseif _options == "restart_list" then
        if type(_re_str) ~= "table" then
            return false
        end
        for _ , v in ipairs(_re_str) do
            if stool.stringStarts(_str, string_upper(v)) then
                return true
            end
        end
    elseif _options == "end_list" then
        if type(_re_str) ~= "table" then
            return false
        end
        for _ , v in ipairs(_re_str) do
            if stool.stringEnds(_str , v) then
                return true
            end
        end
    elseif _options == "reend_list" then
        if type(_re_str) ~= "table" then
            return false
        end
        for _ , v in ipairs(_re_str) do
            if stool.stringEnds(_str, string_upper(v)) then
                return true
            end
        end
    elseif _options == "in_list" then
        if type(_re_str) ~= "table" then
            return false
        end
        for _ , v in ipairs(_re_str) do
            if stool.stringIn(_str , v) then
                return true
            end
        end
    elseif _options == "rein_list" then
        if type(_re_str) ~= "table" then
            return false
        end
        for _ , v in ipairs(_re_str) do
            if stool.stringIn(_str, string_upper(v)) then
                return true
            end
        end
    elseif _options == "dict" then
        if type(_re_str) ~= "table" then
            return false
        end
        local re = _re_str[_str]
        if re == true then
            return true
        end
    elseif _options == "cidr" then
        if type(_re_str) ~= "table" then
            return false
        end
        for _ , v in ipairs(_re_str) do

            local cidr                         = require "resty.cidr"
            local first_address , last_address = cidr.parse_cidr(v)
            --ip_cidr formats like 192.168.10.10/24

            local ip_num                       = cidr.ip_2_number(_str)
            --// get the ip to decimal.

            if ip_num >= first_address and ip_num <= last_address then
                --// judge if ip lies between the cidr.
                return true
            end
        end
    else
        local from , to = ngx_re_find(_str , _re_str , _options)
        if from ~= nil and to ~= 0 then
            -- payload
            -- start_num,end_num
            local start_num = 1
            if from > 5 then
                start_num = from - 5
            end
            local end_num = #_str
            if (#_str - to) > 5 then
                end_num = to + 5
            end
            local payload = string_sub(_str, start_num, end_num)
            return true
        end
    end
end

--- remath增加取反判断
local function remath_Invert(_str , _re_str , _options , _Invert)
    if _Invert then
        if not remath(_str , _re_str , _options) then
            -- 真
            return true
        end
    else
        if remath(_str , _re_str , _options) then
            -- 真
            return true
        end
    end
end

local function sayHtml_ext(_html,_find_type,_content_type)
    --ngx.header.content_type = "text/html"
    if _html == nil then
        _html = "_html is nil"
    elseif type(_html) == "table" then
        _html = stool.tableTojsonStr(_html)
    end
    if _content_type then
        ngx.header.content_type = _content_type
    end

    ngx.say(_html)
    ngx.exit(200)
end

local function sayFile(_filename,_header)
    --ngx.header.content_type = "text/html"
    --local str = readfile(Config.base.htmlPath..filename)
    local str = stool.readfile(_filename) or "filename error"
    if _header then
        ngx.header.content_type = _header
    end
    -- 对读取的文件内容进行 ngx_find
    ngx.say(str)
    ngx.exit(200)
end

local function sayLua(_luapath)
    local re = dofile(_luapath)
    return re
end

--- 获取单个args值
local function get_argsByName(_name)
    if _name == nil then return "" end
    local x = 'arg_'.._name
    local _name = ngx_unescape_uri(ngx.var[x])
    return _name
    -- local args_name = ngx.req.get_uri_args()[_name]
    -- if type(args_name) == "table" then args_name = args_name[1] end
    -- return ngx_unescape_uri(args_name)
end

--- 获取单个post值 非POST方法使用会异常
local function get_postByName(_name)
    if _name == nil then return "" end
    --ngx.req.read_body()
    local posts_name = ngx.req.get_post_args()[_name]
    if type(posts_name) == "table" then posts_name = posts_name[1] end
    return ngx_unescape_uri(posts_name)
end

local function get_paramByName(_name)
    if ngx.var.request_method == "POST" then
        return get_postByName(_name)
    else
        return get_argsByName(_name)
    end
end

--- 获取所有POST参数（包含表单）
local function get_post_all()
    --ngx.req.read_body()
    local data = ngx.req.get_body_data() -- ngx.req.get_post_args()
    if not data then
        local datafile = ngx.req.get_body_file()
        if datafile then
            local fh, err = io_open(datafile, "r")
            if fh then
                fh:seek("set")
                data = fh:read("*a")
                fh:close()
            end
        end
    end
    return ngx_unescape_uri(data)
end

local optl={}
optl.remath = remath
optl.remath_Invert = remath_Invert

optl.random = random
optl.guid = guid

--- say相关
optl.sayHtml_ext = sayHtml_ext
optl.sayFile = sayFile
optl.sayLua = sayLua

--- 请求相关
optl.get_paramByName = get_paramByName
optl.get_post_all = get_post_all

return optl
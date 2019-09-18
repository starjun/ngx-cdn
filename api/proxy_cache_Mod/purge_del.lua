-- proxy cache 删除
local stool = require "stool"
local optl  = require "optl"
local http = require "resty.http"

local _purge_list = optl.get_paramByName("purge_list")
-- {
--     "www.test.com":[
--       "/favicon.ico",
--       "/1.jpg?version=1.0.1"
--     ],
--     "www.abc.com":[
--       "/favicon.ico",
--       "/1.jpg"
--     ]
-- }
local _tb = stool.stringTojson(_purge_list) or {}

local re_tb = {}
for host,uri_list in pairs(_tb) do
    local _httpc = http.new()
    local _headers = {}
    _headers["host"] = host
    for _,uri in ipairs(uri_list) do
        local _url   = "http://127.0.0.1/purge"..uri
        local del_url = string.gsub(_url,"127.0.0.1",host)
        local re,err = _httpc:request_uri(_url , {
                method = "GET",
                headers = _headers
            })
        table.insert(re_tb,del_url)
    end
end

optl.sayHtml_ext({code="ok",msg="del purge cache successful"})
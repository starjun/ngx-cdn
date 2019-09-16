-- proxy cache 删除
local stool = require "stool"
local optl  = require "optl"
local modcache = require("modcache")
local http = require "resty.http"

local _purge_key = optl.get_paramByName("purge_key")
-- {
--     "base64 str1", --base64($scheme$host$request_uri)
--     "base64 str2",
--     "base64 str3"
-- }
local _tb = stool.stringTojson(_purge_key_list) or {}

local re_tb = {}
for i,v in ipairs(_tb) do
    local _httpc = http.new()
    local _url   = "http://127.0.0.1:5460/purge/?purge_key="..v
    local tmp = {}
    tmp.purge_key = v
    tmp.re,tmp.err = _httpc:request_uri(_url , {
            method = "GET"
        })
    table.insert(re_tb,tmp)
end

optl.sayHtml_ext({code="ok",msg=re_tb})
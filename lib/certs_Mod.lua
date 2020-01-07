--- dict save to json
local stool        = require("stool")
local table_insert = table.insert
local string_find  = string.find
local table_concat = table.concat
local ngx_path     = ngx.config.prefix()

-- 证书 %key%.crt
-- 私钥 %key%.key

-- return true 表示合法
local function openssl_test(_path,_type)
    local cmd
    if _type == "key" then
        cmd = "openssl rsa -in ".._path
        -- unable to load Private Key
    else
        cmd = "openssl x509 -in ".._path
        -- unable to load certificate
    end
    local re = stool.supCmd(cmd)
    if re == nil or re == "" then
        return false
    else
        return true
    end
end

-- return enddate
-- openssl x509 -enddate -noout -in xxxx
local function openssl_enddate(_path,_type)
    local md5_name = "/tmp/"..ngx.md5(_path)
    local cmd = "openssl x509 -enddate -noout -in ".._path.." >"..md5_name
    stool.supCmd(cmd)
    ngx.sleep(0.5)
    local tmp = stool.split(stool.supCmd("cat "..md5_name),"=")
    stool.supCmd("rm -rf "..md5_name)
    if type(tmp) == "table" then
        local _t = tmp[2]
        if _type then
            return os.date("%Y-%m-%d% H:%M:%S",ngx.parse_http_time(_t))
        else
            return _t
        end
    end
end

-- 单组证书保存并进行 openssl 检查
-- {
--     "ssl_certificate":"base64 str",
--     "ssl_certificate_key":"base64 str"
-- }
-- return true 表示证书合法
local function ssl_save(_certs_value,_key,_isMaster)
    local certs_path = "/tmp/certs/"
    stool.supCmd("mkdir -p "..certs_path)
    local path_crt = certs_path.._key..".crt"
    local path_key = certs_path.._key..".key"
    stool.writefile(path_crt,ngx.decode_base64(_certs_value["ssl_certificate"]),"w+")
    stool.writefile(path_key,ngx.decode_base64(_certs_value["ssl_certificate_key"]),"w+")
    if _isMaster == "Master" then
        ngx.sleep(0.5)
        if not openssl_test(path_crt,"crt") then
            stool.supCmd("rm -rf "..path_crt)
            stool.supCmd("rm -rf "..path_key)
            return false,_key.." openssl x509 test error"
        end
    end
    if _isMaster == "Master" then
        ngx.sleep(0.5)
        if not openssl_test(path_key,"key") then
            stool.supCmd("rm -rf "..path_crt)
            stool.supCmd("rm -rf "..path_key)
            return false,_key.." openssl rsa test error"
        end
    end
    local _t = openssl_enddate(path_crt)
    stool.supCmd("rm -rf "..path_crt)
    stool.supCmd("rm -rf "..path_key)
    return true,_t
end


local _M = {}

_M.openssl_test = openssl_test

_M.openssl_enddate = openssl_enddate

_M.ssl_save = ssl_save

return _M
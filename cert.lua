-- Copyright (C) 2016 Matthieu Tourne

-- Used to manipulate certs in the ssl_certificate_by_lua*
-- directive.
-- part of lua-resty-core, ships with OpenResty
local ssl   = require("ngx.ssl")
local stool = require("stool")
local modcache = require("modcache")

local function load_cert_from_mod_cache(name)
  local tb_host = modcache.keys.dynamic_host.cache
  local cert_name = tb_host[name].certs
  local tb_certs = modcache.keys.dynamic_certs.cache
  local tmp_cert = tb_certs[cert_name]
  if not tmp_cert then
    ngx.log(ngx.ERR, name.. " certs not in modcache: ", err)
    return ngx.exit(ngx.ERROR)
  end
  return {
         cert = ngx.decode_base64(tmp_cert.ssl_certificate),
         key = ngx.decode_base64(tmp_cert.ssl_certificate_key),
      }
end

local function load_cert_matching(name)

  local dot_pos = string.find(name, "%.") -- %. escapes '.' the matching character
  star_name = "*" .. string.sub(name, dot_pos)
  stool.writefile("/tmp/certs_main","dot_pos: "..star_name.."\n")
  return load_cert_from_mod_cache(name)

end

local function certs_main()
   -- clear the fallback certificates and private keys
   -- set by the ssl_certificate and ssl_certificate_key
   -- directives above:
   local ok, err = ssl.clear_certs()
   if not ok then
      ngx.log(ngx.ERR, "failed to clear existing (fallback) certificates")
      return ngx.exit(ngx.ERROR)
   end

   -- Get TLS SNI (Server Name Indication) name set by the client
   local name, err = ssl.server_name()
   if not name then
      ngx.log(ngx.ERR, "failed to get SNI, err: ", err)
      return ngx.exit(ngx.ERROR)
   end

   -- print("SNI: ", name)
   -- stool.writefile("/tmp/certs_main","SNI: "..name.."\n")

   local cert_data = load_cert_matching(name)
   if not cert_data then
      ngx.log(ngx.ERR, "Unable to load suitable cert for: ", name)
      return ngx.exit(ngx.ERROR)
   end

   local der_cert_chain, err = ssl.cert_pem_to_der(cert_data.cert)
   if not der_cert_chain then
      ngx.log(ngx.ERR, "Unable to load PEM for: ", name,
              ", err: ", err)
      return ngx.exit(ngx.ERROR)
   end

   local ok, err = ssl.set_der_cert(der_cert_chain)
   if not ok then
      ngx.log(ngx.ERR, "Unable te set cert for: ", name,
              ", err: ", err)
      return ngx.exit(ngx.ERROR)
   end

   local der_priv_key, err = ssl.priv_key_pem_to_der(cert_data.key)
   if not der_priv_key then
      ngx.log(ngx.ERR, "Unable to load PEM KEY for: ", name,
              ", err: ", err)
      return ngx.exit(ngx.ERROR)
   end

   local ok, err = ssl.set_der_priv_key(der_priv_key)
   if not ok then
      ngx.log(ngx.ERR, "Unable te set cert key for: ", name,
              ", err: ", err)
      return ngx.exit(ngx.ERROR)
   end
end

certs_main()

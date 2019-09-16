---
title: 动态upstream
tags: dynamic upstream,OpenResty,nginx lua
grammar_cjkRuby: true

---

**简易的动态upstream~**
暂时算法仅仅有ip_hash,url_hash,random

比较简单看一看就明白的，暂时没有写和redis的操作接口
weight.polling [权重+轮询] polling 算法重写
```
{
    "www.abc.com": {
        "bal_list": [["127.0.0.1",81],["127.0.0.1",82],["127.0.0.1",83]],
        "mode": "ip_hash"
    },
    "www.test.com": {
        "bal_list": [["127.0.0.1",81],["127.0.0.1",82]],
        "mode": "url_hash",
        "certs":"www.test.com"
    },
    "www.test2.com": {
        "bal_list": [["127.0.0.1",84],["127.0.0.1",83],["127.0.0.1",82],["127.0.0.1",81]],
        "mode": "random",
        "certs":"www.test2.com"
    },
    "www.abc1.com": {
        "bal_list": [["127.0.0.1",81],["127.0.0.1",82],["127.0.0.1",83]],
        "mode": "polling"
    },
    "www.abc2.com": {
        "bal_list": [["127.0.0.1",81,1],["127.0.0.1",82],["127.0.0.1",83,9]],
        "mode": "weight.polling"
    }
}
```

**感谢**
https://github.com/mtourne/ngx_lua_ssl
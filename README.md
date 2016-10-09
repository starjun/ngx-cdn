---
title: 动态upstream
tags: dynamic upstream,OpenResty,nginx lua
grammar_cjkRuby: true

---

**简易的动态upstream~**
暂时算法仅仅有ip_hash,url_hash,polling,random

比较简单看一看就明白的，暂时没有写和redis的操作接口

2016年10月9日add负载方式：weight.polling [权重+轮询]
`"bal_list": [["1.1.1.1",80,1],["2.2.2.2",80,2],["3.3.3.3"],["4.4.4.4",80,3]]`
启用该算法，中间的端口必须写上,最后的一个参数表示权重。
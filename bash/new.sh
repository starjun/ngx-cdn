## bash
## version 0.1

version=1.0.0.6
ip=192.168.84.41
if [ "$1" = "dynamic_upstream" ];then

    rm -rf /opt/openresty/dynamic_upstream.bak
    mv /opt/openresty/dynamic_upstream /opt/openresty/dynamic_upstream.bak

    cd /opt/openresty/
    wget -N "http://${ip}/dynamic_upstream-${version}.zip"
    unzip -o dynamic_upstream-${version}.zip -d /opt/openresty/
    mv -f dynamic_upstream-${version} dynamic_upstream


    if [ "$2" = "all" ];then ## conf + json
        cp -Rf /opt/openresty/dynamic_upstream.bak/conf_json/* /opt/openresty/dynamic_upstream/conf_json/
        cp -Rf /opt/openresty/dynamic_upstream.bak/conf/* /opt/openresty/dynamic_upstream/conf/
        # cp -Rf /opt/openresty/dynamic_upstream.bak/regsn.json /opt/openresty/dynamic_upstream/
    elif [ "$2" = "conf" ];then ## conf
        cp -Rf /opt/openresty/dynamic_upstream.bak/conf/* /opt/openresty/dynamic_upstream/conf/
    else ## json
        cp -Rf /opt/openresty/dynamic_upstream.bak/conf_json/* /opt/openresty/dynamic_upstream/conf_json/
    fi

elif [ "$1" = "test" ];then

    echo "it is a test!"

else
    echo "./new.sh dynamic_upstream"
fi
FROM alpine:3.1

MAINTAINER John Allen <john.allen@connexiolabs.com>

ENV NGINX_VERSION nginx-1.7.11
ENV DYNAMIC_VERSION f893a7971d85335127f080f03857065a22d82c79

RUN apk --update add openssl-dev pcre-dev zlib-dev wget build-base && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    wget --no-check-certificate https://github.com/simpl/ngx_devel_kit/archive/v0.2.19.tar.gz && \
    tar -zxvf v0.2.19.tar.gz && \
    wget --no-check-certificate https://github.com/openresty/set-misc-nginx-module/archive/v0.29.tar.gz && \
    tar -zxvf v0.29.tar.gz && \
    wget --no-check-certificate https://github.com/openresty/echo-nginx-module/archive/v0.58.tar.gz && \
    tar -zxvf v0.58.tar.gz && \
    wget --no-check-certificate https://github.com/arut/nginx-let-module/archive/v0.0.4.tar.gz && \
    tar -zxvf v0.0.4.tar.gz && \
    wget --no-check-certificate https://github.com/GUI/nginx-upstream-dyanmic-servers/archive/${DYNAMIC_VERSION}.tar.gz && \
    tar -zxvf ${DYNAMIC_VERSION}.tar.gz && \
    wget http://nginx.org/download/${NGINX_VERSION}.tar.gz && \
    tar -zxvf ${NGINX_VERSION}.tar.gz && \
    cd /tmp/src/${NGINX_VERSION} && \
    ./configure \
        --add-module=/tmp/src/echo-nginx-module-0.58 \
        --add-module=/tmp/src/ngx_devel_kit-0.2.19 \
        --add-module=/tmp/src/set-misc-nginx-module-0.29 \
        --add-module=/tmp/src/nginx-let-module-0.0.4 \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --with-http_stub_status_module \
        --prefix=/etc/nginx \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --sbin-path=/usr/local/sbin/nginx && \
    make && \
    make install && \
    apk del build-base && \
    rm -rf /tmp/src && \
    rm -rf /var/cache/apk/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/log/nginx", "/etc/nginx/conf.d"]

WORKDIR /etc/nginx

ADD nginx.conf /etc/nginx/conf/nginx.conf

CMD ["nginx", "-g", "daemon off;"]

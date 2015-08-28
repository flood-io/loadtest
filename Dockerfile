FROM ubuntu

RUN apt-get update -y -qq && apt-get install -y -qq wget

RUN \
  cd /tmp && \
  wget https://github.com/openresty/echo-nginx-module/archive/v0.57.tar.gz && \
  tar -xzvf /tmp/v0.57.tar.gz && \
  wget http://nginx.org/download/nginx-1.7.7.tar.gz && \
  tar -xzvf /tmp/nginx-1.7.7.tar.gz

RUN apt-get install -y build-essential
RUN \
  cd /tmp/nginx-1.7.7/ && \
  ./configure --prefix=/opt/nginx \
  --add-module=/tmp/v0.57
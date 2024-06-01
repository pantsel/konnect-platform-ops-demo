
FROM registry.access.redhat.com/ubi8/ubi:8.1
  
COPY kong.rpm /tmp/kong.rpm
  
RUN set -ex; \
   yum install -y /tmp/kong.rpm \
   && rm /tmp/kong.rpm \
   && chown kong:0 /usr/local/bin/kong \
   && chown -R kong:0 /usr/local/kong \
   && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit \
   && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/lua \
   && ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx \
   && kong version
  
COPY docker-entrypoint.sh /docker-entrypoint.sh
  
USER kong
  
ENTRYPOINT ["/docker-entrypoint.sh"]
  
EXPOSE 8000 8443 8001 8444 8002 8445 8003 8446 8004 8447
  
STOPSIGNAL SIGQUIT
  
HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health
  
CMD ["kong", "docker-start"]
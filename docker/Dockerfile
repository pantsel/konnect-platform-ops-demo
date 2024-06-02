FROM registry.access.redhat.com/ubi8/ubi:latest

# Install dependencies, Kong, and libcap
COPY kong.rpm /tmp/kong.rpm
RUN set -ex; \
    yum update -y && \
    yum upgrade -y && \
    yum install -y /tmp/kong.rpm libcap \
    && rm /tmp/kong.rpm \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && chown kong:0 /usr/local/bin/kong \
    && chown -R kong:0 /usr/local/kong \
    && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit \
    && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/lua \
    && ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx \
    && setcap cap_net_bind_service=ep /usr/local/bin/kong \
    && kong version

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Copy the Certificates
COPY .tls/ /srv/shared/ssl

# Ensure the entrypoint script is executable
RUN chmod +x /docker-entrypoint.sh

# Switch to the new non-root user
USER kong

# Run the container with a read-only filesystem
VOLUME /tmp

ENTRYPOINT ["/docker-entrypoint.sh"]

# Expose necessary ports
EXPOSE 8000 8443 8001 8444 8002 8445 8003 8446 8004 8447

# Set the stop signal
STOPSIGNAL SIGQUIT

# Health check configuration
HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health

CMD ["kong", "docker-start"]
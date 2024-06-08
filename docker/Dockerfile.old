FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

USER root

# Install dependencies, and Kong
COPY kong.rpm /tmp/kong.rpm
RUN set -ex; \
    microdnf update \
    && microdnf install -y perl perl-Time-HiRes \
    && rpm -i /tmp/kong.rpm \
    && rm /tmp/kong.rpm \
    && echo "kong:x:1000:1000:Kong user:/home/kong:/sbin/nologin" >> /etc/passwd \
    && echo "kong:x:1000:" >> /etc/group \
    && chown kong:0 /usr/local/bin/kong \
    && chown -R kong:0 /usr/local/kong \
    && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit \
    && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/lua \
    && ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx \
    && kong version

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Copy the Certificates
COPY .tls/ /srv/shared/ssl

# Include custom plugins
COPY kong-plugin/kong/plugins/ /usr/local/share/lua/5.1/kong/plugins/
RUN ls -la /usr/local/share/lua/5.1/kong/plugins/

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
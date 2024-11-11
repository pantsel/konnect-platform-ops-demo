# Use a minimal base image
FROM debian:bullseye-slim

# Copy the Kong package
COPY kong.deb /tmp/kong.deb

# Install only the necessary dependencies, clean up, and minimize image size
RUN set -eux; \
    apt-get update; \
    apt-get install --yes /tmp/kong.deb; \
    apt-get purge -y dpkg-dev; \
    apt-get autoremove -y; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/kong.deb; \
    chown kong:0 /usr/local/bin/kong; \
    chown -R kong:0 /usr/local/kong; \
    ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit; \
    ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/lua; \
    ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx; \
    kong version

# Include custom plugins
COPY kong-plugin/kong/plugins/ /usr/local/share/lua/5.1/kong/plugins/

# Copy entrypoint script and ensure it is executable
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 755 /docker-entrypoint.sh

# Switch to non-root user
USER kong

# Expose only necessary ports (adjust based on your use case)
EXPOSE 8000 8443 8001 8444 8002 8445 8003 8446 8004 8447

# Use a safe stop signal
STOPSIGNAL SIGQUIT

# Healthcheck for Kong
HEALTHCHECK --interval=10s --timeout=10s --retries=3 CMD kong health

# Set the entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]

# Default command
CMD ["kong", "docker-start"]

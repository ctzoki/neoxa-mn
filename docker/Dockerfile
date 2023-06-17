FROM ubuntu:22.04

# Create a non-root user
RUN adduser --disabled-password --gecos '' neoxa

# Set the working directory and copy the neoxad binary
WORKDIR /app
COPY neoxad /app/neoxad
COPY neoxa-cli /app/neoxa-cli
COPY entrypoint.sh /app/entrypoint.sh

# Adjust ownership and permissions
RUN chown neoxa:neoxa /app/neoxad
RUN chown neoxa:neoxa /app/neoxa-cli
RUN chown neoxa:neoxa /app/entrypoint.sh
RUN chmod +x /app/neoxad
RUN chmod +x /app/neoxa-cli
RUN chmod +x /app/entrypoint.sh

# Create the data directory and set permissions
RUN mkdir /var/lib/neoxa && chown -R neoxa:neoxa /var/lib/neoxa

# Switch to the non-root user
USER neoxa

# Set the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]

# Set the command to execute
CMD ["/app/neoxad", "-datadir=/var/lib/neoxa", "-printtoconsole", "-onlynet=ipv4", "-testnet=1"]

FROM ubuntu:22.04

# Create a non-root user with specific UID and GID
RUN addgroup --gid 5196 neoxa && adduser --disabled-password --gecos '' --uid 5196 --gid 5196 neoxa

# Set the working directory and download and unzip Neoxa binaries
WORKDIR /app
RUN apt-get update && apt-get upgrade -y && apt-get install -y curl unzip
RUN curl -LJO https://github.com/NeoxaChain/Neoxa/releases/download/5.1.1.1/neoxa-testnet-linux64.zip \
    && unzip -j neoxa-testnet-linux64.zip -d /app \
    && rm neoxa-testnet-linux64.zip

# Copy the entrypoint script
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
CMD ["/app/neoxad", "-datadir=/var/lib/neoxa", "-printtoconsole"]

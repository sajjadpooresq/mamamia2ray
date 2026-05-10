FROM debian:bookworm-slim

WORKDIR /app

# Install dependencies
RUN echo "📦 Installing system dependencies..." && \
    apt-get update && apt-get install -y --no-install-recommends \
    bash git curl wget unzip tzdata openssl ca-certificates \
    && echo "✅ Dependencies installed successfully" \
    && rm -rf /var/lib/apt/lists/*

# Copy and run xray installer
COPY install.sh /app/install.sh
RUN echo "⚙️  Running installation script..." && \
    chmod +x /app/install.sh && /app/install.sh && \
    echo "✅ Xray installation completed"

# Copy runtime config — then bake an immutable template copy
COPY config.json /etc/config.json
RUN cp /etc/config.json /etc/config.json.template

# Copy startup script
COPY startup.sh /app/startup.sh
RUN chmod +x /app/startup.sh

CMD ["/app/startup.sh"]

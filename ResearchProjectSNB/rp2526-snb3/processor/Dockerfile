FROM node:22-bookworm

# Install Python and dependencies for deface
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment and install deface
RUN python3 -m venv /opt/deface-env
ENV PATH="/opt/deface-env/bin:$PATH"
RUN pip install --upgrade pip && \
    pip install deface

# Verify deface installation
RUN deface --version

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci --only=production

# Copy application code
COPY . .

# Create temp directory
RUN mkdir -p /tmp/pxlcensor && \
    chmod 777 /tmp/pxlcensor

# Create non-root user
RUN groupadd -g 1001 nodejs && \
    useradd -r -u 1001 -g nodejs nodejs && \
    chown -R nodejs:nodejs /app

USER nodejs

ENV TEMP_DIR=/tmp/pxlcensor

CMD ["node", "worker.js"]

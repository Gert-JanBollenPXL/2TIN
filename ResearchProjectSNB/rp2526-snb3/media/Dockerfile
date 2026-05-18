
FROM node:22-alpine


WORKDIR /app


COPY package*.json ./
RUN npm install --only=production


COPY . .


# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Install su-exec for privilege dropping
RUN apk add --no-cache su-exec


RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001




EXPOSE 8081

ENTRYPOINT ["/entrypoint.sh"]
CMD ["node", "server.js"]
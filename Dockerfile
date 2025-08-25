FROM ghost:5-alpine

# Copy custom configuration
COPY --chown=node:node config.production.json /var/lib/ghost/config.production.json

USER node
WORKDIR /var/lib/ghost

# Expose port
EXPOSE 2368

# Start Ghost
CMD ["node", "current/index.js"]
# The BuildConfig's dockerStrategy.from replaces this FROM with hi-nodejs-base:latest.
FROM quay.io/rgupta/hi-nodejs:latest
ARG BUILD_MESSAGE="Hello from Red Hat Hardened Images"
ENV BUILD_MESSAGE=${BUILD_MESSAGE}

USER 0
WORKDIR /opt/app-root/src

# Dependencies first, so this layer is cached when only server.js changes
COPY package*.json ./
RUN if [ -f package-lock.json ]; then npm ci --omit=dev; else npm install --omit=dev; fi && \
    npm cache clean --force

COPY server.js ./
RUN date -u +"%Y-%m-%d %H:%M:%S UTC" > build-time.txt && \
    chown -R 1001:0 . && chmod -R g=u .

USER 1001
EXPOSE 8080
CMD ["node", "server.js"]

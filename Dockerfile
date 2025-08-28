# Use Nginx to serve the pre-built React app
FROM nginx:alpine

WORKDIR /usr/share/nginx/html

# Remove the default Nginx page
RUN rm -rf ./*

# Copy the pre-built React build folder directly
COPY build/ .

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# Add a healthcheck
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]

FROM node:18 as build

WORKDIR /app
COPY . .
RUN npm run build || echo "Skipping npm build"

FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]


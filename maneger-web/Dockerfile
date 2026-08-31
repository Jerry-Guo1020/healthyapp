# 管理端前端（plus-ui）多阶段构建
# 构建上下文：仓库根目录（docker build -f maneger-web/Dockerfile .）
FROM node:20-alpine AS build
WORKDIR /app
RUN corepack enable
COPY maneger-web/ ./
RUN pnpm install && pnpm build:prod

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
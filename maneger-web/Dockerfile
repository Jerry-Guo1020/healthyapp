# 管理端前端（plus-ui）多阶段构建
# 构建上下文：仓库根目录（docker build -f maneger-web/Dockerfile .）
FROM node:20-alpine AS build
WORKDIR /app
# 固定 pnpm 版本，避免 corepack 依赖 packageManager 字段而失败
RUN npm install -g pnpm@9.14.2
COPY maneger-web/ ./
RUN pnpm install && pnpm build:prod

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
# --------------------
# 第一阶段：编译构建环境
# --------------------
FROM rust:latest AS builder

# 创建工作目录
WORKDIR /usr/src/app

# 将当前目录所有文件复制到容器中
COPY . .

# 以 Release 模式编译二进制文件
RUN cargo build --release

# --------------------
# 第二阶段：运行环境 (使用精简的 Debian 镜像)
# --------------------
FROM debian:bullseye-slim

# 安装必要的依赖 (如 SSL 证书支持，虽然 restls 主要处理 raw tcp 但以防万一)
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

# 从构建阶段复制编译好的二进制文件
# 注意：二进制文件名根据 Cargo.toml 中的 name 字段，这里是 "restls"
COPY --from=builder /usr/src/app/target/release/restls /usr/local/bin/restls

# 赋予执行权限
RUN chmod +x /usr/local/bin/restls

# 容器启动时的默认入口
ENTRYPOINT ["restls"]

# 默认参数 (可选，你可以留空，让用户自己传参)
CMD ["--help"]

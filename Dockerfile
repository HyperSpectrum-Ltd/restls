# --------------------
# 第一阶段：编译构建环境
# --------------------
FROM rust:latest AS builder

WORKDIR /usr/src/app

# 安装 musl 工具链
RUN apt-get update && apt-get install -y musl-tools && rm -rf /var/lib/apt/lists/*
RUN rustup target add x86_64-unknown-linux-musl

COPY . .

# 使用 musl target 进行静态编译
RUN cargo build --release --target x86_64-unknown-linux-musl

# --------------------
# 第二阶段：运行环境 (使用 Alpine，体积极小)
# --------------------
FROM alpine:latest

# 安装基础证书 (restls 可能需要用来验证伪装域名的证书)
RUN apk add --no-cache ca-certificates

# 复制 musl 编译出的静态二进制文件
# 注意路径变了，在 target/x86_64-unknown-linux-musl/release/ 下
COPY --from=builder /usr/src/app/target/x86_64-unknown-linux-musl/release/restls /usr/local/bin/restls

RUN chmod +x /usr/local/bin/restls

ENTRYPOINT ["restls"]
CMD ["--help"]

FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    unzip \
    && rm -rf /var/lib/apt/lists/*

ENV BUN_INSTALL=/root/.bun
ENV PATH="$BUN_INSTALL/bin:$PATH"

RUN curl -fsSL https://bun.sh/install | bash

RUN curl --proto '=https' --tlsv1.2 -sSfL https://sh.vector.dev | bash -s -- -y --prefix /usr/local

WORKDIR /app

COPY server/ ./server/
COPY vector/vector.toml ./vector.toml

WORKDIR /app/server
RUN bun install

EXPOSE 3000

CMD ["sh", "-c", "bun start | vector -c /app/vector.toml"]


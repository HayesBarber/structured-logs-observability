FROM oven/bun:latest

COPY --from=timberio/vector:0.53.0-debian /usr/local/bin/vector /usr/local/bin/vector

WORKDIR /app

COPY server/ ./server/
COPY vector/vector.toml ./vector.toml

RUN cd server && bun install

EXPOSE 3000

WORKDIR /app/server
CMD ["sh", "-c", "bun start | vector -c /app/vector.toml"]


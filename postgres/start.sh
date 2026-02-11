docker run -d --name pg-dev \
  -e POSTGRES_USER=dev \
  -e POSTGRES_DB=appdb \
  -e POSTGRES_HOST_AUTH_METHOD=trust \
  -p 5432:5432 \
  postgres:16


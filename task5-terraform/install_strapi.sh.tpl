#!/bin/bash

# 1. Install Docker & Docker Compose (Official Script)
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# 2. Setup User Directory
mkdir -p /home/ubuntu/strapi-app
cd /home/ubuntu/strapi-app

# 3. Create docker-compose.yml
# Note: Using version '3.8' and 'docker compose' command
cat <<EOF > docker-compose.yml
version: '3.8'
services:
  postgres:
    image: postgres:15
    container_name: postgres-container-strapi
    restart: always
    environment:
      POSTGRES_USER: ${db_user}
      POSTGRES_PASSWORD: ${db_password}
      POSTGRES_DB: ${db_name}
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - strapi-net

  strapi:
    image: anirek/strapi-app:latest
    container_name: strapi-app
    restart: always
    environment:
      DATABASE_CLIENT: postgres
      DATABASE_HOST: postgres
      DATABASE_PORT: 5432
      DATABASE_NAME: ${db_name}
      DATABASE_USERNAME: ${db_user}
      DATABASE_PASSWORD: ${db_password}
      NODE_ENV: production
      APP_KEYS: key1,key2
      API_TOKEN_SALT: somerandomsalt123
      ADMIN_JWT_SECRET: supersecretadminjwt
      JWT_SECRET: supersecretjwt
    depends_on:
      - postgres
    ports:
      - "1337:1337"
    networks:
      - strapi-net

networks:
  strapi-net:
    driver: bridge

volumes:
  postgres-data:
EOF

# 4. Start Application
# Use 'docker compose' (v2) instead of 'docker-compose'
docker compose up -d

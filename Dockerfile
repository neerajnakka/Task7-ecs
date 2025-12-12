FROM node:20-slim AS build

WORKDIR /app
ENV NODE_ENV=development

# Install build tools needed for better-sqlite3 (node-gyp)
RUN apt-get update && apt-get install -y \
    python3 make g++ \
  && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build
RUN npm prune --omit=dev
RUN rm -rf .cache .strapi-updater.json


FROM node:20-slim AS runtime

WORKDIR /app

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=1337

COPY --from=build /app ./

EXPOSE 1337
CMD ["npm", "run", "start"]

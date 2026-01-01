# Practical Case Study: Optimizing a Node.js App

Let's look at a real-world example of optimizing a Strapi-like Node.js application.

## The "Naive" Approach (Bad)
This is how most beginners write a Dockerfile.

```dockerfile
# File: Dockerfile.bad
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
CMD ["npm", "start"]
```

**Result:**
*   **Size:** **1.2 GB**
*   **Why?** It includes the full Debian OS, development tools, full `node_modules` (including dev dependencies), and the `.git` folder (because we forgot `.dockerignore`).

---

## The "Optimized" Approach (Good)
Applying our techniques: Multi-stage, Alpine, `.dockerignore`.

### 1. The .dockerignore
```text
node_modules
.git
.env
dist
```

### 2. The Dockerfile
```dockerfile
# File: Dockerfile.optimized

# Stage 1: Dependency Cache
FROM node:18-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
# Use 'ci' for faster, reliable builds. Only prod dependencies.
RUN npm ci --omit=dev

# Stage 2: Builder
FROM node:18-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# Stage 3: Runner
FROM node:18-alpine AS runner
WORKDIR /app
ENV NODE_ENV production

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

CMD ["npm", "start"]
```

**Result:**
*   **Size:** **140 MB**
*   **Reduction:** **~88%**
*   **Impact:**
    *   Deployment time dropped from **90 seconds** to **12 seconds**.
    *   Storage cost reduced by **88%**.

---

📌 **Next:** [04. Tools and Cheatsheet](./04_Tools_and_Cheatsheet.md)

# Techniques for Docker Image Reduction

Reducing image size is not magic; it is about discipline and knowing specific strategies.

## 1. Multi-Stage Builds (The "Silver Bullet")
The single most effective technique.
*   **Concept:** Use one heavy image to *build* the app, and a different tiny image to *run* the app.
*   **Analogy:** You use a messy kitchen to cook code (compilers, headers, build tools), but you serve the food on a clean plate (runtime only).

**Example:**
```dockerfile
# Stage 1: Build (The Kitchen)
FROM node:18 AS builder
WORKDIR /app
COPY package.json .
RUN npm install          # Installs devDependencies (Heavy!)
COPY . .
RUN npm run build        # Creates the 'dist' folder

# Stage 2: Run (The Plate)
FROM node:18-alpine      # Tiny base image
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "dist/index.js"]
```

## 2. Choose the Right Base Image
*   **Standard (`node:18`):** Includes Debian, git, curl, openssl. (~1GB)
*   **Slim (`node:18-slim`):** Debain without the extra tools. (~200MB)
*   **Alpine (`node:18-alpine`):** Security-hardened, ultra-minimal Linux. (~50MB)
*   **Distroless (`gcr.io/distroless/nodejs`):** Google's extreme option. Contains *only* Node.js. No Shell. No Package Manager. (~30MB)

## 3. The `.dockerignore` File
*   **Concept:** Prevent local garbage file from being copied into the container.
*   **Common Mistakes:** Copying `.git` folder, `node_modules` (local), `AWS_CREDENTIALS` (Security risk!), or `coverage` reports.
*   **Action:** Always have a `.dockerignore` file.

## 4. Layer Caching & Ordering
Docker builds efficiently by caching layers.
*   **Bad Order:** Copy source code -> Install Dependencies. (Changing 1 line of code forces a re-install of all libraries).
*   **Good Order:** Copy `package.json` -> Install Dependencies -> Copy Source Code. (Libraries are cached; builds are instant).

## 5. Combine Run Commands (Less Layers)
Every `RUN` instruction creates a new layer.
*   **Bad:**
    ```dockerfile
    RUN apt-get update
    RUN apt-get install -y git
    RUN rm -rf /var/lib/apt/lists/*
    ```
*   **Good:** (One layer)
    ```dockerfile
    RUN apt-get update && \
        apt-get install -y git && \
        rm -rf /var/lib/apt/lists/*
    ```

---

📌 **Next:** [03. Practical Case Study (Node.js)](./03_Practical_Case_Study.md)

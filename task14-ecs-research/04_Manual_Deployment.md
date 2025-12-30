# Manual Deployment Guide: Step-by-Step

This guide walks you through deploying a simple web app to ECS using the AWS Management Console (Fargate Launch Type).

## Phase 1: Create the Task Definition
*The "Recipe"*

1.  **Navigate:** Go to **ECS** -> **Task Definitions**.
2.  **Create:** Click **Create new Task Definition**.
3.  **Config:**
    *   **Family Name:** `my-web-app-task`.
    *   **Launch Type:** Select **AWS Fargate**.
    *   **OS/Arch:** Linux / X86_64.
    *   **Task Size:** 0.5 vCPU, 1 GB Memory.
4.  **Container Details:**
    *   **Name:** `web-container`.
    *   **Image:** `nginx:latest` (or your ECR URI).
    *   **Port Mappings:** Container Port `80`. Protocol `TCP`.
5.  **Finish:** Click **Create**.

## Phase 2: Create the Cluster
*The "House"*

1.  **Navigate:** Go to **ECS** -> **Clusters**.
2.  **Create:** Click **Create Cluster**.
3.  **Config:**
    *   **Name:** `my-production-cluster`.
    *   **Infrastructure:** Select **AWS Fargate (Serverless)**.
4.  **Finish:** Click **Create**.

## Phase 3: Create the Service
*The "Guest Manager"*

1.  **Enter Cluster:** Click into `my-production-cluster`.
2.  **Deploy:** Under the **Services** tab, click **Create**.
3.  **Environment:**
    *   **Launch Type:** Fargate.
    *   **Family:** Select `my-web-app-task`.
    *   **Revision:** Latest (e.g., 1).
    *   **Service Name:** `my-web-service`.
    *   **Desired Tasks:** 2 (This means 2 copies will run).
4.  **Networking (Critical):**
    *   **VPC:** Select your default VPC.
    *   **Subnets:** Select at least 2 public subnets (for high availability).
    *   **Security Group:** Create new. Allow **HTTP** (Port 80) from **Anywhere** (0.0.0.0/0).
    *   **Auto-assign Public IP:** **ENABLED** (Since we are in a public subnet without a fancy Load Balancer yet).
5.  **Finish:** Click **Create Service**.

## Phase 4: Verification
*Did it work?*

1.  **Wait:** Watch the "Deployments" tab. The status will go from `PROVISIONING` -> `PENDING` -> `RUNNING`.
2.  **Find IP:**
    *   Go to the **Tasks** tab.
    *   Click on one of the **Task IDs** (e.g., `e43f...`).
    *   Look for **Public IP** in the details.
3.  **Test:** Copy that IP into your browser (`http://1.2.3.4`).
4.  **Success:** You should see the "Welcome to Nginx" page.

---

📌 **Next:** [05. Advanced Concepts](./05_Advanced_Concepts.md)


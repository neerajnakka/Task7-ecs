# Task 9: Optimizing Costs with Fargate Spot

"Task 9 is same as previous but we need to use fargate spot instance instead of fargate."

## 📉 What is Fargate Spot?
Fargate Spot allows you to run containers on **spare AWS capacity**.
*   **The Benefit**: It offers up to **70% discount** compared to standard Fargate prices.
*   **The Catch**: AWS can reclaim this capacity with a **2-minute warning** if they need it back.
*   **Best For**: Stateless applications like Strapi (since the database is external), websites, and CI/CD jobs.

---

## 🛠️ Implementation

We created a new directory `task9-spot` (copy of Task 8) to implement this safely.

### 1. The Code Change (`task9-spot/terraform/ecs.tf`)

We modified the `aws_ecs_service` resource.
**Yes, this is the ONLY change:** we removed `launch_type` and added the block below.

```hcl
resource "aws_ecs_service" "strapi" {
  # ... (other settings like name, cluster, task_definition keep same) ...
  
  # ❌ OLD: Standard Fargate (Expensive)
  # launch_type = "FARGATE"

  # ✅ NEW: Fargate Spot (Cheap)
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100 
  }
}
```

### 2. What does `weight` mean? ⚖️

The `weight` parameter controls **how many tasks** go to this provider compared to others.

*   **Scenario A (100% Spot)**:
    Since we only have **one** provider in the list, `weight = 100` (or 1, or any number) means **100%** of your tasks run on Spot.

*   **Scenario B (The Mix)**:
    If you wanted to be safe, you could mix them:
    ```hcl
    capacity_provider_strategy {
      capacity_provider = "FARGATE"      # Full Price
      weight            = 1              # 1 Share
    }
    capacity_provider_strategy {
      capacity_provider = "FARGATE_SPOT" # Cheap
      weight            = 4              # 4 Shares
    }
    ```
    *   **Result**: For every 5 tasks, **1** is On-Demand (Safe) and **4** are Spot (Cheap).

In our code, we are going "All In" on Spot for maximum savings.

---

## 🏃 Execution

1.  **Navigate to the new folder**:
    ```bash
    cd task9-spot/terraform
    ```

2.  **Initialize**:
    ```bash
    terraform init
    ```

3.  **Apply**:
    ```bash
    terraform apply -auto-approve
    ```

4.  **Verify**:
    *   Go to ECS Console -> Clusters -> strapi-ecs-cluster -> Services -> strapi-service.
    *   Look for **"Capacity Provider Strategy"**.
    *   It should say **FARGATE_SPOT: 100**.

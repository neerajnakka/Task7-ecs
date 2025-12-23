# Task 10: Blue/Green Deployment (CodeDeploy)

We successfully upgraded our ECS Service to support **Blue/Green Deployments** using AWS CodeDeploy.

## 🏗️ Architecture

Instead of the "Rolling Update" (standard), we now have:

1.  **Two Target Groups**:
    *   🔵 **Blue**: The current live version.
    *   🟢 **Green**: The new version (staging).
2.  **CodeDeploy Controller**:
    *   Manages the traffic shift.
    *   Strategy: `Canary10Percent5Minutes` (Shifts 10% traffic to Green, waits 5 mins, then shifts 100%).
3.  **ALB Listener**:
    *   The Listener rule is now managed by CodeDeploy to switch weights between Blue and Green.

---

## 🔧 Fixes Applied

We fixed two critical issues to make this work:

### 1. Database Connection (`ecs.tf`)
The database connection previously failed because the RDS instance requires SSL, but the container didn't know that.
*   **Fix**: Added `DATABASE_SSL="true"` to the environment variables.

```hcl
{
  name  = "DATABASE_SSL"
  value = "true"
}
```

### 2. "Custody Battle" Conflict (`ecs.tf`)
Terraform and CodeDeploy were fighting over who controls the Task Definition.
*   **Error**: `Unable to update task definition on services with a CODE_DEPLOY deployment controller`.
*   **Fix**: Added a `lifecycle` block to tell Terraform to back off.

```hcl
lifecycle {
  ignore_changes = [
    task_definition,
    load_balancer
  ]
}
```

---

## 🏃 Verification

### 1. Check the Deployment
1.  Go to **CodeDeploy Console** -> Applications -> `strapi-neeraj-app`.
2.  Click on the **Deployment Group**: `strapi-neeraj-deployment-group`.
3.  You will see the deployment configuration is **Blue/Green**.

### 2. Triggering a Deployment
To see it in action, you can trigger a "Force New Deployment" via Terraform (by changing a variable) or manually in the CodeDeploy console.
1.  **CodeDeploy Console** -> Create deployment.
2.  Choose the Application & Group.
3.  Select "My application is stored in Amazon ECS".
4.  Choose the `task-definition.json` and `appspec.json` (CodeDeploy requires these artifacts).

### 3. Traffic Shifting
During a deployment, watch the **Target Groups** in the EC2 Console:
*   You will see tasks spinning up in **Green**.
*   Traffic weight will shift: `Blue: 90 / Green: 10`.
*   After 5 minutes: `Blue: 0 / Green: 100`.

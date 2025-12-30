# Advanced ECS: Concepts & Best Practices

Once you understand the basics, you need to master these concepts for production environments.

## 1. IAM Roles (The Security Keys)
ECS uses **two** distinct IAM roles. Confusing them is the #1 beginner mistake.

### A. Task Execution Role (`ecsTaskExecutionRole`)
*   **Who uses it?** The **ECS Agent** (The infrastructure).
*   **Permissions needed:**
    *   "Pull docker image from ECR".
    *   "Push logs to CloudWatch".
*   *If your task fails to start with "CannotPullContainerError", your Execution Role is missing permissions.*

### B. Task Role (`TaskRole`)
*   **Who uses it?** **Your Code** inside the container.
*   **Permissions needed:**
    *   "Upload file to S3".
    *   "Read from DynamoDB".
*   *If your app crashes saying "Access Denied" when trying to read S3, this is the role to fix.*

## 2. Load Balancing (ALB)
In production, you never access a Task's IP directly (because it changes if the task restarts).
*   **Target Group:** ECS registers tasks into a Target Group.
*   **Application Load Balancer:** Sends traffic to the Target Group.
*   **Dynamic Port Mapping:** With ALB + EC2, you can map Container Port 80 to Host Port 0 (Random). The ALB updates automatically, allowing multiple copies of the same container on one server.

## 3. Auto-Scaling
Fargate allows amazing auto-scaling capabilities.

*   **Target Tracking:** "Keep CPU utilization at 70%."
    *   If CPU > 70%, ECS adds 2 tasks.
    *   If CPU < 70%, ECS kills 1 task.
*   **Benefit:** You pay for exactly what you need. No idle servers at 3 AM.

## 4. ECR (Elastic Container Registry)
The private DockerHub for AWS.
*   **Workflow:**
    1.  Dev builds image locally: `docker build -t my-app .`
    2.  Tag it: `docker tag my-app:latest 12345.dkr.ecr.us-east-1.amazonaws.com/repo:v1`
    3.  Push it: `docker push ...`
    4.  Task Definition references this ECR URI.

---

📌 **End of Course.** [Back to Glossary](./00_ECS_Glossary_for_Beginners.md)


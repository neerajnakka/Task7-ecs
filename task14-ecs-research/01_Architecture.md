# AWS ECS: Core Concepts and Architecture

**Amazon Elastic Container Service (ECS)** is a fully managed container orchestration service. It helps you deploy, manage, and scale containerized applications.

## 1. The Architecture Hierarchy

It is crucial to understand the hierarchy. One does not simply "run a container." You follow this chain:

1.  **Cluster:** The top-level wrapper.
2.  **Service:** Runs inside a cluster. Manages long-running processes (like a web server).
3.  **Task:** The actual running units (containers) managed by the Service.
4.  **Container:** Using Docker images defined in the Task Definition.

```mermaid
graph TD
    Cluster[ECS Cluster]
    
    subgraph Cluster
        ServiceA[Service: Web API]
        ServiceB[Service: Worker]
        
        ServiceA -- Manages --> Task1[Task (Replica 1)]
        ServiceA -- Manages --> Task2[Task (Replica 2)]
        
        ServiceB -- Manages --> Task3[Task (Worker 1)]
    end
    
    LB[Load Balancer] -- Traffic --> ServiceA
```

## 2. Key Components Detailed

### A. Task Definition (The Blueprint)
Before you run anything, you must create a **Task Definition**. This version-controlled JSON file defines:
*   **Image:** `nginx:latest`, `my-app:v1`
*   **Resources:** CPU (e.g., 256 units), Memory (e.g., 512 MiB).
*   **Networking:** Port mappings (Host 80 -> Container 80).
*   **IAM Roles:** Permissions the container needs (e.g., ability to upload to S3).

> *Note: You cannot change a Task Definition. You create a NEW Revision (v1, v2, v3).*

### B. Service (The Coordinator)
A **Service** is used for applications that need to stay running (like a website).
*   **Desired Count:** "I want 3 copies of this task running."
*   **Self-Healing:** If a task crashes, the Service Scheduler sees "Active: 2, Desired: 3" and starts a new one.
*   **Load Balancing:** The Service automatically registers new tasks with your Application Load Balancer (ALB).

### C. Cluster (The Infrastructure)
*   **EC2 Cluster:** You see the EC2 instances in your console. You pay for the EC2s even if they are empty.
*   **Fargate Cluster:** You see nothing. It's just a logical group. You pay nothing if nothing is running.

## 3. Networking Modes (`awsvpc`)

ECS has evolved. In the past, we used `bridge` mode (like local Docker). NOT ANYMORE.
Now, the standard is **`awsvpc` network mode**.

*   **How it works:** Every single Task gets its **own Elastic Network Interface (ENI)**.
*   **Implication:** Every Task gets its own private IP address inside your VPC Subnet.
*   **Security:** You can assign Security Groups *per Task*, not just per Server. This is massive for security.

---

📌 **Next:** [02. Deep Dive: Task Definitions](./02_Task_Definitions.md)



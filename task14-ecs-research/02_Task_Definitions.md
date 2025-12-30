# Deep Dive: ECS Task Definitions

You cannot run a container in ECS without a **Task Definition**. It is the most critical configuration piece in the entire ecosystem.

## 1. What is it really?

Think of a **Task Definition** as the **"DNA"** of your application.
*   It is a **text file** (JSON) that tells ECS exactly how to construct your container.
*   It is **Version Controlled** automatically. You never "edit" a task definition; you create **Version 2**, then **Version 3**. This allows you to roll back instantly if Version 3 is broken.
*   It is roughly equivalent to a `docker-compose.yml` file, but strictly for AWS.

## 2. The Anatomy of a Task Definition

A Task Definition contains two distinct scopes of configuration:

### A. The "Task" Level (The Wrapper)
These settings apply to the whole group of containers (if you have sidecars).
*   **Task Role:** What permissions does the *App* have? (e.g., S3 access).
*   **Execution Role:** What permissions does *ECS* have? (e.g., Pulling images).
*   **Network Mode:** Almost always `awsvpc` for Fargate.
*   **Total CPU / Memory:** The hard limit for the entire task.

### B. The "Container" Level (The Inside)
You can have 1 or more containers per task.
*   **Image:** `nginx:alpine` or `123.dkr.ecr...`
*   **Port Mappings:** Map Container Port 80 to Host.
*   **Environment Variables:** `DB_HOST=localhost`.
*   **Secrets:** Inject passwords securely from SSM Parameter Store.

## 3. Important Parameters Explained

### CPU and Memory (The Confusing Part)
You set CPU/Memory at **Task Level** AND **Container Level**.
*   **Task Level:** "I want to pay for 1 vCPU and 2GB RAM." (This is what you are billed for).
*   **Container Level:** "Container A gets at least 512MB. Container B gets the rest."
    *   *Best Practice:* Just set the Task Level limits and let the container use it all.

### Environment Variables vs. Secrets
*   **Environment Variables:** Plain text. Good for `NODE_ENV=production`. **BAD** for `DB_PASSWORD`.
*   **Secrets:** You reference a value in AWS Systems Manager (SSM).
    *   *Config:* `valueFrom: "arn:aws:ssm:us-east-1:123:parameter/my-db-pass"`
    *   *Result:* ECS fetches the password at startup and injects it as an Env Var. You never see the password in the console.

## 4. Visualizing the JSON

If you look at the `JSON` tab in the console, it looks like this:

```json
{
  "family": "my-web-app",
  "networkMode": "awsvpc",
  "cpu": "256",       // 0.25 vCPU
  "memory": "512",    // 512 MB
  "executionRoleArn": "arn:aws:iam::...:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "web-container",
      "image": "nginx:latest",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "environment": [
        { "name": "LOG_LEVEL", "value": "debug" }
      ],
      "secrets": [
        { "name": "DB_PASS", "valueFrom": "arn:aws:ssm..." }
      ]
    }
  ]
}
```

## 5. Revisions and Updates

1.  **Create:** You create `my-web-app:1`.
2.  **Update:** You change the image tag to `v2`. You are actually saving `my-web-app:2`.
3.  **Deploy:** You tell the **Service**: "Stop using revision 1. Please update to revision 2."
4.  **Rollback:** If `v2` crashes, you just tell the Service: "Go back to revision 1."

---

📌 **Next:** [03. Launch Types: Fargate vs EC2](./03_Launch_Types.md)


# Unleash: Overview and Architecture

## 1. What is Unleash?

**Unleash** is a powerful, open-source **feature management platform** that allows software teams to control the release of features at runtime. It decouples the deployment of code from the release of features.

In traditional software development, "deploying" and "releasing" were often the same event. If you deployed code, it was live for everyone. With Unleash, you can deploy code to production but keep the feature "off" (hidden) behind a **Feature Flag**. You can then toggle the feature "on" for specific users, percentage of traffic, or environments without redeploying.

### Key Value Propositions
*   **Decoupling Deployment from Release:** Deploy code whenever it's ready; release it when the business is ready.
*   **Risk Mitigation:** Test in production with a small subset of users (Canary Releases) before a full rollout.
*   **Kill Switches:** Instantly disable a buggy feature without a rollback.
*   **A/B Testing:** Run experiments to see which version of a feature performs better.

---

## 2. Why is it used?

Unleash is used to solve the complexities of modern continuous delivery (CD).

| Challenge | Unleash Solution |
| :--- | :--- |
| **Merge Hell** | Developers can merge incomplete code to the main branch (Trunk-Based Development) behind a flag, avoiding long-lived feature branches. |
| **Risky Releases** | instead of a "Big Bang" release where 100% of users get a new feature at once, Unleash allows **Gradual Rollouts** (e.g., 1% -> 10% -> 100%). |
| **Environment Consistency** | Manage configuration across Dev, Stage, and Prod from a single dashboard. |
| **User Targeting** | Enable features only for "Beta Users," "Internal Employees," or specific regions. |

---

## 3. Architecture

Unleash uses a **client-side evaluation** model (for server-side languages) and a **proxy model** (for frontend/mobile). This ensures privacy and performance.

### High-Level Components

1.  **Unleash Server (The Brain)**
    *   The central control plane.
    *   Provides the **Admin UI** for creating flags and strategies.
    *   Exposes a read-only API for SDKs to fetch flag configurations.
    *   Stores data in a **PostgreSQL** database.

2.  **Unleash SDKs ( The Enforcers)**
    *   Libraries installed in your application (Node.js, Java, Go, Python, etc.).
    *   **Polling:** The SDK periodically polls the Unleash Server for the latest *configuration* (rules), not the *status* for every user.
    *   **Local Evaluation:** The SDK evaluates the rules *locally* in memory. If a rule says "Enable for UserID 123", the SDK checks the current user's ID against the rule locally.
    *   **Benefit:** This is extremely fast (microseconds) and robust. If the Server goes down, the SDK continues to use the cached configuration.

3.  **Unleash Proxy / Edge (For Frontend)**
    *   Frontend apps (React, iOS, Android) cannot be trusted with the full configuration (security risk) and shouldn't poll the server directly (performance risk).
    *   The **Unleash Proxy** sits between the Frontend and the Server.
    *   The Frontend sends the user context (e.g., userId) to the Proxy.
    *   The Proxy evaluates the flags and returns simple `true/false` results to the frontend.

### Architecture Diagram (Conceptual)

```mermaid
graph TD
    subgraph "Infrastructure"
        DB[(PostgreSQL)]
        Server[Unleash Server / UI]
        DB --- Server
    end

    subgraph "Backend Services (Server-Side SDK)"
        App1[Backend App 1 <br/> (Node.js SDK)]
        App2[Backend App 2 <br/> (Go SDK)]
        
        Server -- "Sync Config (Polling)" --> App1
        Server -- "Sync Config (Polling)" --> App2
        
        App1 -- "Metrics" --> Server
    end

    subgraph "Frontend / Mobile (Client-Side)"
        Proxy[Unleash Proxy]
        React[React App]
        iOS[iOS App]

        Server -- "Sync Config" --> Proxy
        Proxy -- "Evaluated Flags" --> React
        Proxy -- "Evaluated Flags" --> iOS
    end
```

### Workflow

1.  **Create Flag:** Developer creates a flag `new-checkout-flow` in the Unleash Dashboard.
2.  **Define Strategy:** Developer sets a strategy: "Enable for 10% of users" OR "Enable for UserIDs: `test-user-1`".
3.  **Code:** Developer wraps the new code in an `if (isEnabled('new-checkout-flow')) { ... }` block.
4.  **Deploy:** Code is deployed to production. The flag is initially "Off".
5.  **Toggle:** Product Manager turns the flag "On" or creates a rollout strategy in the Dashboard.
6.  **Evaluate:**
    *   **Backend:** The SDK fetches the rule, sees "10% rollout", hashes the UserID, and determines if *this* user is in the lucky 10%.
    *   **Frontend:** The React app asks the Proxy "Is this enabled for me?", Proxy calculates and says "Yes".

---

## 4. Infrastructure Requirements: What does Unleash need?

To run Unleash specifically, you need two main components. We use **Docker** to bundle them together easily.

1.  **Unleash Server (Node.js):** The application logic.
2.  **Database (PostgreSQL):** Where flags and metrics are stored.

**Recommended Setup:**
*   **Docker & Docker Compose:** This is the industry standard for running Unleash locally or in simple deployments. It spins up both the Node.js Server and the Postgres DB in one command.

---

## 5. Summary Checklist

✅ **Decoupled:** Deploy code anytime; release features independently
✅ **Safe Rollouts:** Reduce risk with % rollout, user targeting
✅ **Observability:** See which flags are stale, unused, or error-prone
✅ **Self-Hosted:** Full control (unlike SaaS-only tools like LaunchDarkly)

📌 **Next:** [02. Core Concepts: Flags, Strategies, and Variants](./02_Unleash_Features_and_Use_Cases.md)


# Unleash Features and Use Cases

Unleash provides a robust set of features designed to support complex deployment strategies and experimentation.

## Core Features

### 1. Feature Flags (Toggles)
The fundamental unit of Unleash. A boolean switch that determines whether a feature is active.
*   **Standard Strategy:** On/Off for everyone.
*   **Flexible Rollout:** Roll out to a percentage of users (0% to 100%).
*   **UserID Strategy:** Enable only for specific User IDs (great for QA/Dev testing in Prod).
*   **IP Strategy:** Whitelist specific IP addresses.

### 2. Activation Strategies
Strategies define *who* gets the feature. Unleash allows you to chain constraints.
*   **Gradual Rollout (Canary):** Randomly enables the feature for a set percentage of users. "Stickiness" ensures that once a user gets a feature, they keep it (based on SessionID or UserID).
*   **Field-Based Constraints:** Create custom constraints. E.g., "Enable only if `plan` is `premium`" or "Enable only if `region` is `EU`".

### 3. Variants (A/B Testing)
Sometimes you don't just want On/Off; you want Option A vs. Option B.
*   **Variants** allow you to return a string payload (e.g., "blue-button", "red-button") instead of just true/false.
*   Useful for multi-variant testing.

### 4. Environments
Unleash supports multiple environments (e.g., `development`, `staging`, `production`) within the same project.
*   You can have a flag enabled in `development` but disabled in `production`.
*   Unleash enforces strict change management flows between environments.

### 5. Projects & Role-Based Access Control (RBAC)
*   **Projects:** Group flags by team or product area.
*   **RBAC:** Control who can create flags, who can toggle them in Prod, and who is read-only.

### 6. Audit Logging
Every change (toggle on/off, strategy update) is logged. You can see *who* changed *what* and *when*.

---

## Common Use Cases

### 1. Trunk-Based Development
*   **Scenario:** You are working on a large feature that takes 2 weeks. You don't want a long-lived feature branch.
*   **Unleash Solution:** Merge code to `main` daily, but wrap the entry point in a Feature Flag. The code is in production, but no user executes it.

### 2. Canary Releases
*   **Scenario:** You modified a critical API. You are 90% sure it works, but risks are high.
*   **Unleash Solution:** Use a "Gradual Rollout" strategy. Set it to 1%. Monitor error logs. If stable, increase to 10%, then 50%, then 100%.

### 3. Kill Switch (Circuit Breaker)
*   **Scenario:** A new 3rd-party integration starts timing out and bringing down your site.
*   **Unleash Solution:** Disable the feature flag for that integration immediately via the Unleash UI. The app reverts to the old behavior instantly without a code rollback.

### 4. VIP Features
*   **Scenario:** You want to give "Gold" users early access to a new dashboard.
*   **Unleash Solution:** Create a constraint: `user.plan` IN `['gold', 'platinum']`.

### 5. Maintenance Mode
*   **Scenario:** You need to disable a specific part of the system for maintenance.
*   **Unleash Solution:** Use a flag to show a "Under Maintenance" banner or disable the "Submit" button dynamically.

---

📌 **Next:** [03. Local Setup Guide (React + Docker)](./03_Local_Setup_Guide_React.md)


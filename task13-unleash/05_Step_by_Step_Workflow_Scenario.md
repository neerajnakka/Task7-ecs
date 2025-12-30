# Step-by-Step Workflow: The "Dark Mode" Scenario

To understand **how** and **when** to use Unleash, let's walk through a real-world scenario.

**The Goal:** You want to add a "Dark Mode" to your website, but you are afraid it might look broken for some users. You want to release it safely.

---

## Phase 1: Setup (The "One-Time" Stuff)
*Only done once per project.*

1.  **Install Unleash:** You run `docker compose up -d` to start the Unleash Server.
2.  **Install SDK:** You run `npm install ...` in your React app.
3.  **Connect:** You add the `<FlagProvider>` to your `App.js`.

---

## Phase 2: Development (Loop)

### Step 1: Create the Flag (In Unleash UI)
1.  Go to `localhost:4242`.
2.  Click **"New Feature Toggle"**.
3.  Name: `site-dark-mode`.
4.  Type: **Release**. (Because we are releasing a new feature).
5.  **Enable in Development:** Click the toggle for the "Development" environment.
6.  **Strategy:** Add "Standard" (On for everyone *in dev*).

### Step 2: Code the Feature (In VS Code)
You write the React code. You don't delete the old Light Mode yet.

```javascript
const isDarkMode = useFlag('site-dark-mode');

return (
  <div className={isDarkMode ? 'theme-dark' : 'theme-light'}>
    {/* Content */}
  </div>
);
```

*   **Test:** You run the app on localhost. Since the flag is ON in Dev, you see Dark Mode.
*   **Verify Switch:** You go to Unleash UI, turn the flag OFF. Your localhost app instantly turns to Light Mode. *Magic.*

### Step 3: Deployment
You push your code to GitHub and deploy to Production.
*   **Critical:** In Production, the flag `site-dark-mode` is still **OFF** (Disabled) by default in Unleash.
*   **Result:** Real users still see **Light Mode**. Nothing changed for them. You released the code safely.

---

## Phase 3: The Rollout (In Production)

Now, you want to release it.

### Step 4: Canary Test (Internal)
1.  In Unleash UI, switch to the **Production** environment.
2.  Add Strategy: **UserIDs**.
3.  Add your own User ID.
4.  **Result:** ONLY YOU see Dark Mode on the live site. Everyone else sees Light Mode. You verify it looks good.

### Step 5: Gradual Rollout
1.  Edit Strategy: Change to **Gradual Rollout**.
2.  Set slider to **10%**.
3.  **Result:** 10% of your random users now see Dark Mode.
4.  **Wait 24 hours:** Check your error logs. Did complaints go up?
    *   **If Yes:** Turn the flag **OFF** immediately. (Kill Switch).
    *   **If No:** Move slider to **50%**, then **100%**.

### Step 6: Cleanup
1.  Once 100% of users have Dark Mode for a few weeks, logic says you don't need the "Light Mode" code anymore.
2.  **Code Cleanup:** Go to VS Code, remove the `useFlag` check, and delete the Light Mode CSS.
3.  **Unleash Cleanup:** Archive the `site-dark-mode` flag in the dashboard.

---

## Recap: When to use what?

| Task | Feature Flag Strategy |
| :--- | :--- |
| **New big feature** | Gradual Rollout (0% -> 100%) |
| **Testing in Prod** | UserID Strategy (Target developers) |
| **Regional Feature** | Context constraint (`region` IN `['US', 'CA']`) |
| **Buggy Feature** | Kill Switch (Turn OFF immediately) |

---

📌 **Next:** [04. Commands Cheatsheet](./04_Commands_Cheatsheet.md)


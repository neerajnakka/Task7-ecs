# Unleash: Concepts for Absolute Beginners

If you have **0% knowledge** of Unleash or Feature Flags, start here. This dictionary explains the core concepts in plain English.

## The Core Concept: "The Light Switch"
Imagine a light switch on the wall.
*   **Without Unleash:** To turn the light on, you have to wire the house (write code) and build the wall (deploy). To turn it off, you have to tear down the wall (re-deploy code).
*   **With Unleash:** You wire the house once. Then, you use a remote control (Unleash Dashboard) to turn the light on or off instantly, without touching the wall.

## Key Terminology

### 1. Feature Flag (or Feature Toggle)
**What is it?** A variable in your code.
**Think of it as:** A standardized `if` statement.
*   **Code:** `if (unleash.isEnabled('my-new-feature')) { showNewFeature() }`
*   **Logic:** instead of hardcoding `true` or `false`, the code asks Unleash "Is this feature on?".

### 2. Strategy (The "Rules")
**What is it?** The condition for *when* the flag should be `true` (On).
**Think of it as:** The "Smart" part of the standard.
*   **Standard Strategy:** "Turn it on for everyone."
*   **Gradual Rollout:** "Turn it on for 10% of people." (Great for testing safety).
*   **UserIDs:** "Turn it on ONLY for `user_id: 123`." (Great for you testing it yourself).

### 3. Context (The "Who")
**What is it?** Information about the *current user* or *environment*.
**Think of it as:** The ID card you show the bouncer.
*   When your React app asks Unleash "Can I see the VIP page?", it must also say "I am User 55, from the USA". This extra info is the **Context**. Unleash uses this to decide if the Strategy matches.

### 4. Client-Side Evaluation (The "Privacy & Speed" Trick)
**What is it?** How Unleash makes decisions.
**Think of it as:** Downloading the rulebook instead of calling the referee.
*   **Server-Side:** Your app doesn't ask the Unleash Server for *every single user* "Is this user allowed?". That would be slow.
*   **Client-Side Evaluation:** Your app downloads the *entire list of rules* (the configuration) once. Then, when a user arrives, your app checks the rules *locally* in its own memory. It's instant.

### 5. Sticky / Stickiness
**What is it?** Ensuring a user gets the same experience every time.
**Think of it as:** Consistency.
*   If you roll out a feature to 50% of users, you don't want User A to see the feature, refresh the page, and then *not* see it.
*   **Stickiness** ensures that if User A was in the "lucky 50%" group nicely, they stay there.

### 6. Environment
**What is it?** Where your code is running.
*   **Development:** Your laptop. You play around here.
*   **Production:** The live website. Real users are here.
*   Unleash lets you have the *same* flag name (e.g., `new-header`) but have it **ON** in Development and **OFF** in Production.

## Summary Checklist
1.  **Create Flag** in Dashboard (e.g., "new-button").
2.  **Add Strategy** (e.g., "Standard" = On for everyone).
3.  **Code It** (Wrap your react component in `if (showButton)...`).
4.  **Connect** (Your app needs the API URL and Token to talk to Unleash).

---

📌 **Next:** [01. Overview and Architecture](./01_Unleash_Overview_and_Architecture.md)


# Local Setup Guide: Unleash with React

This guide covers setting up a local Unleash Server and connecting a React application to it.

## Prerequisites
*   **Docker Desktop** (running)
*   **Node.js** & **npm**
*   **Git**

---

## Part 1: Start Unleash Server (Docker)

We will use the official docker-compose setup to run the Unleash Server and Database.

### 1. Create a `docker-compose.yml`
Create a folder named `unleash-docker` and add this file:

```yaml
version: "3.9"
services:
  web:
    image: unleashorg/unleash-server:latest
    ports:
      - "4242:4242"
    environment:
      DATABASE_HOST: db
      DATABASE_NAME: unleash
      DATABASE_USERNAME: unleash_user
      DATABASE_PASSWORD: password
      DATABASE_SSL: "false"
      INIT_CLIENT_API_TOKENS: "*:development.unleash-insecure-api-token"
    depends_on:
      - db

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: unleash
      POSTGRES_USER: unleash_user
      POSTGRES_PASSWORD: password
```

### 2. Run the Server
Open a terminal in that folder and run:

```bash
docker compose up -d
```

### 3. Verify
*   Open your browser to [http://localhost:4242](http://localhost:4242).
*   **Login:**
    *   Username: `admin`
    *   Password: `unleash4all`

---

## Part 2: Configure Unleash

1.  **Create a Feature Flag:**
    *   Click **"New Feature Toggle"**.
    *   Name: `demo-banner`
    *   Type: Release
    *   Click **"Create"**.
    *   In the toggle view, under "Strategies", add a strategy (e.g., "Standard" or "Gradual Rollout").
    *   **IMPORTANT:** Enable the toggle in the `development` environment by clicking the toggle switch.

2.  **Get Client Key (API Token):**
    *   The docker-compose above pre-configured a token: `*:development.unleash-insecure-api-token`.
    *   For production, you would generate this in **Configure -> API Access**.

---

## Part 3: Connect React App

### 1. Install Dependencies
In your React project folder:

```bash
npm install @unleash/proxy-client-react unleash-proxy-client
```

### 2. Configure the Provider
Wrap your main application (e.g., `index.js` or `App.js`) with the `FlagProvider`.

> **Note:** The official Unleash Server image includes a simplified proxy endpoint for frontend testing at `/api/frontend`.

```jsx
// index.js or App.js
import React from 'react';
import ReactDOM from 'react-dom/client';
import { FlagProvider } from '@unleash/proxy-client-react';
import App from './App';

const config = {
  url: 'http://localhost:4242/api/frontend', // The frontend API endpoint
  clientKey: '*:development.unleash-insecure-api-token', // The token we defined in docker-compose
  refreshInterval: 15, // How often to check for updates (seconds)
  appName: 'my-react-app',
};

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <FlagProvider config={config}>
    <App />
  </FlagProvider>
);
```

### 3. Use the Flag in Components
Now you can use the hook `useFlag` to check if a feature is enabled.

```jsx
// App.js
import { useFlag } from '@unleash/proxy-client-react';

function App() {
  const showBanner = useFlag('demo-banner'); // Ensure this matches the name in Unleash UI

  return (
    <div className="App">
      <h1>Welcome to my App</h1>
      
      {showBanner && (
        <div style={{ background: 'gold', padding: '10px' }}>
          Example Feature is ENABLED!
        </div>
      )}
      
      {!showBanner && <p>Feature is disabled.</p>}
    </div>
  );
}

export default App;
```

---

## Part 4: Testing

1.  Run your React app (`npm start`).
2.  You should see the "Feature is enabled" message (if you toggled it ON in Unleash).
3.  Go to [http://localhost:4242](http://localhost:4242).
4.  Toggle `demo-banner` **OFF**.
5.  Wait 15 seconds (your `refreshInterval`).
6.  The React app should automatically update to hide the banner without a page refresh!

---

📌 **Next:** [05. Step-by-Step Workflow Scenario](./05_Step_by_Step_Workflow_Scenario.md)


# commands Cheatsheet: Unleash

This cheatsheet provides a quick reference for the essential commands and configurations used when working with Unleash locally and via Docker.

## Docker Setup Commands

Use these commands to manage the Unleash Server instance.

| Action | Command | Description |
| :--- | :--- | :--- |
| **Start Unleash** | `docker compose up -d` | **Starts the system.**<br>• `docker compose`: The tool that runs multi-container setups.<br>• `up`: Create and start containers.<br>• `-d` (Detached): Runs in the background. If you omit this, the logs will take over your terminal and closing the window kills the server. |
| **Stop Unleash** | `docker compose down` | **Stops and cleans up.**<br>• Stops the running containers.<br>• Removes the networks created by Docker.<br>• DOES NOT remove the database volume (your data is safe). |
| **View Logs** | `docker compose logs -f` | **Debugs issues.**<br>• `logs`: Prints output from the app.<br>• `-f` (Follow): Keeps the stream open so you see new logs in real-time (Ctrl+C to exit). |
| **Restart** | `docker compose restart` | **Reboots.**<br>• Useful if the server is acting stuck or you changed a config that requires a reboot but not a full rebuild. |
| **Pull Updates** | `docker compose pull` | **Updates.**<br>• Downloads the latest version of the "Unleash" and "Postgres" images from the internet if deeper updates are available. |

### Docker Compose Configuration Parameters
Important environment variables used in `docker-compose.yml`.

| Variable | Value (Example) | Description |
| :--- | :--- | :--- |
| `DATABASE_NAME` | `unleash` | Name of the Postgres DB. |
| `INIT_CLIENT_API_TOKENS` | `*:development.unleash-insecure-api-token` | **CRITICAL for Local Dev.** Auto-creates an API token so you don't have to manually generate one in UI initially. |
| `LOG_LEVEL` | `debug` | Set to `debug` if you need detailed server logs. |

---

## React SDK Installation

Commands to install the necessary libraries in your frontend project.

**Using npm:**
```bash
npm install @unleash/proxy-client-react unleash-proxy-client
```

**Using yarn:**
```bash
yarn add @unleash/proxy-client-react unleash-proxy-client
```

---

## API & Token Reference

When connecting your Client (React/Node) to Unleash, you need:

1.  **Unleash URL:**
    *   **Backend SDKs:** `http://localhost:4242/api`
    *   **Frontend (Proxy) Clients:** `http://localhost:4242/api/frontend` (When using the built-in edge/proxy in the server image).

2.  **Client Key (Token):**
    *   Format: `[project]:[environment].[random-string]`
    *   Example: `*:development.unleash-insecure-api-token`

---

## Troubleshooting

**1. "Connection Refused"**
*   **Cause:** Docker container isn't running or port 4242 is blocked.
*   **Fix:** Run `docker ps` to check status. Check if something else is using port 4242.

**2. Feature Flag always returns `false`**
*   **Cause A:** You didn't enable the flag in the correct **Environment** (e.g., Development).
*   **Cause B:** You didn't click "Save" or "Add Strategy" in the UI.
*   **Cause C:** Your `appName` in the SDK config doesn't match what is allowed (usually not restricted in dev, but good to check).
*   **Cause D:** The `refreshInterval` hasn't passed yet.

**3. CORS Errors**
*   Unleash Server usually handles CORS for localhost. If accessing from a different domain, you may need to configure `UNLEASH_CORS_ORIGIN` env var in Docker.

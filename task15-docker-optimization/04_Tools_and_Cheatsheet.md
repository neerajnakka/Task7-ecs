# Docker Optimization Tools & Cheatsheet

## Essential Tools

### 1. Dive (`dive`)
A tool to explore a docker image, layer contents, and discover methods to shrink the size.
*   **What it shows:** Exactly which file was added in which layer.
*   **Command:** `dive my-image:latest`
*   **Goal:** Look for "Red" bars (wasted space) where you added a file in Layer A and verified removed it in Layer B (Docker still keeps Layer A!).

### 2. Docker Slim (`slim`)
An automated tool that analyzes your container and "minifies" it.
*   **Magic:** It runs your container, watches what files it *actually touches*, and deletes everything else.
*   **Warning:** Can sometimes be too aggressive. Always test the output image.

### 3. Grype / Trivy
Security scanners.
*   **Goal:** While not strictly for *size*, they identify vulnerabilities. Smaller images typically have fewer results here.

---

## Optimization Checklist

| Item | Action | Benefit |
| :--- | :--- | :--- |
| **Base Image** | Switch to `alpine` or `slim`. | Massive size reduction. |
| **Ignore Files** | Verify `.dockerignore` exists. | Prevents sending trash to build context. |
| **Stages** | Use Multi-Stage builds. | Separates build tools from runtime code. |
| **Cleaning** | `apt-get clean` and `rm -rf /var/lib/apt/lists/*`. | Removes temporary install files. |
| **User** | Run as `USER node` (not specific to size, but vital). | Security best practice. |

---

📌 **End of Course.** [Back to Main README](../README.md)

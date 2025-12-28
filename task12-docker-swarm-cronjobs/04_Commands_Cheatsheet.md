# 04. Docker Swarm & Cronjob Command Reference  
*A Practical, Safety-First Cheat Sheet for Beginners & Pros*

> 💡 **How to Use This Guide**  
> - 🔎 **Search by goal** (e.g., “How do I add a node?”)  
> - 🧪 **All examples are tested** — copy/paste into your terminal  
> - ⚠️ **Warnings** call out common pitfalls  
> - 📌 **“Why This Matters”** explains the *purpose* behind each command  

---

## 🧱 1. Swarm Setup & Cluster Management

### ✅ Initialize a Swarm (Single-Node Cluster)
```bash
docker swarm init
```
- **What it does**: Turns your machine into a *Swarm Manager*.  
- **Output includes**:  
  - Your node ID (e.g., `xyz123`)  
  - Command to add workers (ignore for single-node)  
- ⚠️ **Only run once per machine** — subsequent runs fail.

> 🔍 **Verify**:
> ```bash
> docker info --format 'Swarm State: {{.Swarm.LocalNodeState}}'
> # → Swarm State: active
> ```

---

### ➕ Add a Worker Node (Multi-Machine)
On the **manager**, get the join token:
```bash
docker swarm join-token worker
```
→ Outputs a command like:
```bash
docker swarm join --token SWMTKN-1-abc...def 192.168.1.10:2377
```

On the **worker machine**, run that command.

> 📌 **Why tokens?**  
> Tokens prevent unauthorized machines from joining your cluster (security!).

---

### 📋 List All Nodes
```bash
docker node ls
```
Sample output:
```
ID        HOSTNAME   STATUS  AVAILABILITY  MANAGER STATUS
xyz123 *  laptop     Ready   Active        Leader
abc456    worker-01  Ready   Active
```
- `*` = current node  
- `STATUS: Ready` = healthy  
- `AVAILABILITY: Drain` = no new tasks allowed (use for maintenance)

---

### 🛑 Leave the Swarm (Single-Node Cleanup)
```bash
docker swarm leave --force
```
- `--force` required when you’re the only manager.  
- ⚠️ **Destroys cluster state** — all services are deleted.

---

## 📦 2. Service Management (Your “Workloads”)

### 🚀 Create a Service (Basic)
```bash
docker service create \
  --name my-app \
  --replicas 3 \
  nginx:alpine
```
| Flag | Meaning | When to Use |
|------|---------|-------------|
| `--name` | Human-readable name | ✅ Always use — helps in logs & debugging |
| `--replicas N` | “Keep N containers running” | `1` for cronjobs, `3+` for web apps |

> 🧠 **Fun Fact**: A service with `--replicas 0` is *idle* — perfect for cronjobs triggered later.

---

### 🔄 Create a “Cron-Like” Service (Restart Policy)
```bash
docker service create \
  --name backup-job \
  --replicas 1 \
  --restart-condition any \
  --restart-delay 1h \
  alpine sh -c "date && echo '✅ Done' && exit 0"
```
| Flag | Why It Matters |
|------|----------------|
| `--restart-condition any` | Restarts on *success* (`exit 0`) **and** failure (`exit 1`) |
| `--restart-delay 1h` | Wait 1 hour *after exit* before restarting → your “interval” |

> ⚠️ **Drift Warning**: Actual interval = `script runtime + delay`.  
> For 1h jobs, a 5m script → 1h5m between starts.

---

### 📝 Update a Running Service
```bash
# Change replica count
docker service scale backup-job=0

# Update image
docker service update --image alpine:latest my-app

# Add a secret
echo "secret" | docker secret create api-key -
docker service update --secret-add source=api-key,target=api_key my-app
```

> 🔒 **Secrets Tip**:  
> Secrets are mounted at `/run/secrets/<target>` inside the container — **never in env vars**.

---

### 🗑️ Delete a Service (Gracefully)
```bash
docker service rm backup-job
```
- Removes service + all tasks  
- Non-blocking — returns immediately (cleanup happens in background)

---

## 🔍 3. Debugging & Inspection

### 📊 List All Services
```bash
docker service ls
```
Output:
```
ID             NAME          MODE         REPLICAS   IMAGE
x1y2z3         backup-job    replicated   0/0        alpine
a1b2c3         web           replicated   3/3        nginx:alpine
```
- `0/0` = desired/running (0 desired, 0 running)  
- `3/3` = healthy

---

### 👀 See Service Tasks (Containers)
```bash
docker service ps backup-job
```
Useful columns:
| Column | Meaning |
|--------|---------|
| `DESIRED STATE` | What Swarm *wants* (`Running`, `Shutdown`) |
| `CURRENT STATE` | What’s *actually* happening (`Running 5s ago`, `Complete 1m ago`) |
| `ERROR` | Why it failed (e.g., `"task: non-zero exit (1)"`) |

> 💡 Add `--no-trunc` to see full error messages:
> ```bash
> docker service ps --no-trunc backup-job
> ```

---

### 📜 View Logs
```bash
# All logs (merged)
docker service logs backup-job

# Live stream
docker service logs -f backup-job

# Logs from one task only (best for cron!)
docker service logs backup-job.1.uvxyz
```
> ✅ **Pro Tip**: Task IDs (`backup-job.1.uvxyz`) give you *per-run logs* — critical for debugging cron.

---

### 📋 Inspect Service Configuration
```bash
docker service inspect backup-job --pretty
```
Shows:  
- Replicas  
- Restart policy  
- Labels (e.g., cron triggers)  
- Mounts, secrets, networks  

> 🔍 To see raw JSON (for scripting):
> ```bash
> docker service inspect backup-job | jq '.[0].Spec'
> ```

---

## ⏱️ 4. Cronjob-Specific Commands

### 🚀 Deploy `swarm-cronjob` Controller (Production)
```bash
docker service create \
  --name swarm-cronjob \
  --mode global \
  --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  crazymax/swarm-cronjob:latest
```
| Part | Why |
|------|-----|
| `--mode global` | Runs 1 instance on *every* manager node (HA!) |
| `--mount ... docker.sock` | Lets it talk to Docker Engine (required) |

> 🔐 **Security Note**:  
> This gives the controller full Docker API access — only deploy on trusted managers.

---

### 📅 Create a True Cronjob (Using Labels)
```bash
docker service create \
  --name nightly-backup \
  --replicas 0 \
  --label "swarm.cronjob.enable=true" \
  --label "swarm.cronjob.schedule=0 2 * * *" \
  --label "swarm.cronjob.skip-running=true" \
  alpine date
```
| Label | Meaning |
|-------|---------|
| `swarm.cronjob.enable=true` | “This is a cronjob — watch me!” |
| `schedule=0 2 * * *` | “Run daily at 2:00 AM UTC” ([test here](https://crontab.guru)) |
| `skip-running=true` | “Don’t start a new run if the last one is still going” |

> 🧪 **Test it now** (run once immediately):
> ```bash
> docker service scale nightly-backup=1
> docker service logs -f nightly-backup
> ```

---

## 🆘 5. Emergency & Recovery

### 🔁 Force Restart All Tasks
```bash
docker service update --force my-app
```
- Recreates *all* containers (even healthy ones)  
- Use after config/secrets change.

---

### 🚧 Drain a Node (Maintenance Mode)
```bash
docker node update --availability drain <node-id>
```
- Moves all tasks off the node  
- Safe for OS updates/reboots  
- Reverse with: `--availability active`

---

### 🔄 Rotate Join Tokens (Security Best Practice)
```bash
# Rotate worker token
docker swarm join-token --rotate worker

# Get new command
docker swarm join-token worker
```
- Invalidates old tokens → prevents stale machines from rejoining  
- Do this quarterly or after employee offboarding.

---

## 📚 6. Quick Reference Tables

### 📏 Restart Policies
| Policy | When It Restarts | Best For |
|--------|------------------|----------|
| `--restart-condition any` | Always (success/failure) | Cronjobs (interval-based) |
| `--restart-condition on-failure` | Only on `exit ≠ 0` | Web apps (don’t restart on success!) |
| `--restart-max-attempts 3` | Up to 3 times, then stop | Prevent retry loops |

### 🔤 Common `docker service` Flags
| Flag | Shortcut | Use Case |
|------|----------|----------|
| `--replicas N` | `-r N` | Set desired task count |
| `--detach` | `-d` | Run in background (default for services) |
| `--constraint 'node.role==manager'` | — | Run only on managers |

---

## ➕ Further Reading
- [Docker CLI Docs](https://docs.docker.com/engine/reference/commandline/)  
- [Cron Expression Tester](https://crontab.guru)  
- [`swarm-cronjob` Examples](https://github.com/crazy-max/swarm-cronjob/tree/master/examples)
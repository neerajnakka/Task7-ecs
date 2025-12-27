# 04. Commands Cheatsheet

A quick reference guide for all commands related to managing Swarm and Services.

## Swarm Management
| Command | Description |
| :--- | :--- |
| `docker swarm init` | Initialize a swarm. The current node becomes a Manager. |
| `docker swarm join-token worker` | Show command to join a new worker node. |
| `docker swarm leave --force` | Make the current node leave the swarm. |
| `docker node ls` | List all nodes in the cluster. |
| `docker node inspect <NODE>` | View detailed metadata of a node. |

## Service Management
| Command | Description |
| :--- | :--- |
| `docker service ls` | List all running services. |
| `docker service ps <SERVICE>` | List the tasks (containers) of a specific service. |
| `docker service logs <SERVICE>` | View logs of all containers in a service. |
| `docker service inspect <SERVICE>` | detailed configuration of a service. |
| `docker service rm <SERVICE>` | Remove/Stop a service. |
| `docker service scale <SERVICE>=<N>` | Scale a service to N replicas. |

## Service Creation (Cron Examples)

### 1. Basic Interval (Restart Policy)
```bash
docker service create \
  --name <NAME> \
  --restart-condition any \
  --restart-delay <INTERVAL> \
  <IMAGE> <COMMAND>
```

### 2. Using Swarm-Cronjob Labels
*(Requires swarm-cronjob controller running)*
```bash
docker service create \
  --name <NAME> \
  --replicas 0 \
  --label swarm.cronjob.enable=true \
  --label swarm.cronjob.schedule="* * * * *" \
  <IMAGE> <COMMAND>
```

## Debugging
- **Check Task Errors**:
  ```bash
  docker service ps <SERVICE> --no-trunc
  ```
- **View Container Output**:
  ```bash
  docker service logs -f <SERVICE>
  ```

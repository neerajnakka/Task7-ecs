# 01. Docker Swarm Architecture Overview

## Introduction
Docker Swarm is a container orchestration tool natively embedded in the Docker Engine. It allows you to manage a cluster of Docker engines as a single virtual system.

## High-Level Architecture
The architecture consists of **Nodes**, which can be either **Managers** or **Workers**.

![Docker Swarm Architecture Diagram](https://docs.docker.com/engine/swarm/images/swarm-diagram.png)
*(Source: Official Docker Documentation)*

### Components Breakdown

#### 1. Nodes
- **Manager Nodes**:
    - **Role**: Brain of the cluster.
    - **Responsibilities**:
        - Maintain cluster state (Raft consensus).
        - Schedule services.
        - Serve the Swarm API.
    - **Best Practice**: Run an odd number (3 or 5) for high availability.
- **Worker Nodes**:
    - **Role**: Muscle of the cluster.
    - **Responsibilities**:
        - Execute containers (Tasks) assigned by Managers.
        - Report state back to Managers.
    - **Note**: Managers also run tasks by default, but can be configured as "Drain" to be pure managers.

#### 2. Services and Tasks
- **Service**: The desired state definition (e.g., "Run 3 replicas of Nginx").
- **Task**: The atomic scheduling unit. A task = One Container.
- **Load Balancing**: Swarm has a built-in routing mesh. Requests to any node are routed to an active task.

### Architecture Visualization (Mermaid)
Below is a visual representation of how Managers orchestrate Workers.

```mermaid
graph TD
    subgraph Swarm Cluster
        subgraph Manager Nodes
            M1[Manager 1 (Leader)]
            M2[Manager 2]
            M3[Manager 3]
            M1 <--> M2
            M2 <--> M3
            M3 <--> M1
        end
        
        subgraph Worker Nodes
            W1[Worker 1]
            W2[Worker 2]
            W3[Worker 3]
        end
        
        M1 -- Assigns Tasks --> W1
        M1 -- Assigns Tasks --> W2
        M1 -- Assigns Tasks --> W3
    end
    
    Client[User / CI/CD] -- Docker Service Create --> M1
```

## Networking (Overlay Network)
Swarm uses an **Overlay Network** to connect containers across multiple hosts.
- Containers on different physical nodes can communicate as if they were on the same LAN.
- **Ingress Network**: Handles traffic entering the swarm and routes it to the correct service.

### Key Takeaways
- **Decentralized Design**: You can submit commands to any manager.
- **Declarative Model**: You define *what* you want (3 replicas), and Swarm ensures it happens.
- **Scaling**: Add more nodes to increase capacity (horizontal scaling).

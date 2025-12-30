# AWS ECS: The Absolute Beginner's Glossary

If you are new to AWS ECS, the terminology can be confusing. Start here.

## The Core Metaphor: "The Hotel Management"

Imagine running a hotel.
*   **The Guests:** Your Docker Containers (The apps).
*   **The Rooms:** The CPU and Memory resources.

### 1. ECS (Elastic Container Service)
**What is it?** The Hotel Manager.
**Analogy:** The automated system that decides which guest goes in which room and ensures the hotel doesn't burn down. It doesn't *own* the building; it just *manages* the placement of guests.

### 2. Cluster
**What is it?** A logical grouping of resources.
**Analogy:** The "Hotel Building" itself. You might have a "Production Hotel" (Cluster) and a "Testing Hotel" (Cluster). Rules set at the cluster level apply to everything inside.

### 3. Task Definition
**What is it?** The Blueprint / Recipe.
**Analogy:** The "Reservation details" or "Room Service Menu". It describes *what* the guest needs:
*   "I need 2GB of RAM."
*   "I need port 80 open."
*   "I need the `nginx` image."
It is a JSON file that tells ECS how to run a container. Nothing runs until you use this blueprint.

### 4. Task
**What is it?** A running instance of a Task Definition.
**Analogy:** The actual "Guest in the Room". If you have a blueprint (Task Def), the **Task** is the live, running container created from that blueprint.

### 5. Service
**What is it?** The Long-Running Manager.
**Analogy:** The "Housekeeping & Concierge Staff".
*   If a Guest (Task) dies (crashes), the Service notices and immediately puts a new Guest in the room to replace them.
*   The Service ensures you always have exactly 5 guests (Desired Count) at all times.
*   It handles the Load Balancer connections.

### 6. Container Instance (EC2)
**What is it?** The actual Virtual Machine (Server).
**Analogy:** The physical floorboards and walls. If you use the **EC2 Launch Type**, you have to manage these servers (patching, updating OS).

### 7. Fargate
**What is it?** Serverless Compute Engine.
**Analogy:** "Ghost Hotel". You don't see the building, walls, or servers. You just say "I need a room," and magically a room floats in usage. You pay *only* for the time the guest is there. You don't manage the OS.

---

📌 **Next:** [01. Architecture, Concepts & Hierarchy](./01_Architecture.md)


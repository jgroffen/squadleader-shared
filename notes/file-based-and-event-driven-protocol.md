# Prompt

Design a file‑based or event‑driven agent protocol.

# Response

Perfect—this is the **right layer** to formalize if you want multi‑agent systems that are durable, auditable, and vendor‑neutral.

Below is a **clean, extensible design for a file‑based *and* event‑driven agent protocol**. The two modes share the same contracts; only the transport differs.

Think of this as a **wire protocol for agents**, not an implementation.

***

# 1. Design goals (non‑negotiable)

This protocol is intentionally boring and explicit.

**Goals**

*   Vendor neutral (Copilot, Claude, OpenAI, local models)
*   Replayable & auditable
*   Tool‑agnostic
*   Safe for parallel and async execution
*   Human‑inspectable

**Non‑goals**

*   No model‑specific features (functions, tools, teams)
*   No hidden “agent memory”
*   No conversational magic

***

# 2. Core abstractions

The protocol revolves around **four primitives**:

1.  **Task**
2.  **Agent**
3.  **Artifact**
4.  **Event**

Each one is stable and serializable.

***

## 2.1 Task

A **Task** is work to be done; it is immutable except for status.

```yaml
# tasks/T-042.yaml
task_id: T-042
goal: Add pagination support to list endpoints
requested_by: orch
status: pending
inputs:
  - requirements.md
  - openapi.yaml
acceptance_criteria:
  - All list endpoints support page & pageSize
  - No breaking API changes
```

**Important**

*   Tasks never contain execution detail
*   Tasks do not reference agents directly

***

## 2.2 Agent

An **Agent** is a capability specification, not a runtime process.

```yaml
# agents/api_designer.yaml
agent_id: api_designer
role: Design and evolve public APIs
inputs:
  - requirements
  - openapi
outputs:
  - updated_openapi
constraints:
  - backward_compatible
rubric:
  - no_breaking_changes
  - version_comments_added
```

This allows:

*   multiple agents per task
*   hot‑swapping implementations
*   deterministic selection

***

## 2.3 Artifact

Artifacts are **immutable, content‑addressed outputs**.

```yaml
# artifacts/openapi.v3.1.yaml
artifact_id: sha256:9c2d...
type: openapi
produced_by:
  agent: api_designer
  task: T-042
content_ref: ./openapi.yaml
timestamp: 2026-04-10T11:12:00+09:30
```

Artifacts are append‑only; state progresses by reference.

***

## 2.4 Event (the backbone)

Everything that happens emits an **event**.

```yaml
# events/2026-04-10T01-42-12Z.agent_invoked.yaml
event_type: agent_invoked
timestamp: 2026-04-10T01:42:12Z
task_id: T-042
agent_id: api_designer
payload:
  context_hash: sha256:ab81...
```

Events are:

*   chronological
*   immutable
*   append‑only

***

# 3. File‑based protocol (baseline)

This version works *anywhere*: Git, shared folders, CI runners, laptops.

## 3.1 Directory layout

    /agents
      api_designer.yaml
      implementer.yaml
      reviewer.yaml

    /tasks
      T-042.yaml

    /artifacts
      openapi.yaml
      openapi@sha256-xxxx.yaml

    /events
      2026-04-10T01-42-12Z.agent_invoked.yaml
      2026-04-10T01-44-01Z.agent_completed.yaml

    /state
      current.yaml

***

## 3.2 Execution flow (file‑based)

### 1️⃣ Orchestrator emits intent

```yaml
event_type: task_ready
task_id: T-042
```

***

### 2️⃣ Orchestrator selects an agent

```yaml
event_type: agent_selected
task_id: T-042
agent_id: api_designer
```

***

### 3️⃣ Orchestrator materializes context

```yaml
event_type: context_prepared
task_id: T-042
agent_id: api_designer
payload:
  context_files:
    - requirements.md
    - openapi.yaml
```

***

### 4️⃣ Agent runner consumes context

This runner could be:

*   Copilot CLI
*   Claude Code
*   A local LLM
*   A script

It **only needs the files and agent spec**.

***

### 5️⃣ Agent produces output artifact

```yaml
event_type: agent_completed
task_id: T-042
agent_id: api_designer
payload:
  produced_artifacts:
    - artifact_id: sha256:9c2d...
```

***

### 6️⃣ Orchestrator evaluates

```yaml
event_type: evaluation_result
task_id: T-042
agent_id: api_designer
result: accepted
```

Or retry/escalate.

***

# 4. Event‑driven protocol (scalable variant)

The exact same schema—but events are **published**, not written.

## 4.1 Transport examples

*   File watcher
*   Message queue (Redis, Kafka, NATS)
*   Git commits
*   Webhooks
*   Local event bus

The protocol does **not care**.

***

## 4.2 Agent listener contract

An agent process subscribes to:

```text
event_type == agent_selected
AND agent_id == self
```

It then:

1.  Fetches context artifacts
2.  Runs the model
3.  Emits `agent_completed`

***

## 4.3 Orchestrator as a reducer

The orchestrator:

*   listens to all events
*   updates derived state
*   decides next transitions

This is conceptually **event sourcing**, not a chat loop.

***

# 5. Prompting becomes an implementation detail

Inside the agent runner:

    SYSTEM = agent.role + constraints
    INPUTS = context files
    TASK   = task.goal
    OUTPUT = declared outputs

You can change:

*   Copilot CLI → Claude → local LLM
*   without touching protocol files
*   without changing orchestration logic

***

# 6. Parallelism & safety (built in)

Because everything is immutable:

*   multiple agents can act on the same task
*   their outputs are compared
*   consensus or arbitration is explicit

Example:

    agent_completed (api_designer)
    agent_completed (api_reviewer)
    evaluation_result (quorum_passed)

No race conditions. No shared mutable memory.

***

# 7. Why this protocol works long‑term

| Property           | Why it matters          |
| ------------------ | ----------------------- |
| Append‑only events | Debuggable & replayable |
| Explicit artifacts | No hallucinated state   |
| Stateless agents   | Horizontal scaling      |
| Human‑readable     | Trust & governance      |
| CLI‑friendly       | Works today             |

***

# 8. Minimal mental model

> **Agents don’t talk to each other.  
> They talk through artifacts and events.**

This mirrors:

*   Unix pipes
*   CQRS / event sourcing
*   build systems
*   CI pipelines

Which is exactly why it works.

***

## Where to go next (if you want)

We can:

*   map this directly to **Copilot CLI invocation**
*   add **trusted vs untrusted agent tiers**
*   design **automatic rollback & diff‑based retries**
*   layer a **planner agent** on top of this protocol

Just say the word.

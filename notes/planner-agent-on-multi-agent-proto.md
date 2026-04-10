# Prompt

layer a planner agent on top of this protocol

# Answer

Excellent—layering a **planner agent** is where this protocol stops being a pipeline and becomes a **system**.

What follows is a **vendor‑neutral Planner‑as‑Control‑Plane design** that fits cleanly *on top* of the file/event protocol you already have, not beside it and not inside the LLM.

***

# Layering a Planner Agent on the Protocol

## 1. Core idea

> **The planner never does work.  
> It only decides *what work should exist*.**

That constraint is what keeps the system:

*   deterministic
*   auditable
*   non‑vendor‑locked

The planner:

*   **creates tasks**
*   **orders tasks**
*   **selects agent classes**
*   **responds to events**

It **never edits artifacts directly**.

***

## 2. Planner’s role in the system

Visually:

              ┌─────────────┐
              │   Planner   │
              └─────┬───────┘
                    │ emits
                    v
              ┌─────────────┐
              │    Tasks    │
              └─────┬───────┘
                    │ scheduled to
                    v
              ┌─────────────┐
              │   Agents    │
              └─────┬───────┘
                    │ produce
                    v
              ┌─────────────┐
              │  Artifacts  │
              └─────┬───────┘
                    │ observed by
                    └────────▶ Planner

The planner lives entirely in **event space**.

***

## 3. Planner Agent definition

A planner is just another agent **with special permissions**.

```yaml
# agents/planner.yaml
agent_id: planner
role: Plan and coordinate multi-step work
inputs:
  - high_level_goal
  - current_state
  - previous_events
outputs:
  - tasks
constraints:
  - must_not_modify_artifacts
  - must_emit_explicit_tasks
rubric:
  - tasks_are_ordered
  - tasks_have_clear_acceptance
```

Key restriction:

> **Planner output must be declarative, not imperative.**

***

## 4. Planner output schema

The planner does **not say “do X now”**.

It emits *task definitions*.

```yaml
# events/2026-04-10T02-01-00Z.planner_output.yaml
event_type: planner_proposed_tasks
timestamp: 2026-04-10T02:01:00Z
payload:
  tasks:
    - task_id: T-043
      goal: Update OpenAPI spec to support pagination
      suggested_agents:
        - api_designer
      inputs:
        - requirements.md
        - openapi.yaml
      acceptance_criteria:
        - Pagination added
        - No breaking changes

    - task_id: T-044
      goal: Implement pagination logic in service layer
      suggested_agents:
        - implementation_agent
      depends_on:
        - T-043
```

The orchestrator—not the planner—decides whether to accept this plan.

***

## 5. Planner invocation lifecycle

### Step 1: Triggering conditions

The orchestrator invokes the planner when:

*   A new high‑level goal arrives
*   A task fails repeatedly
*   State changes invalidate assumptions
*   A phase boundary is reached (design → implementation)

This is explicit:

```yaml
event_type: planner_requested
reason: new_goal
goal_ref: goals/G-012.yaml
```

***

### Step 2: Context given to the planner

The planner gets **summaries**, not raw artifacts.

```yaml
context:
  goal: Add pagination support
  state_summary:
    - openapi: exists
    - service_layer: no pagination
  recent_events:
    - agent_completed (api_designer)
    - evaluation_result (rejected)
```

This prevents:

*   token explosion
*   planner hallucinating detail
*   tight coupling to implementation

***

### Step 3: Planner emits proposed tasks

Planner runs once, statelessly, and emits a **single event**.

No loops.
No memory.

***

### Step 4: Orchestrator validates planner output

Before tasks are accepted, the orchestrator checks:

| Validation                  | Why             |
| --------------------------- | --------------- |
| Task IDs unique             | Determinism     |
| Dependencies resolvable     | DAG correctness |
| Agents exist                | Safety          |
| Acceptance criteria present | Verifiability   |

Only then are tasks written to `/tasks`.

***

## 6. Planner + event sourcing = replayable intelligence

Because the planner is pure input → output:

*   You can replay planning decisions
*   Swap planner models
*   Diff plans across models
*   Roll forward / backward

Example insight:

> “Claude generated 6 tasks; Copilot generated 4. Why?”

That’s impossible with chat‑based orchestration.

***

## 7. Hierarchical planning (optional, but powerful)

You can layer planners:

    Meta-Planner
       ↓
    Phase Planner (Design / Build / Validate)
       ↓
    Task-Level Planner

Each emits tasks at a **progressively finer granularity**.

They never share memory—only events.

***

## 8. Failure handling with a planner

### Scenario: implementation task fails validation

Events:

    agent_completed (implementer)
    evaluation_result (rejected)

Orchestrator invokes planner again:

```yaml
planner_requested:
  reason: task_failed
  failed_task: T-044
```

Planner might emit:

*   a refactor task
*   a spec clarification task
*   a reviewer task

This is **structured recovery**, not retries.

***

## 9. Why planner ≠ orchestrator

| Planner        | Orchestrator   |
| -------------- | -------------- |
| Decides *what* | Decides *when* |
| Stateless      | Stateful       |
| Declarative    | Operational    |
| LLM‑friendly   | Deterministic  |
| Replaceable    | Core system    |

Keeping this separation prevents the planner from becoming an un-debuggable god‑object.

***

## 10. Minimal mental model

> **Planner thinks.  
> Agents act.  
> Orchestrator enforces reality.**

If a planner hallucination slips through, it dies at validation.

***

## 11. Copilot / Claude mapping (without lock‑in)

*   Planner invocation → any LLM (Copilot CLI works fine)
*   Planner output → YAML files / events
*   No reliance on:
    *   “function calling”
    *   “sub‑agents”
    *   “teams”

Vendor swap = change one invocation point.

***

## 12. Final sanity rule

> **If the planner disappeared tomorrow,  
> you should still be able to execute every existing task.**

That rule keeps the system honest.

***

If you want next, I can:

*   show a **planner prompt template that produces reliably parsable plans**
*   add a **meta‑critic planner** that validates other planners
*   map this to a **GitOps workflow** (planner PRs plans, humans review)

Just tell me where to take it.

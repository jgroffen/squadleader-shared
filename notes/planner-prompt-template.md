# Prompt

Show a planner prompt template

# Answer

Below is a **battle‑tested, vendor‑neutral planner prompt template** designed to sit cleanly on top of the protocol we’ve been building.

This is **not chatty**, **not conversational**, and **not model‑specific**.  
It is designed to produce **structurally valid, auditable planning output** that an orchestrator can safely trust or reject.

***

# Planner Prompt Template (Vendor‑Neutral)

## 1. Design constraints this template enforces

This template intentionally:

✅ Prevents the planner from “doing work”  
✅ Forces declarative task creation  
✅ Produces machine‑parseable output  
✅ Avoids reliance on tool/function calling  
✅ Works with Copilot CLI, Claude, OpenAI, or local models

***

## 2. Top‑level structure

The prompt is divided into **five hard sections**:

1.  Planner role & guardrails
2.  Planning rules
3.  Inputs (context)
4.  Output contract (schema)
5.  Final instruction

This structure is deliberate—do not collapse it.

***

## 3. Planner Prompt Template

```text
SYSTEM
You are a PLANNER agent in a multi-agent software system.

Your responsibility is to DECOMPOSE GOALS into TASKS.
You MUST NOT perform implementation, design, or analysis work yourself.

You ONLY emit declarative task definitions.

If you violate these rules, your output will be rejected.


PLANNING RULES
- You must NOT modify, describe, or guess artifact contents.
- You must NOT suggest solutions, designs, or code.
- You must NOT assume undocumented state.
- You must create tasks that are:
  - independently executable
  - explicitly verifiable
  - ordered via dependencies
- Each task MUST include acceptance criteria.
- Tasks MUST reference existing agents only.
- If information is missing, create a clarification task instead of guessing.


INPUT: HIGH-LEVEL GOAL
{{goal_text}}


INPUT: CURRENT STATE SUMMARY
This is a lossy summary. Do not infer details beyond what is stated.

{{state_summary}}


INPUT: RECENT EVENTS (chronological)
{{recent_events}}


AVAILABLE AGENTS
{{agent_catalog}}


OUTPUT CONTRACT
Emit ONLY valid YAML matching this schema:

planner_proposed_tasks:
  tasks:
    - task_id: string
      goal: string
      suggested_agents: [string]
      inputs: [string]
      depends_on: [string]        # optional
      acceptance_criteria: [string]

Do NOT include explanatory text.
Do NOT include headings.
Do NOT include extra keys.


FINAL INSTRUCTION
Propose the MINIMUM set of tasks required to advance the goal.
Prefer smaller, verifiable tasks over large ones.
```

***

## 4. Example: Filled‑in prompt (realistic)

Here’s what the orchestrator actually sends to the LLM:

```text
SYSTEM
You are a PLANNER agent in a multi-agent software system.
...


INPUT: HIGH-LEVEL GOAL
Add pagination support to API list endpoints.


INPUT: CURRENT STATE SUMMARY
- public OpenAPI spec exists
- list endpoints do not specify pagination
- service implementation may require changes


INPUT: RECENT EVENTS (chronological)
- agent_completed(api_designer)
- evaluation_result(rejected): breaking change risk detected


AVAILABLE AGENTS
- api_designer
- implementation_agent
- reviewer_agent


OUTPUT CONTRACT
...
```

***

## 5. Example: Correct planner output

```yaml
planner_proposed_tasks:
  tasks:
    - task_id: T-101
      goal: Update OpenAPI specification to define pagination parameters for list endpoints
      suggested_agents:
        - api_designer
      inputs:
        - openapi.yaml
        - requirements.md
      acceptance_criteria:
        - Pagination parameters defined for all list endpoints
        - No breaking changes to existing contracts

    - task_id: T-102
      goal: Implement pagination handling in service layer
      suggested_agents:
        - implementation_agent
      inputs:
        - service_code
        - openapi.yaml
      depends_on:
        - T-101
      acceptance_criteria:
        - Pagination logic implemented
        - Existing tests pass

    - task_id: T-103
      goal: Review API and implementation changes for correctness and compatibility
      suggested_agents:
        - reviewer_agent
      inputs:
        - openapi.yaml
        - service_code
      depends_on:
        - T-102
      acceptance_criteria:
        - No breaking changes identified
        - Pagination behavior verified
```

✅ No designs  
✅ No code  
✅ No assumptions  
✅ Fully orchestratable

***

## 6. Why this template works (and most don’t)

### It treats planning as a **pure function**

Same inputs → same plan → replayable

### It prevents planner drift

By removing *any* permission to solve problems

### It converts intelligence into **infrastructure**

The planner becomes a replaceable component, not a god‑agent

***

## 7. Hard guardrail (important)

> **If your planner output would be useless without an LLM later, it’s wrong.**

A correct plan should:

*   be readable by a human
*   be executable by scripts
*   survive model replacement

This template enforces that.

***

## 8. Optional upgrades (later)

Once this works, you can add:

*   a **planner‑critic** agent that validates plans
*   a **cost‑aware planner** (token/compute budgets)
*   a **phase‑based planner** (design → build → verify)
*   a **human‑approval gate** (GitOps‑style)

All without changing the core template.

***

If you want next, I can:

*   harden this prompt further for Copilot CLI quirks
*   design a planner‑critic prompt
*   show how to version planner prompts safely

Just say the word.

# Prompt

How to version planner prompts?

# Answer

Versioning planner prompts is **not a prompt‑engineering problem**—it’s a **control‑plane and governance problem**. If you treat planner prompts like ad‑hoc text, your system will silently drift, become non‑replayable, and lose trust.

Below is a **practical, production‑grade approach** that keeps planners auditable, replaceable, and safe—without coupling you to any LLM vendor.

***

# How to Version Planner Prompts (Correctly)

## 1. First principle

> **A planner prompt is executable policy.  
> Therefore it must be versioned like code, not like config.**

That means:

*   semantic versioning
*   immutability
*   provenance
*   replayability

***

## 2. What exactly gets versioned

You do **not** version “the prompt blob” alone.

You version **four distinct things**:

| Component           | Why                 |
| ------------------- | ------------------- |
| Prompt template     | Behavioral contract |
| Output schema       | Safety boundary     |
| Planning rules      | Guardrails          |
| Invocation metadata | Reproducibility     |

These must move together.

***

## 3. Canonical directory structure

    /planners
      /task-planner
        /v1.0.0
          planner.yaml
          prompt.txt
          schema.yaml
          changelog.md

        /v1.1.0
          planner.yaml
          prompt.txt
          schema.yaml
          changelog.md

        /v2.0.0
          planner.yaml
          prompt.txt
          schema.yaml
          changelog.md

**Immutable versions.**
No edits after release.

***

## 4. Planner metadata (`planner.yaml`)

This is the control surface.

```yaml
planner_id: task-planner
version: 1.1.0

intent: Decompose high-level goals into ordered, verifiable tasks

compatibility:
  supports_protocol: ">=1.0"
  compatible_agents:
    - api_designer
    - implementation_agent
    - reviewer_agent

breaking_changes:
  - v2.0.0 tightened acceptance criteria requirements
```

Why this matters:

*   orchestrator can refuse incompatible planners
*   humans can reason about upgrades
*   rollback is trivial

***

## 5. Prompt file (`prompt.txt`)

This is **pure text**, no logic, no comments that change meaning.

Key rule:

> **Prompt files are write‑once.  
> Changing behavior = new version.**

Never “tweak” a prompt in place.

***

## 6. Output schema (`schema.yaml`)

This is non‑negotiable and enforced by the orchestrator.

```yaml
planner_proposed_tasks:
  type: object
  required: [tasks]
  properties:
    tasks:
      type: array
      items:
        type: object
        required:
          - task_id
          - goal
          - suggested_agents
          - acceptance_criteria
```

**Why separate this?**

*   Schema changes are usually breaking
*   Schema validation is how you reject hallucinations

***

## 7. Semantic versioning rules

Treat planner versions like APIs.

### ✅ PATCH (1.0.1)

*   Clarifies wording only
*   No output shape change
*   No behavior expansion

### ✅ MINOR (1.1.0)

*   Adds optional constraints
*   Improves plan quality
*   Same schema

### ❌ MAJOR (2.0.0)

*   New schema fields
*   Stronger constraints
*   Different task granularity

**If the orchestrator logic must change → MAJOR.**

***

## 8. Recording planner version in events (critical)

Every planner invocation must emit:

```yaml
event_type: planner_invoked
planner_id: task-planner
planner_version: 1.1.0
prompt_hash: sha256:94ab...
```

Why this matters:

*   you can replay plans exactly
*   you can diff outcomes across versions
*   you can answer “why did this plan exist?”

Without this, versioning is a lie.

***

## 9. Replay & regression testing

Before promoting a new planner version:

1.  Select historical goals
2.  Re‑run planner v(old) and v(new)
3.  Diff:
    *   number of tasks
    *   dependencies
    *   acceptance criteria clarity

If differences are unexpected → reject.

This is **planner CI**.

***

## 10. Safe rollout strategy

### Never “flip” planner versions globally.

Instead:

```yaml
planner_policy:
  default: task-planner@1.1.0
  experiments:
    - planner: task-planner@1.2.0
      scope: non_production
```

Optional:

*   per‑repo
*   per‑team
*   per‑risk‑tier

***

## 11. Lock‑step upgrades with protocol

If you ever change:

*   event structure
*   task schema
*   orchestration rules

You **must** bump:

*   planner MAJOR version
*   protocol version

This is how you avoid silent corruption.

***

## 12. Human‑readable changelog (mandatory)

`changelog.md` example:

```markdown
## v1.1.0
- Improved task dependency ordering
- Reduced over-generation of reviewer tasks

## v2.0.0
- Introduced mandatory acceptance criteria
- Planner now emits clarification tasks explicitly
```

This is not optional.  
LLMs drift; humans forget.

***

## 13. The golden rule

> **If you cannot deterministically reproduce a plan six months later,
> you do not have a versioned planner.**

Good versioning makes planners:

*   debuggable
*   replaceable
*   governable
*   trustworthy

***

## 14. What *not* to do (hard‑won lessons)

❌ Embed schemas inside prompts  
❌ Hot‑patch prompts in prod  
❌ Version by date only  
❌ Rely on model version names  
❌ Let planners edit themselves

***

## 15. Mental model to keep

> **Planner versions are laws.  
> Agents are workers.  
> The orchestrator is the constitution.**

Once you adopt that framing, versioning becomes obvious.

***

If you want next, I can:

*   design **planner regression test cases**
*   show **GitOps workflows for planner promotion**
*   add **canary planning with automatic rollback**
*   or design a **planner‑critic versioning strategy**

Just say where to go.

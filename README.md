# SquadLeader Shared

**SquadLeader Shared** is the shared library for a multi‑agent ecosystem.
It provides a unified collection of reusable **skills**, **templates**, **schemas**, and **utility modules** that are shared across:

- **squadleader** — the orchestrator agent and developer-facing tools  
- **squadleader-mcp** — the suite of MCP servers and tool implementations  
- **downstream projects** — any project that includes the orchestrator as a submodule

This repository centralizes all cross‑cutting logic so that agents, MCPs, and development workflows can rely on a single, consistent source of truth.  
It keeps shared capabilities versioned, maintainable, and easy to consume across your entire agentic toolkit.

---

## ✨ Features

- **Shared Skills**  
  Reusable agent skills that can be consumed by orchestrators, MCP servers, and development tools.

- **Shared Templates**  
  Prompt templates, response formats, and reusable text structures.

- **Shared Schemas**  
  JSON schemas, type definitions, and structured interfaces used across agents and MCP tools.

- **Shared Utilities**  
  Common helper modules (logging, config, parsing, validation, etc.) used by both orchestration and MCP layers.

---

## 🧱 Repository Structure

Each folder is intentionally lightweight and framework‑agnostic so it can be imported cleanly by:

- Orchestrator and agents in **squadleader**
- MCP servers in **squadleader-mcp**
- Any downstream project that includes the orchestrator as a submodule

---

## 🔗 How It Fits Into the Ecosystem

`squadleader-shared` is designed to be included as a **git submodule** in both:

- `squadleader`
- `squadleader-mcp`

This ensures a single source of truth for shared logic while keeping the architecture modular and maintainable.

### Multi‑Repo SquadLeader Architecture

```
                 ┌──────────────────────────────┐
                 │      squadleader-shared      │
                 │  (skills, templates, utils)  │
                 └──────────────┬───────────────┘
                                │
                ┌───────────────┼────────────────┐
                │                                │
                ▼                                ▼
   ┌──────────────────────────┐    ┌──────────────────────────┐
   │        squadleader       │    │     squadleader-mcp      │
   │  (orchestrator agents,   │    │  (MCP servers + tools)   │
   │   orchestration skills)  │    │                          │
   └────────────┬─────┬───────┘    └─────────────┬────────────┘
                │     │    references            │
                │     └──locally running───┐     │
                │         MCP services     │     │
                ▼                          ▼     ▼
      ┌───────────────────┐          ┌──────────────────────┐
      │  Downstream       │          │   MCP Runtime /      │
      │  Projects         │          │   Copilot CLI        │
      │  (include         │          │   loads MCP servers  │
      │   orchestrator)   │          │   and orchestrator   │
      └───────────────────┘          └──────────────────────┘
```

---

## 📄 License

MIT

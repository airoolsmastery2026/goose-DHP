# DHP Goose Desktop Agent

DHP Goose is a local-first custom distribution layer on top of Goose. It keeps Goose core upstream-compatible and adds a DHP operating layer: UMS orchestration, curated skills, MCP/tool policy, memory rules, quality gates, and a Windows one-click launcher.

## Design goals

- Local-first and usable without paid APIs.
- Ollama is the default provider; paid providers are never enabled automatically.
- Goose core remains replaceable/upgradable; DHP behavior lives in recipes, skills, config, and launch scripts.
- Tools are loaded on demand. Do not expose every MCP tool to every task.
- Corrections become lessons/memory; do not fine-tune model weights automatically.
- Every non-trivial task follows: understand -> plan -> execute -> verify -> critique -> retry -> report.

## Runtime layers

1. **Desktop shell** — Goose Desktop when installed, CLI fallback otherwise.
2. **UMS** — routes intent, selects skills/tools, plans work, verifies completion.
3. **Skills** — universal engineering/research skills plus DHP domain skills.
4. **MCP/tools** — Developer, Memory, Skills, Todo, Summon and approved custom MCP servers.
5. **Memory** — local corrections, preferences, project lessons, reusable workflows.
6. **Provider policy** — Ollama first, verified-free cloud optional, paid disabled by default.
7. **Quality loop** — plan, execute, verify, critique, retry, save lesson.

## Windows quick start

From a cloned repository, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\distributions\dhp-goose\windows\install-dhp-goose.ps1
```

The installer creates a `DHP Goose` desktop shortcut. The shortcut runs `start-dhp-goose.ps1`, checks Ollama and Goose, sets the local provider/model policy, and opens Goose.

Default local model: `qwen3:1.7b`. This is intentionally a bootstrap/offline model for low-resource PCs. Change `DHP_GOOSE_MODEL` later when a stronger verified model is available for the machine.

## Important directories

- `ums/UMS.md` — orchestration contract.
- `skills/` — curated SKILL.md packs.
- `recipes/dhp-employee.yaml` — default employee-mode recipe.
- `mcp/registry.yaml` — approved tool policy.
- `windows/` — installer, launcher, and health check.

## Definition of Done

DHP Goose v1 is considered operational when:

- a desktop icon starts the system without manual PowerShell commands;
- Ollama and Goose are health-checked before launch;
- local provider/model settings are injected without API keys;
- UMS routes work through only relevant skills/tools;
- Developer/Memory/Skills/Todo/Summon are available through the default recipe;
- results are verified before completion;
- corrections can be saved as reusable lessons;
- no paid provider can be silently enabled;
- the distribution can be updated independently of Goose core.

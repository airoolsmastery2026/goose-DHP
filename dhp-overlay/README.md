# DHP Goose Overlay

This directory contains Dai Hai Phat-specific distribution policy and integration contracts for the `goose-DHP` fork.

## Boundary

The upstream Goose source remains the execution runtime. DHP-specific behavior should stay in this overlay, configuration, recipes, MCP registration, packaging, or adapters whenever possible.

Authority order:

```text
DHP-AIOS / project contracts
        -> UMS routing and workflow policy
        -> Zero-$ execution policy
        -> Goose execution runtime
        -> local providers / MCP tools
```

Goose does not become the DHP system of record, business orchestrator, pricing authority, CRM owner, or cost-policy authority.

## Supported deployment modes

1. **DHP Goose Desktop** — a standalone Windows desktop application installed with `DHP-Goose-Setup.exe`.
2. **DHP local execution node** — Desktop/CLI exposes authenticated loopback ACP for a DHP client or local gateway.

Both modes share one Goose runtime and the same Zero-$ policy. They are not separate products or codebases.

## Zero-dollar invariant

The default DHP distribution is fail-closed for cost:

- paid API auto-use is disabled;
- automatic top-up and metered fallback are disabled;
- local inference is preferred for durable continuity;
- an optional cloud route is allowed only when an external policy layer can prove it is currently zero-cost;
- loss of every verified zero-cost route stops model execution instead of spending money.

See `policy/zero-dollar-policy.json`.

## Upstream sync rule

Keep `main` suitable for upstream synchronization. DHP changes belong on DHP branches and should minimize edits to upstream core code. Core changes require a demonstrated capability gap and explicit tests.
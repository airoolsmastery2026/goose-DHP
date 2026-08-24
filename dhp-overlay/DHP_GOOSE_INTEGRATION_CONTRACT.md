# DHP Goose Integration Contract

## Purpose

`goose-DHP` is an execution runtime for Dai Hai Phat. It supports a standalone Windows desktop experience and an optional local execution-node mode for DHP-AIOS without replacing the Website, UMS, or Zero-$ policy layers.

## Architecture

```text
DHP Website / DHP Desktop
          |
          v
         UMS
          |
          v
     Zero-$ Gate
          |
          v
      goose-DHP
       /     \
 local model  MCP tools
```

For web/mobile use, the preferred future boundary is:

```text
DHP client -> authenticated DHP local gateway -> ACP -> goose-DHP
```

The public Website must never depend on the local node being online.

## Authority and ownership

- DHP Website remains the business brain and source of truth for customer, pricing, quotation, CRM, and knowledge records.
- UMS remains workflow/router authority.
- Zero-$ policy decides whether a provider/model route is eligible.
- Goose executes approved tasks and tools.
- Goose memory, recipes, skills, or local files must not silently become canonical DHP business storage.

## Zero-$ hard lock

The DHP distribution must default to `absolute_zero=true`.

Disallowed by default:

- paid API fallback;
- automatic credit purchase or top-up;
- metered provider fallback;
- injecting paid API credentials into a DHP zero-dollar process;
- silently switching to a provider whose zero-cost status cannot be proven.

Preferred continuity order is capability-driven, not brand-driven:

1. reuse an already installed compatible local runtime;
2. use a lightweight local runtime/model profile that fits detected hardware;
3. optionally use a currently verified official zero-cost route when the operator enables it;
4. stop model execution if no eligible zero-cost route remains.

No model is downloaded automatically merely because a larger model might be better. Runtime/model installation requires an explicit installation action and disk/RAM suitability check.

## Local runtime discovery

Initial adapters:

- Ollama-compatible loopback endpoint;
- llama.cpp/OpenAI-compatible loopback endpoint;
- compatible pre-existing local OpenAI endpoint such as Jan when explicitly configured.

Discovery must prefer reuse over installation. Only loopback/local endpoints are eligible for automatic local discovery.

## ACP security

`goose serve` or any ACP HTTP/WebSocket mode used by DHP must:

- bind to loopback by default;
- require a non-empty secret key;
- restrict allowed browser origins to explicitly configured DHP origins;
- never expose a shell-capable unauthenticated endpoint to the public Internet;
- keep runtime secrets outside source control;
- request approval for high-impact filesystem, shell, deployment, secret, or destructive operations.

ACP stdio is preferred for same-machine embedding when practical.

## Permission defaults

Suggested baseline:

- conversation/read-only research: `smart_approve`;
- isolated development workspace: `smart_approve` with bounded filesystem scope;
- repository writes, deployment, credentials, and production actions: `approve`;
- destructive or privilege-changing operations: deny unless a separate explicit policy grants them.

## Desktop distribution

The DHP Windows build is opt-in through `DHP_DESKTOP_BUILD=1`. Normal upstream-compatible Goose packaging remains unchanged when the variable is absent.

DHP packaging target:

```text
DHP-Goose-Setup.exe
```

Unsigned builds are acceptable for private/testing use and preserve the $0 software budget; Windows SmartScreen warnings are an expected trade-off until an optional signing process is deliberately funded.

## Telemetry

DHP launch profiles should set `GOOSE_DISABLE_TELEMETRY=1` by default. Telemetry may only be enabled by an explicit distribution decision.

## Acceptance criteria

- no paid route is enabled by the DHP overlay;
- upstream Goose behavior remains unchanged when DHP build flags are absent;
- Windows installer can be built from the fork without adding a new package dependency;
- Website remains functional when Goose Desktop is absent/offline;
- local ACP is authenticated and loopback-first;
- DHP business records remain Website-owned;
- upstream sync remains practical.
# DHP Digital Studio Skill

Use for DHP website/product UI, content systems, automation, and AI video production workflows.

## Website mode

- Preserve the existing framework and project architecture.
- Work mobile-first, performance-first, accessible, and SEO-aware.
- Reuse design tokens/components before adding new abstractions.
- Keep one component focused on one responsibility and avoid duplicate UI.
- Validate loading, empty, error, responsive, dark-mode, and keyboard states where relevant.
- Never redesign randomly when the task is a targeted fix.

## Video mode

Maintain a production pipeline rather than treating generation as isolated prompts:
Brief -> Script -> Bibles -> Storyboard -> Generation -> Edit -> Final.

Continuity is a gate. Track scene/take identity, visual style, material/color/camera constraints, selected takes, and QC status. Do not silently change canonical project facts between scenes.

## Automation mode

For multi-step generation, persist checkpoints before expensive work. Prefer resumable jobs, bounded parallelism, deterministic file naming, and explicit failure/retry state.

## Completion gate

Digital work is complete only after the requested output is observable and its critical states/continuity rules have been checked, not merely generated.

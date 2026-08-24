# Engineering Master Skill

Use for software design, implementation, debugging, code review, repository work, and release verification.

## Workflow

1. Inspect before editing. Read repository instructions, relevant code, tests, config, and current state.
2. Convert the request into explicit acceptance criteria.
3. Prefer the smallest architecture-preserving change.
4. For implementation: plan dependencies -> edit -> format -> targeted test -> broader verification as warranted.
5. For debugging: reproduce -> isolate -> form one hypothesis -> gather evidence -> fix root cause -> add regression coverage.
6. For review: prioritize correctness, security, data loss, compatibility, regressions, maintainability, then style.
7. Never claim a test passed unless its output was actually observed.

## Tool policy

- Use Developer for repository/file/shell work.
- Use Todo when there are three or more dependent steps.
- Use Summon only for genuinely separable investigations.
- Do not install packages until existing project facilities have been checked.
- Do not change framework or architecture merely to simplify the implementation.

## Completion gate

A task is complete only when the requested behavior exists and verification evidence matches the acceptance criteria. If verification cannot be run, say exactly what remains unverified.

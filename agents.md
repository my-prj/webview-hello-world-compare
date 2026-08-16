# Agent Instructions

## Version-control permissions

- Create or amend a commit only when the user explicitly asks for it or grants explicit permission.
- Push only when the user explicitly asks for it or grants separate explicit permission in addition to permission to commit.
- Agent-created commits: exactly one co-author trailer — the model you run as and this agent's email. Turn off Cursor **Attribution** (Settings → Agent) so the IDE does not inject a second one.

## Reproducibility and repository contents

- Keep all source code, configuration, build definitions, workflow files, and documentation required to reproduce an experiment in Git.
- The Git repository must contain sufficient information to reproduce every experiment deterministically and obtain the same results from a clean checkout.
- Do not keep required knowledge only in a local environment or in undocumented manual steps.
- Store all build outputs, downloaded dependencies, generated components, targets, toolchains, compilers, caches, test data, and other reconstructible files under `temp/`.
- Do not create project working files outside this repository. Use `temp/` for temporary or generated materials so that the development machine remains clean.
- Treat `temp/` as disposable. Its complete removal must never prevent reproduction because everything in it must be recoverable unambiguously from the tracked project files.

## Comparing WebView integrations

- Keep every WebView approach independent and explicitly separated in both tracked code and `temp/`.
- Use a stable per-implementation identifier consistently in directory names, build scripts, GitHub Actions artifacts, and documentation.
- Do not share implementation-specific files, caches, dependencies, or build outputs between approaches unless the shared input is explicitly versioned and documented.
- Preserve the ability to build, move, modify, and compare each implementation independently.

## Experience log

- Record practical experience with every evaluated tool in tracked documentation.
- Capture setup friction, build and runtime issues, non-obvious dependencies, workarounds, and noteworthy trade-offs.
- Record enough context for future readers to judge which tool is suitable in general and for specific scenarios.

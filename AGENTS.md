# AI Agent Guidelines

## Overview

This is a NixOS configuration repository built on modern, bleeding-edge practices.

## Version Control System (VCS)

This repository is **Jujutsu (jj) first**, it is colocated with git.

- **Jujutsu Only**: Do not use `git` commands in favor of `jj`. Always use `jj --no-pager` for commands that produce output.
- **Conventional Commits**: Always format your commit messages using the Conventional Commits specification. (`feat: ...`, `fix: ...`, `chore: ...`, ...). Keep commit messages concise and clear, they're lowercase (aside from eg. acronyms, ...) and don't have a period at the end.
- **Atomic Commits**: Keep commits focused on a single logical change. Describe the change before coding (`jj desc -m "..."`).

## Environment

- **Nix Flakes**: Prefer modern Nix Flake commands (`nix build`, `nix flake check`, `nix run`, ...) over legacy commands.
- **Direnv**: The workspace uses `direnv`. If you modify the flake devShell, make sure to reload the environment using `direnv allow`.

## Adding Flake Inputs

When adding or modifying flake inputs in `flake.nix`, strictly follow these rules to maintain a lean, deduped lockfile:

1. **Ordering by Significance**:
   - Inputs must be ordered inversely by significance: **least significant/most volatile** inputs (e.g., apps, git-hooks) go at the TOP. **Most fundamental/stable** inputs (e.g., `flake-parts`, `nixpkgs`) go at the BOTTOM.
   - This exact same ordering applies to the `.follows` declarations inside each block.

2. **Discovering Real Dependencies**:
   - NEVER guess or hallucinate a flake's dependencies!
   - You MUST run `nix flake metadata <flake-url>` and read the `Inputs:` section at the bottom of the output to discover its true dependencies. Do not use `nix flake show` for this, as it evaluates outputs, not inputs.

3. **Shared vs Non-Shared Dependencies**:
   - **Shared (Deduplicate & Pin)**: If a dependency (like `flake-compat` or `nixpkgs`) is used by _multiple_ flakes in our config, or if the user explicitly added it to the top-level inputs, you must add it to the top-level `inputs` block and use `inputs.<name>.follows = "<shared-name>";` inside the consuming flakes to pin them to the exact same version.
   - **Non-Shared (Comment Out)**: If a dependency is ONLY used by the flake you are currently adding, do NOT pollute the top-level config with it! Instead, write the follows syntax inside the block but **comment it out** so we have a documented record of it (e.g., `# inputs.non-shared-dep.follows = "non-shared-dep";`).

## Agent Checklist

Before finishing a task, verify:

1. Change is scoped strictly to the requested behavior.
2. `nix fmt` was run to ensure consistent code styling.
3. `nix flake check` passes successfully, validating code hygiene.
4. `jj st` shows a clean, tracked state with a properly formatted commit message.
5. User-facing summary includes exactly what changed and what was validated.

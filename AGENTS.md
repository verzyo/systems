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

## Agent Checklist

Before finishing a task, verify:

1. Change is scoped strictly to the requested behavior.
2. `nix fmt` was run to ensure consistent code styling.
3. `nix flake check` passes successfully, validating code hygiene.
4. `jj st` shows a clean, tracked state with a properly formatted commit message.
5. User-facing summary includes exactly what changed and what was validated.

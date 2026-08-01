# Personal preferences

User-level guidance for Quentin Kniep.
Applies to every project; a repo's own CLAUDE.md always wins on conflicts.

## Communication
- Concise and direct; lead with the answer, skip preamble and flattery.
- When uncertain, say so and ask — don't guess at ambiguous scope.
- State tradeoffs briefly instead of hedging every sentence.

## Tools
- Prefer `rg` over grep, `fd` over find, `eza` over ls, `bat` over cat.
- When a needed CLI tool is not installed,
  use `nix-shell -p <pkg> --run '<command>'` to run it ephemerally.

## Code
- Match the surrounding code's style, naming, and idioms.
- Keep diffs minimal; every changed line should trace to the request.
- Remove only the orphans your change created — don't delete pre-existing
  dead code unless asked.
- Indent with spaces unless a project's config (editorconfig, etc.) says otherwise.

## Questioning the existing design
- Moving towards a better design is better than conforming to an existing bad one.
- Existing code is evidence of what someone once believed, not proof it was right or is still right.
- If you'd have designed it differently, say so in a sentence or two — even when you follow the existing pattern anyway.
  Silence reads as endorsement.
- Criticize in prose, change in scope: do the task as asked,
  flag the design concern separately, let me decide whether to widen the work.
- Be concrete about the alternative and its merits and costs.

## Execution
- Turn tasks into verifiable goals:
  "fix the bug" → "write a failing test that reproduces it, then make it pass."
- For multi-step work, state a short plan with a check per step, then loop until verified.

## Rust (my primary language)
- Test with `cargo nextest run`; keep `cargo clippy` warning-clean.
- Propagate fallible errors with `?`; use `expect()` (over `unwrap()`) for
  genuine invariants, where the message documents why it can't fail.

## Git
- Don't commit, push, or open PRs unless I ask.

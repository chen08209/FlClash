# code_forge

The code editor behind FlClash's profile, script and config editors
(`lib/pages/editor.dart`). It is derived from
[code_forge](https://github.com/heckmon/code_forge) 10.14.0 by Athul A S, through
the `chen08209/code_forge` fork, and keeps upstream's MIT license (see `LICENSE`).
FlClash is its only user, so it is trimmed to what FlClash uses rather than kept
in step with upstream.

## What changed from upstream

- The Rust backend (rope buffer, fold ranges, bracket matching, indent guides,
  completion words) is the `editor/` module of `plugins/rust_api`, loaded through
  the app's single `RustLib`; this package has no native build of its own.
- Vertical layout goes through one row-based `ViewLineLayout` (prefix sums over
  per-line row counts, folded lines take no rows), so scrolling and jumping stay
  logarithmic in large documents.
- Removed: the language server client (hover, diagnostics, semantic tokens, code
  actions, signature help, snippets), AI completion and ghost text, git diff and
  line/gutter decorations, document colors and the color picker, inlay hints,
  occurrence highlights, right-to-left layout, multiple cursors, and the
  built-in context menu, suggestion popup and scrollbar with the options that
  styled them.
- Added for FlClash: `suggestionPopupBuilder`, `onContextMenu` and
  `scrollbarBuilder` hooks, platform keyboard shortcuts
  (`CodeForgeKeyboardShortcuts.forPlatform`), whole-line copy and cut with no
  selection, line selection from the gutter, and Material from `material_ui`.

Regression tests live in `test/plugins/code_forge/` at the repository root.

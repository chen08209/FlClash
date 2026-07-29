---
name: provider-tests
description: Use when adding or updating FlClash Riverpod provider tests, notifier tests, or state-management tests in this repository.
---

# Provider Tests

## When To Use

Use this for tests under `test/providers/` or any change that validates Riverpod providers, generated notifiers, app state defaults, or provider interactions.

For broader test expansion, pair this with `.agents/rules.md` and `.agents/commands.md`.

## Workflow

1. Read the provider under test and its generated public API before writing assertions.
2. Use `ProviderContainer` directly when no widget tree is needed.
3. Dispose containers in teardown or with `addTearDown(container.dispose)`.
4. Prefer generated notifier APIs over implementation details. Generated `update()` takes a callback:

   ```dart
   notifier.update((state) => newValue);
   ```

5. Mock external dependencies with `mocktail`; register fallback values for freezed params used with `any()`.
6. Keep tests focused on behavior: defaults, state transitions, persistence boundaries, and side effects.
7. Run the narrowest relevant test first:

   ```bash
   flutter test test/providers/
   ```

## Pitfalls

- Do not use `dart test`; FlClash models and provider tests may depend on Flutter types.
- Re-check source defaults before asserting them; provider defaults can drift.
- If async provider timing matters, wait on provider futures or state changes instead of fixed sleeps.

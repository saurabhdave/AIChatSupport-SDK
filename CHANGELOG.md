# Changelog

All notable changes to AIChatSupport are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Breaking

- **`AIChatDelegate` now refines `Sendable`** (and remains `@MainActor`-isolated). Delegate
  conformers must therefore be main-actor isolated — annotate them with `@MainActor`:

  ```swift
  @MainActor
  final class MyChatDelegate: AIChatDelegate { /* ... */ }
  ```

  This removes the `nonisolated(unsafe)` escape hatch previously used for
  `AIChatConfiguration.delegate`.

### Changed

- The Anthropic provider's default model is now `claude-opus-4-8` (was `claude-opus-4-5`).
- The message composer uses a vertical-axis `TextField`: a hardware-keyboard Return sends,
  and Shift+Return inserts a newline (the previous `TextEditor.onSubmit` never fired).

### Added

- `AIChatTheme` now honors `headingFontWeight`, `bodyFontWeight`, and `usesDynamicType`.
  These were declared on `HostAppTheme` but previously never applied.

### Fixed

- Provider requests no longer include the empty assistant placeholder or leading welcome
  messages; the first message sent is always a user turn. This fixes 400-level errors from
  providers (notably Anthropic) that require a non-empty, user-first message list.
- In-flight requests are now cancelled when a new message is sent, the conversation is
  cleared, or the chat view is dismissed.
- The context-length-exceeded path now trims older turns and retries exactly once instead
  of potentially re-trimming.
- The error banner's **Retry** button now retries the failed message instead of only
  dismissing the banner.
- The message list stays pinned to the bottom while a response streams in.
- The date header reflects the first message's timestamp rather than always showing "Today".
- The system-prompt identity line keeps the company name even when the app name is empty.

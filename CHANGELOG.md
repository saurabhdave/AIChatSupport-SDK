# Changelog

All notable changes to AIChatSupport are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Configure from JSON.** New `AIChatConfigurationFile` loads everything except the provider/delegate
  from a JSON file (`init(data:)` / `init(contentsOf:)` / `init(resource:bundle:)` →
  `makeConfiguration(provider:delegate:)`). Pure-data config types are now `Codable` (`AppContext`,
  `FAQ`, `UserInfo`, `TonePersonality`, `AvatarStyle`, `PresentationStyle`, `WelcomeMessage`,
  `CornerRadiusStyle`), brand tokens use hex colors via a new `Color(hex:)`, and decoding is lenient
  (omitted fields use defaults).

### Fixed

- The modal close (✕) button now dismisses the presented chat (sheet or fullscreen cover). It
  previously only invoked the `chatDidDismiss` delegate callback without actually dismissing.
- The chat now renders in its theme's color scheme instead of inheriting the device's, so themes
  that mix fixed brand colors with system colors stay readable. Previously a light brand theme on
  a device in Dark Mode produced unreadable bubbles (e.g. white text on a light surface).

### Added

- `AIChatTheme.colorScheme` pins how system colors resolve. The light/minimal presets use `.light`
  and the dark preset uses `.dark`; `HostAppTheme.prefersDarkMode` overrides it.

## [1.0.0] - 2026-06-01

Initial public release.

### Added

- **AI providers** with SSE token streaming: OpenAI (`OpenAIConfig`), Anthropic
  (`AnthropicConfig`, default model `claude-opus-4-8`), a `.custom` provider conforming to
  `AIProviderProtocol`, and a deterministic `.mock` provider for development and tests.
- **App knowledge → system prompt:** `AppContext` compiles product identity, domain
  knowledge, behavioral rules, an FAQ knowledge base, and per-user context into a structured
  system prompt.
- **Theming:** `AIChatTheme` with `.light` / `.dark` / `.minimal` presets and a `.custom`
  builder, plus `HostAppTheme` for mapping a host app's brand tokens (colors, corner-radius
  style, font family, heading/body font weights, Dynamic Type) onto the chat UI.
- **Presentation & launchers:** `.sheet`, `.fullScreen`, and `.inline` styles via the
  `aiChatSupport(isPresented:configuration:)`, `aiChatFloatingButton(configuration:)`, and
  `aiChatInline(configuration:)` view modifiers; `AIChatSupport.makeView` / `quickStart`
  entry points.
- **Chat experience:** streaming responses with a typing indicator, staggered welcome
  messages, suggested-prompt chips, thumbs up/down feedback, per-message retry, a dismissible
  error banner, haptics, message timestamps, and accessibility labels throughout.
- **Lifecycle:** `AIChatDelegate` callbacks for sent message, received response, error, and
  dismissal.

### Notes

- `AIChatDelegate` is `@MainActor`-isolated and refines `Sendable`. Conforming types must be
  main-actor isolated — annotate them with `@MainActor`:

  ```swift
  @MainActor
  final class MyChatDelegate: AIChatDelegate { /* ... */ }
  ```

- **Security:** the `.openAI` and `.anthropic` providers call the vendor API directly from
  the device, so any embedded key is extractable. Use them for prototyping; in production
  route requests through your own backend via a `.custom` provider. See the README.

[Unreleased]: https://github.com/saurabhdave/AIChatSupport-SDK/compare/1.0.0...HEAD
[1.0.0]: https://github.com/saurabhdave/AIChatSupport-SDK/releases/tag/1.0.0

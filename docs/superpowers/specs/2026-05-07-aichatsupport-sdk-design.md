---
name: AIChatSupport SDK Design
description: Architecture and design spec for the AIChatSupport SwiftUI iOS SDK
type: project
---

# AIChatSupport SDK Design

**Date:** 2026-05-07  
**Target:** iOS 26+, Swift 6, zero third-party dependencies  
**Status:** Implemented

---

## Context

The AIChatSupport SDK lets any iOS 26+ app embed a production-quality AI chat support interface with a single `.aiChatFloatingButton()` or `.aiChatSupport()` modifier call. It handles OpenAI and Anthropic streaming out of the box, adapts visually to the host app's brand, and injects deep product knowledge into every conversation through the `AppContext` system.

---

## Architecture

Three layers with one-way dependencies:

```
Public API  →  ViewModel  →  Service
   (View)     (Observable)  (Providers)
```

**Public API Layer** (`AIChatSupport.swift`, `View+Extensions.swift`): Facades, View modifiers, configuration types.

**ViewModel Layer** (`ChatViewModel.swift`): `@MainActor @Observable` class owns all UI state. Drives streaming via `async/await`, manages welcome message delivery, context trimming, and delegate callbacks.

**Service Layer** (`AIProviderProtocol`, `OpenAIProvider`, `AnthropicProvider`, `MockAIProvider`): `Sendable final class` implementations. Each conforms to `AIProviderProtocol` and returns `AsyncThrowingStream<String, any Error>`. Uses typed throws (`throws(AIProviderError)`) per Swift 6.

---

## Key Design Decisions

### AppContext System Prompt Injection
`AppContext.buildSystemPromptBlock()` compiles product identity, FAQ knowledge base, behavioral rules, and current user info into a structured `[PRODUCT CONTEXT]` / `[KNOWLEDGE BASE]` / `[BEHAVIORAL RULES]` / `[CURRENT USER]` block. This block is prepended to every conversation automatically by `ChatViewModel.buildSystemPrompt()`.

### HostAppTheme Merging
`AIChatTheme.resolved(hostTheme:)` merges a `HostAppTheme` onto the base theme token-by-token. Brand colors map to specific semantic tokens (primary → user bubble, send button, FAB; surface → bot bubble, input, header). This lets host apps adopt SDK UI without fighting a hardcoded design system.

### Swift 6 Strict Concurrency
- `@Observable` macro (not `ObservableObject`) — iOS 17+ API, clean actor isolation
- All public types: `Sendable`
- Providers: `Sendable final class` with no mutable shared state
- `ResponseIndex` in `MockAIProvider`: actor for safe index cycling
- No `@unchecked Sendable`; no `DispatchQueue`; no completion handlers

### SSE Streaming
Both `OpenAIProvider` and `AnthropicProvider` use `URLSession.bytes(for:)` with `AsyncSequence` line iteration. Tokens are yielded through `AsyncThrowingStream`. The ViewModel appends tokens in-place to the streaming placeholder message, giving real-time display without rebuilding the list.

### Context Length Recovery
On `.contextLengthExceeded`, the ViewModel trims the 4 oldest non-system messages and retries the request once (`isRetryingAfterContextTrim` guard prevents infinite loops).

---

## File Inventory

| File | Purpose |
|---|---|
| `Package.swift` | iOS 26, Swift 6 mode |
| `AIChatSupport.swift` | Public entry point |
| `Configuration/AIChatConfiguration.swift` | Full config struct |
| `Configuration/AIChatTheme.swift` | Token system + resolved() |
| `Configuration/AppContext.swift` | Product knowledge + buildSystemPromptBlock() |
| `Configuration/HostAppTheme.swift` | Brand override struct |
| `Models/ChatMessage.swift` | Message model + helpers |
| `Services/AIProvider.swift` | Protocol + config structs + error enum |
| `Services/OpenAIProvider.swift` | OpenAI SSE streaming |
| `Services/AnthropicProvider.swift` | Anthropic SSE streaming |
| `Services/MockAIProvider.swift` | Deterministic mock for dev/tests |
| `ViewModels/ChatViewModel.swift` | @Observable state machine |
| `Utilities/HapticManager.swift` | UIFeedbackGenerator wrappers |
| `Utilities/View+Extensions.swift` | Public view modifier APIs |
| `Views/Components/*.swift` | 10 composable UI components |
| `Views/Screens/ChatView.swift` | Root screen |
| `Launcher/AIChatLauncher.swift` | Sheet / fullscreen / inline presenter |
| `Launcher/AIChatFloatingButton.swift` | FAB with pulse animation |
| `Tests/AIChatSupportTests.swift` | Swift Testing suite (5 @Suite groups) |

---

## Accessibility

- `.accessibilityLabel` and `.accessibilityHint` on all interactive elements
- `@Environment(\.accessibilityReduceMotion)` read in `ChatView`, propagated into theme
- All font sizes use theme tokens (never `.caption`, `.body`, etc.)
- Minimum 44×44pt tap targets on all buttons
- `.textSelection(.enabled)` on message bubbles

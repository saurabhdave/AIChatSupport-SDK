# AIChatSupport

[![CI](https://github.com/saurabhdave/AIChatSupport-SDK/actions/workflows/ci.yml/badge.svg)](https://github.com/saurabhdave/AIChatSupport-SDK/actions/workflows/ci.yml)

A production-grade, plug-and-play SwiftUI AI Chat Support SDK for iOS.  
Drop in a floating button or a full chat screen with **3 lines of code** — no backend required.

---

## Requirements

| Requirement | Version |
|---|---|
| iOS | 26+ |
| Swift | 6.2+ (Swift 6 language mode, strict concurrency) |
| Xcode | 26+ |

Zero third-party dependencies.

---

## Installation — Swift Package Manager

In Xcode: **File → Add Package Dependencies** and enter:

```
https://github.com/saurabhdave/AIChatSupport-SDK
```

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/saurabhdave/AIChatSupport-SDK", .upToNextMajor(from: "1.0.0"))
]
```

Then add `"AIChatSupport"` to your target's dependencies.

---

## Quick Start

Three lines to add an AI chat floating button to any view:

```swift
import AIChatSupport

ContentView()
    .aiChatFloatingButton(configuration: AIChatSupport.quickStart(
        provider: .openAI(OpenAIConfig(apiKey: "sk-...")),
        appContext: AppContext(appName: "MyApp", appDescription: "A task management app.")
    ))
```

---

## Full Configuration Example

```swift
import AIChatSupport

// 1. Build rich product knowledge
let context = AppContext(
    appName: "ShopEasy",
    appDescription: "A curated fashion marketplace for independent designers.",
    companyName: "ShopEasy Inc.",
    supportEmail: "help@shopeasy.com",
    supportPhoneNumber: "+1-800-555-0199",
    productCategories: ["Fashion", "Marketplace", "E-commerce"],
    primaryUseCases: ["Order tracking", "Returns & refunds", "Sizing help", "Designer info"],
    keyFeatures: ["1,000+ independent designers", "Free 30-day returns", "Same-day city delivery"],
    pricingInfo: "Free to shop. ShopEasy Pro: $9.99/mo",
    doNotDiscussList: ["competitor pricing", "internal margins"],
    escalationTriggers: ["speak to a human", "talk to agent", "real person"],
    handoffMessage: "I'll connect you with a ShopEasy team member right away. Average wait: under 2 minutes.",
    tonePersonality: .friendly,
    faqs: [
        FAQ(question: "How do I track my order?",
            answer: "Open the Orders tab, tap your order, and you'll see live tracking."),
        FAQ(question: "What is the return policy?",
            answer: "Free returns within 30 days. Initiate in the app under Orders > Return Item."),
        FAQ(question: "Can I contact a designer directly?",
            answer: "Yes! Each product page has a 'Message Designer' button.")
    ]
)

// 2. Build configuration
var config = AIChatConfiguration(
    provider: .anthropic(AnthropicConfig(apiKey: "sk-ant-...")),
    botName: "ShopEasy Support",
    botSubtitle: "Typically replies instantly",
    botAvatarStyle: .sfSymbol("bag.fill"),
    appContext: context,
    presentationStyle: .sheet,
    suggestedPrompts: ["Track my order", "Start a return", "Find my size"],
    systemPrompt: "Always end responses with a relevant follow-up question.",
    enableFeedback: true,
    showTypingIndicator: true
)

// 3. Apply brand theme
config.hostAppTheme = HostAppTheme(
    brandPrimaryColor: Color(red: 1.0, green: 0.42, blue: 0.21),  // ShopEasy orange
    brandSurfaceColor: Color(red: 0.98, green: 0.96, blue: 0.94), // warm off-white
    brandOnPrimaryColor: .white,
    preferredFontFamily: "Georgia",
    cornerRadiusStyle: .pill
)

// 4. Set user context after login
config.appContext.currentUserInfo = UserInfo(
    userID: "usr_8821",
    name: "Jordan Lee",
    email: "jordan@example.com",
    plan: "ShopEasy Pro",
    customAttributes: ["preferred_designer": "Maison Cleo", "city": "New York"]
)

// 5. Present
ContentView()
    .aiChatSupport(isPresented: $showChat, configuration: config)
```

---

## AppContext Example — "ShopEasy"

```swift
let context = AppContext(
    appName: "ShopEasy",
    appDescription: "A curated fashion marketplace for independent designers.",
    companyName: "ShopEasy Inc.",
    websiteURL: "https://shopeasy.com",
    supportEmail: "help@shopeasy.com",
    productCategories: ["Fashion", "Marketplace"],
    primaryUseCases: ["Order tracking", "Returns", "Sizing"],
    keyFeatures: ["Free 30-day returns", "Same-day city delivery"],
    tonePersonality: .friendly,
    faqs: [
        FAQ(question: "What is the return policy?", answer: "Free returns within 30 days.")
    ]
)
```

---

## HostAppTheme Example

```swift
let hostTheme = HostAppTheme(
    brandPrimaryColor: Color(red: 1.0, green: 0.42, blue: 0.21),
    brandSurfaceColor: Color(red: 0.98, green: 0.96, blue: 0.94),
    brandOnPrimaryColor: .white,
    preferredFontFamily: "Georgia",
    messageFontSize: 15,
    cornerRadiusStyle: .pill,
    prefersBorderedInput: false,
    reducedMotion: false
)

config.hostAppTheme = hostTheme
```

---

## AI Providers

| Provider | Case | Notes |
|---|---|---|
| OpenAI | `.openAI(OpenAIConfig(...))` | GPT-4o default; SSE streaming |
| Anthropic | `.anthropic(AnthropicConfig(...))` | Claude Opus 4.8 default; SSE streaming |
| Custom | `.custom(MyProvider())` | Conform to `AIProviderProtocol` |
| Mock | `.mock(MockAIConfig(...))` | For development and testing; no API key needed |

> ⚠️ **Security — do not ship provider API keys in production.** The `.openAI` and `.anthropic` providers call the vendor API directly from the device, which means any key you pass is embedded in your app binary and can be extracted. Use them for prototyping only. **For production, route requests through your own backend and use `.custom(...)`** to point the SDK at your proxy endpoint — your server holds the secret key and the app never sees it.

---

## Theme Presets

| Preset | Description |
|---|---|
| `.light` | Clean light theme (default) |
| `.dark` | Dark mode first |
| `.minimal` | Monochrome, flat, bordered input |

Build a custom theme:

```swift
let theme = AIChatTheme.custom { t in
    t.primaryColor = .purple
    t.bubbleCornerRadius = 12
}
```

---

## Delegate Usage

`AIChatDelegate` is `@MainActor`-isolated, so conforming types must be main-actor isolated too (mark the class `@MainActor`):

```swift
@MainActor
final class MyChatDelegate: AIChatDelegate {
    func chatDidSendMessage(_ message: String) {
        Analytics.track("chat_message_sent")
    }
    func chatDidReceiveResponse(_ response: String) {
        // Log or process bot response
    }
    func chatDidEncounterError(_ error: any Error) {
        Crashlytics.recordError(error)
    }
    func chatDidDismiss() {
        print("Chat closed")
    }
}

config.delegate = MyChatDelegate()
```

---

## Custom Provider

```swift
struct MyBackendProvider: AIProviderProtocol {
    func streamResponse(
        messages: [AIMessage],
        systemPrompt: String
    ) async throws(AIProviderError) -> AsyncThrowingStream<String, any Error> {
        // Call your own SSE endpoint and return an AsyncThrowingStream
        AsyncThrowingStream { continuation in
            Task {
                // ... your streaming logic
                continuation.finish()
            }
        }
    }
}

let config = AIChatConfiguration(
    provider: .custom(MyBackendProvider()),
    appContext: AppContext(appName: "MyApp", appDescription: "...")
)
```

---

## Presentation Styles

```swift
// Sheet (default)
config.presentationStyle = .sheet

// Fullscreen
config.presentationStyle = .fullScreen

// Inline embed
myView.aiChatInline(configuration: config)
```

---

## Example app

A runnable SwiftUI showcase lives in [`Examples/AIChatDemo`](Examples/AIChatDemo). Open
`Examples/AIChatDemo/AIChatDemo.xcodeproj` in Xcode, pick an iOS 26 simulator, and Run. It
demonstrates the floating button, sheet/fullscreen/inline presentation, a branded `HostAppTheme`,
and the lifecycle delegate.

Three tab-bar domains — an **e-commerce** assistant (ShopEasy), a **travel concierge** (Wanderly),
and an **on-device** assistant — show the same SDK adapting its identity, prompts, knowledge, and
brand to any context.

| Showcase home (3 domains) | E-commerce chat | Travel chat | Branded theme |
|---|---|---|---|
| <img src="Examples/AIChatDemo/Screenshots/01-home.png" width="200" alt="Showcase home with ShopEasy, Wanderly and On-Device tabs"> | <img src="Examples/AIChatDemo/Screenshots/02-shopeasy-chat.png" width="200" alt="ShopEasy e-commerce chat"> | <img src="Examples/AIChatDemo/Screenshots/03-wanderly-chat.png" width="200" alt="Wanderly travel chat"> | <img src="Examples/AIChatDemo/Screenshots/04-wanderly-branded.png" width="200" alt="Wanderly branded theme"> |

_Captured on iOS 26 Simulator. The chat stays light even with the device in Dark Mode because the theme pins its own color scheme._

It runs on the **mock provider** out of the box — no API key needed. To try live streaming, set
`OPENAI_API_KEY` or `ANTHROPIC_API_KEY` in the Run scheme's environment
(**Product ▸ Scheme ▸ Edit Scheme… ▸ Run ▸ Arguments ▸ Environment Variables**).

### On-device & custom models

The SDK is model-agnostic — you can point it at any LLM, including your own fine-tuned model:

- **OpenAI-compatible endpoint (no code):** set `OpenAIConfig.baseURL` + `model` to a server such as
  Ollama, vLLM, LM Studio, llama.cpp, TGI, Together/Groq/OpenRouter, Azure OpenAI, or a fine-tuned
  OpenAI model id.
- **Anything else (`.custom`):** conform to `AIProviderProtocol` and return an
  `AsyncThrowingStream<String, any Error>` — a bespoke HTTP/SSE API, or an **on-device** model.

#### Local / self-hosted model (e.g. Ollama)

Ollama, vLLM, and LM Studio all expose an OpenAI-compatible API, so a local model needs no custom
code — just repoint `OpenAIConfig`:

```swift
// `ollama serve` then `ollama pull llama3.2`
let config = AIChatConfiguration(
    provider: .openAI(OpenAIConfig(
        apiKey: "ollama",                     // any non-empty string; local servers ignore it
        model: "llama3.2",
        baseURL: "http://localhost:11434/v1"  // Simulator reaches the host; on a device use your Mac's LAN IP
    )),
    appContext: AppContext(appName: "MyApp", appDescription: "…")
)
```

> **Cleartext HTTP note:** App Transport Security blocks plain `http://` by default. For a local
> server add an ATS exception to your app's Info.plist — `NSAllowsLocalNetworking = YES` for
> `localhost`, or an `NSExceptionDomains` entry for a LAN host. Production traffic should use HTTPS.

The **On-Device** tab is a working `.custom` example: [`OnDeviceModelProvider`](Examples/AIChatDemo/AIChatDemo/Support/OnDeviceModelProvider.swift)
bridges Apple's **Foundation Models** on-device LLM (no network, no API key). It requires an
Apple Intelligence–capable device with the feature enabled — on the Simulator or unsupported
devices the chat shows an availability message. For a custom-*trained* model, load a trained adapter
via `SystemLanguageModel(adapter:)` and pass it to `LanguageModelSession(model:)`.

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release notes, including breaking changes.

---

## License

MIT

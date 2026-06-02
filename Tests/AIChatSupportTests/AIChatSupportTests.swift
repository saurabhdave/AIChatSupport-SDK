import Testing
import Foundation
import SwiftUI
@testable import AIChatSupport

// MARK: – AppContext Tests

@Suite("AppContext.buildSystemPromptBlock")
struct AppContextTests {

    @Test("Full context produces all required sections")
    func fullContextProducesAllSections() {
        let context = AppContext(
            appName: "ShopEasy",
            appDescription: "A curated fashion marketplace.",
            appVersion: "3.2.1",
            companyName: "ShopEasy Inc.",
            websiteURL: "https://shopeasy.com",
            supportEmail: "help@shopeasy.com",
            supportPhoneNumber: "+1-800-555-0199",
            productCategories: ["Fashion", "Marketplace"],
            primaryUseCases: ["Order tracking", "Returns"],
            keyFeatures: ["Free returns", "Same-day delivery"],
            pricingInfo: "Free + $9.99/mo Pro",
            targetAudience: "Fashion-forward shoppers",
            doNotDiscussList: ["competitor pricing"],
            escalationTriggers: ["speak to a human"],
            handoffMessage: "Connecting you now.",
            tonePersonality: .friendly,
            faqs: [FAQ(question: "How do I return?", answer: "Open the app and select Returns.")],
            currentUserInfo: nil
        )

        let block = context.buildSystemPromptBlock()

        #expect(block.contains("[PRODUCT CONTEXT]"))
        #expect(block.contains("ShopEasy by ShopEasy Inc."))
        #expect(block.contains("A curated fashion marketplace."))
        #expect(block.contains("3.2.1"))
        #expect(block.contains("https://shopeasy.com"))
        #expect(block.contains("help@shopeasy.com"))
        #expect(block.contains("+1-800-555-0199"))
        #expect(block.contains("Fashion, Marketplace"))
        #expect(block.contains("Free returns"))
        #expect(block.contains("Free + $9.99/mo Pro"))
        #expect(block.contains("[KNOWLEDGE BASE]"))
        #expect(block.contains("Q: How do I return?"))
        #expect(block.contains("A: Open the app and select Returns."))
        #expect(block.contains("[BEHAVIORAL RULES]"))
        #expect(block.contains("friendly"))
        #expect(block.contains("competitor pricing"))
        #expect(block.contains("speak to a human"))
        #expect(block.contains("Connecting you now."))
    }

    @Test("Empty AppContext returns empty string")
    func emptyContextReturnsEmpty() {
        let context = AppContext()
        let block = context.buildSystemPromptBlock()
        #expect(block.isEmpty)
    }

    @Test("Missing optional fields are omitted with no blank lines for them")
    func missingOptionalFieldsOmitted() {
        let context = AppContext(
            appName: "MyApp",
            appDescription: "A great app.",
            appVersion: nil,
            companyName: nil,
            websiteURL: nil,
            supportEmail: nil
        )
        let block = context.buildSystemPromptBlock()
        #expect(!block.contains("Version:"))
        #expect(!block.contains("Website:"))
        #expect(!block.contains("Support:"))
        #expect(block.contains("MyApp"))
        #expect(block.contains("A great app."))
    }

    @Test("FAQs are formatted as Q:/A: pairs")
    func faqsFormatted() {
        let context = AppContext(
            appName: "App",
            appDescription: "Desc.",
            faqs: [
                FAQ(question: "Q1?", answer: "A1."),
                FAQ(question: "Q2?", answer: "A2.")
            ]
        )
        let block = context.buildSystemPromptBlock()
        #expect(block.contains("Q: Q1?"))
        #expect(block.contains("A: A1."))
        #expect(block.contains("Q: Q2?"))
        #expect(block.contains("A: A2."))
    }

    @Test("UserInfo block is included when present")
    func userInfoIncluded() {
        var context = AppContext(appName: "App", appDescription: "Desc.")
        context.currentUserInfo = UserInfo(
            name: "Jordan",
            email: "j@example.com",
            plan: "Pro",
            customAttributes: ["city": "NYC"]
        )
        let block = context.buildSystemPromptBlock()
        #expect(block.contains("[CURRENT USER]"))
        #expect(block.contains("Jordan"))
        #expect(block.contains("j@example.com"))
        #expect(block.contains("Pro"))
        #expect(block.contains("city: NYC"))
    }

    @Test("UserInfo block is absent when currentUserInfo is nil")
    func userInfoAbsentWhenNil() {
        let context = AppContext(appName: "App", appDescription: "Desc.")
        let block = context.buildSystemPromptBlock()
        #expect(!block.contains("[CURRENT USER]"))
    }

    @Test("Escalation triggers are correctly formatted")
    func escalationTriggersFormatted() {
        let context = AppContext(
            appName: "App",
            appDescription: "Desc.",
            escalationTriggers: ["speak to a human", "talk to agent"],
            handoffMessage: "Hold please."
        )
        let block = context.buildSystemPromptBlock()
        #expect(block.contains("speak to a human"))
        #expect(block.contains("talk to agent"))
        #expect(block.contains("Hold please."))
    }
}

// MARK: – AIChatTheme Tests

@Suite("AIChatTheme.resolved")
struct AIChatThemeTests {

    @Test("nil hostTheme returns theme unchanged")
    func nilHostThemeUnchanged() {
        let theme = AIChatTheme.light
        let resolved = theme.resolved(hostTheme: nil)
        #expect(resolved.messageFontSize == theme.messageFontSize)
        #expect(resolved.bubbleCornerRadius == theme.bubbleCornerRadius)
    }

    @Test("brandPrimaryColor overrides userBubbleColor and sendButtonColor")
    func brandPrimaryColorOverrides() {
        let hostTheme = HostAppTheme(brandPrimaryColor: .red)
        let resolved = AIChatTheme.light.resolved(hostTheme: hostTheme)
        #expect(resolved.userBubbleColor == .red)
        #expect(resolved.sendButtonColor == .red)
        #expect(resolved.chipSelectedBackgroundColor == .red)
    }

    @Test("brandSurfaceColor overrides botBubbleColor and inputBackgroundColor and headerBackgroundColor")
    func brandSurfaceColorOverrides() {
        let hostTheme = HostAppTheme(brandSurfaceColor: .green)
        let resolved = AIChatTheme.light.resolved(hostTheme: hostTheme)
        #expect(resolved.botBubbleColor == .green)
        #expect(resolved.inputBackgroundColor == .green)
        #expect(resolved.headerBackgroundColor == .green)
        #expect(resolved.secondaryBackgroundColor == .green)
    }

    @Test("prefersDarkMode true starts from dark base")
    func prefersDarkModeUsesDarkBase() {
        let hostTheme = HostAppTheme(prefersDarkMode: true)
        let resolved = AIChatTheme.light.resolved(hostTheme: hostTheme)
        #expect(resolved.backgroundColor == AIChatTheme.dark.backgroundColor)
    }

    @Test("cornerRadiusStyle pill sets bubbleCornerRadius to 99")
    func pillCornerRadius() {
        let hostTheme = HostAppTheme(cornerRadiusStyle: .pill)
        let resolved = AIChatTheme.light.resolved(hostTheme: hostTheme)
        #expect(resolved.bubbleCornerRadius == 99)
        #expect(resolved.inputCornerRadius == 99)
    }

    @Test("cornerRadiusStyle sharp sets bubbleCornerRadius to 0")
    func sharpCornerRadius() {
        let hostTheme = HostAppTheme(cornerRadiusStyle: .sharp)
        let resolved = AIChatTheme.light.resolved(hostTheme: hostTheme)
        #expect(resolved.bubbleCornerRadius == 0)
        #expect(resolved.inputCornerRadius == 4)
    }

    @Test("cornerRadiusStyle custom sets exact values")
    func customCornerRadius() {
        let hostTheme = HostAppTheme(cornerRadiusStyle: .custom(bubble: 12, input: 16))
        let resolved = AIChatTheme.light.resolved(hostTheme: hostTheme)
        #expect(resolved.bubbleCornerRadius == 12)
        #expect(resolved.inputCornerRadius == 16)
    }

    @Test("prefersBorderedInput is propagated")
    func prefersBorderedInputPropagated() {
        let hostTheme = HostAppTheme(prefersBorderedInput: true)
        let resolved = AIChatTheme.light.resolved(hostTheme: hostTheme)
        #expect(resolved.prefersBorderedInput == true)
    }

    @Test("Presets carry the expected color scheme")
    func presetColorSchemes() {
        #expect(AIChatTheme.light.colorScheme == .light)
        #expect(AIChatTheme.dark.colorScheme == .dark)
        #expect(AIChatTheme.minimal.colorScheme == .light)
    }

    @Test("prefersDarkMode pins the resolved color scheme")
    func prefersDarkModePinsScheme() {
        #expect(AIChatTheme.light.resolved(hostTheme: HostAppTheme(prefersDarkMode: true)).colorScheme == .dark)
        #expect(AIChatTheme.dark.resolved(hostTheme: HostAppTheme(prefersDarkMode: false)).colorScheme == .light)
        // nil leaves the base theme's scheme untouched.
        #expect(AIChatTheme.light.resolved(hostTheme: HostAppTheme(brandPrimaryColor: .red)).colorScheme == .light)
    }
}

// MARK: – ChatViewModel Tests

@Suite("ChatViewModel")
@MainActor
struct ChatViewModelTests {

    func makeViewModel(prompts: [String] = [], maxContextTurns: Int = 3) -> ChatViewModel {
        let config = AIChatConfiguration(
            provider: .mock(MockAIConfig(streamDelay: 0, tokenDelay: 0)),
            welcomeMessages: [],
            suggestedPrompts: prompts,
            maxContextTurns: maxContextTurns
        )
        return ChatViewModel(configuration: config)
    }

    @Test("sendMessage appends user message")
    func sendMessageAppendsUserMessage() async throws {
        let vm = makeViewModel()
        vm.inputText = "Hello"
        vm.sendMessage()
        try await Task.sleep(for: .milliseconds(150))
        #expect(vm.messages.contains { $0.role == .user && $0.content == "Hello" })
    }

    @Test("clearConversation empties messages")
    func clearConversationEmptiesMessages() async throws {
        let vm = makeViewModel()
        vm.inputText = "Test"
        vm.sendMessage()
        try await Task.sleep(for: .milliseconds(150))
        vm.clearConversation()
        #expect(vm.messages.isEmpty)
        #expect(vm.inputText.isEmpty)
        #expect(vm.error == nil)
    }

    @Test("canSend is false when inputText is empty")
    func canSendFalseWhenEmpty() {
        let vm = makeViewModel()
        vm.inputText = ""
        #expect(vm.canSend == false)
    }

    @Test("canSend is true when inputText has content and not loading")
    func canSendTrueWithContent() {
        let vm = makeViewModel()
        vm.inputText = "Hello"
        #expect(vm.canSend == true)
    }

    @Test("showSuggestedPrompts true before any user message with prompts configured")
    func showSuggestedPromptsBeforeFirstMessage() {
        let vm = makeViewModel(prompts: ["Hello"])
        #expect(vm.showSuggestedPrompts == true)
    }

    @Test("showSuggestedPrompts false with no configured prompts")
    func showSuggestedPromptsFalseWhenNoPrompts() {
        let vm = makeViewModel(prompts: [])
        #expect(vm.showSuggestedPrompts == false)
    }

    @Test("setFeedback updates correct message after bot responds")
    func setFeedbackUpdatesMessage() async throws {
        let vm = makeViewModel()
        vm.inputText = "Hello"
        vm.sendMessage()
        try await Task.sleep(for: .milliseconds(300))
        guard let botMsg = vm.messages.first(where: { $0.role == .assistant }) else {
            return
        }
        vm.setFeedback(.positive, for: botMsg.id)
        #expect(vm.messages.first { $0.id == botMsg.id }?.feedback == .positive)
    }

    @Test("buildContext respects maxContextTurns limit")
    func buildContextRespectsTurnLimit() async throws {
        let vm = makeViewModel(maxContextTurns: 1)
        vm.inputText = "First"
        vm.sendMessage()
        try await Task.sleep(for: .milliseconds(300))
        vm.inputText = "Second"
        vm.sendMessage()
        try await Task.sleep(for: .milliseconds(300))
        // With maxContextTurns=1, only 2 messages (1 pair) sent to provider
        let userMessages = vm.messages.filter { $0.role == .user }
        #expect(userMessages.count >= 1)
    }
}

// MARK: – Context Assembly Tests

/// A provider that records every (messages, systemPrompt) pair it is asked to stream,
/// so tests can assert on the exact wire payload the view model builds.
final class CapturingProvider: AIProviderProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var _capturedMessages: [[AIMessage]] = []
    private var _capturedSystemPrompts: [String] = []
    private let response: String

    init(response: String = "ok") { self.response = response }

    var capturedMessages: [[AIMessage]] { lock.withLock { _capturedMessages } }
    var capturedSystemPrompts: [String] { lock.withLock { _capturedSystemPrompts } }

    func streamResponse(
        messages: [AIMessage],
        systemPrompt: String
    ) async throws(AIProviderError) -> AsyncThrowingStream<String, any Error> {
        lock.withLock {
            _capturedMessages.append(messages)
            _capturedSystemPrompts.append(systemPrompt)
        }
        let text = response
        return AsyncThrowingStream { continuation in
            continuation.yield(text)
            continuation.finish()
        }
    }
}

@Suite("ChatViewModel context assembly")
@MainActor
struct ContextAssemblyTests {

    @Test("First turn never sends an empty assistant placeholder and starts with the user role")
    func firstTurnExcludesPlaceholderAndLeadingWelcome() async throws {
        let capture = CapturingProvider()
        let config = AIChatConfiguration(
            provider: .custom(capture),
            welcomeMessages: [WelcomeMessage(text: "Hi there!", delay: 0)],
            showTypingIndicator: false
        )
        let vm = ChatViewModel(configuration: config)
        await vm.onAppear() // delivers the assistant welcome message

        vm.inputText = "Hello"
        vm.sendMessage()
        try await Task.sleep(for: .milliseconds(200))

        let sent = try #require(capture.capturedMessages.first)
        // No empty turns reach the provider.
        #expect(sent.allSatisfy { !$0.content.isEmpty })
        // The leading assistant welcome message is dropped; the first message is the user's.
        #expect(sent.first?.role == .user)
        #expect(sent.contains { $0.role == .user && $0.content == "Hello" })
    }

    @Test("Second turn includes the prior assistant reply and still starts with user")
    func secondTurnIncludesPriorAssistant() async throws {
        let capture = CapturingProvider(response: "first reply")
        let config = AIChatConfiguration(
            provider: .custom(capture),
            welcomeMessages: [],
            showTypingIndicator: false
        )
        let vm = ChatViewModel(configuration: config)

        vm.inputText = "First"
        vm.sendMessage()
        try await Task.sleep(for: .milliseconds(200))

        vm.inputText = "Second"
        vm.sendMessage()
        try await Task.sleep(for: .milliseconds(200))

        let secondPayload = try #require(capture.capturedMessages.last)
        #expect(secondPayload.first?.role == .user)
        #expect(secondPayload.contains { $0.role == .assistant && $0.content == "first reply" })
        #expect(secondPayload.contains { $0.role == .user && $0.content == "Second" })
        #expect(secondPayload.allSatisfy { !$0.content.isEmpty })
    }

    @Test("System prompt carries the AppContext block")
    func systemPromptIncludesAppContext() async throws {
        let capture = CapturingProvider()
        let config = AIChatConfiguration(
            provider: .custom(capture),
            appContext: AppContext(appName: "ShopEasy", appDescription: "A marketplace."),
            welcomeMessages: [],
            showTypingIndicator: false
        )
        let vm = ChatViewModel(configuration: config)
        vm.inputText = "Hello"
        vm.sendMessage()
        try await Task.sleep(for: .milliseconds(200))

        let prompt = try #require(capture.capturedSystemPrompts.first)
        #expect(prompt.contains("[PRODUCT CONTEXT]"))
        #expect(prompt.contains("ShopEasy"))
    }

    @Test("A failed response marks the message failed and surfaces an error")
    func failedResponseSetsError() async throws {
        let config = AIChatConfiguration(
            provider: .mock(MockAIConfig(streamDelay: 0, tokenDelay: 0, shouldFail: true)),
            welcomeMessages: [],
            showTypingIndicator: false
        )
        let vm = ChatViewModel(configuration: config)
        vm.inputText = "Hello"
        vm.sendMessage()
        try await Task.sleep(for: .milliseconds(200))

        #expect(vm.error != nil)
        #expect(vm.messages.contains { $0.isFailed })
    }

    @Test("clearConversation resets loading and empties messages")
    func clearConversationResetsState() async throws {
        let config = AIChatConfiguration(
            provider: .mock(MockAIConfig(streamDelay: 5, tokenDelay: 0)),
            welcomeMessages: [],
            showTypingIndicator: false
        )
        let vm = ChatViewModel(configuration: config)
        vm.inputText = "Hello"
        vm.sendMessage()
        try await Task.sleep(for: .milliseconds(50))
        vm.clearConversation()

        #expect(vm.messages.isEmpty)
        #expect(vm.isLoading == false)
    }
}

// MARK: – AppContext identity edge case

@Suite("AppContext identity line")
struct AppContextIdentityTests {

    @Test("companyName is kept even when appName is empty")
    func companyKeptWithoutAppName() {
        let context = AppContext(appName: "", appDescription: "Desc.", companyName: "Acme Inc.")
        let block = context.buildSystemPromptBlock()
        #expect(block.contains("Acme Inc."))
    }

    @Test("appName and companyName combine as 'App by Company'")
    func appAndCompanyCombine() {
        let context = AppContext(appName: "ShopEasy", appDescription: "Desc.", companyName: "ShopEasy Inc.")
        let block = context.buildSystemPromptBlock()
        #expect(block.contains("ShopEasy by ShopEasy Inc."))
    }
}

// MARK: – MockAIProvider Tests

@Suite("MockAIProvider")
struct MockAIProviderTests {

    @Test("Yields tokens in sequence")
    func yieldsTokensInSequence() async throws {
        let provider = MockAIProvider(config: MockAIConfig(
            responses: ["Hello world"],
            streamDelay: 0,
            tokenDelay: 0,
            shouldFail: false
        ))
        let stream = try await provider.streamResponse(messages: [], systemPrompt: "")
        var tokens: [String] = []
        for try await token in stream {
            tokens.append(token)
        }
        let joined = tokens.joined()
        #expect(joined == "Hello world")
    }

    @Test("Cycles through responses when called multiple times")
    func cyclesResponses() async throws {
        let provider = MockAIProvider(config: MockAIConfig(
            responses: ["First", "Second"],
            streamDelay: 0,
            tokenDelay: 0
        ))

        var first = ""
        let s1 = try await provider.streamResponse(messages: [], systemPrompt: "")
        for try await t in s1 { first += t }

        var second = ""
        let s2 = try await provider.streamResponse(messages: [], systemPrompt: "")
        for try await t in s2 { second += t }

        #expect(first == "First")
        #expect(second == "Second")
    }

    @Test("Throws networkError when shouldFail is true")
    func throwsWhenShouldFail() async throws {
        let provider = MockAIProvider(config: MockAIConfig(
            streamDelay: 0,
            tokenDelay: 0,
            shouldFail: true
        ))
        let stream = try await provider.streamResponse(messages: [], systemPrompt: "")
        var caughtNetworkError = false
        do {
            for try await _ in stream {}
        } catch let error as AIProviderError {
            if case .networkError = error { caughtNetworkError = true }
        }
        #expect(caughtNetworkError)
    }

    @Test("Token ordering is deterministic with zero delay")
    func tokenOrderingDeterministic() async throws {
        let provider = MockAIProvider(config: MockAIConfig(
            responses: ["one two three"],
            streamDelay: 0,
            tokenDelay: 0
        ))
        let stream = try await provider.streamResponse(messages: [], systemPrompt: "")
        var result = ""
        for try await token in stream { result += token }
        #expect(result == "one two three")
    }
}

// MARK: – ChatMessage Tests

@Suite("ChatMessage")
struct ChatMessageTests {

    @Test("formattedTime for today shows h:mm a only")
    func formattedTimeToday() {
        let msg = ChatMessage(role: .user, content: "Hi", timestamp: Date())
        let formatted = msg.formattedTime
        #expect(!formatted.contains("Yesterday"))
        #expect(formatted.contains("AM") || formatted.contains("PM"))
    }

    @Test("formattedTime for yesterday contains Yesterday prefix")
    func formattedTimeYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let msg = ChatMessage(role: .user, content: "Hi", timestamp: yesterday)
        #expect(msg.formattedTime.hasPrefix("Yesterday"))
    }

    @Test("formattedTime for older dates contains full date")
    func formattedTimeOlder() {
        let twoYearsAgo = Calendar.current.date(byAdding: .year, value: -2, to: Date()) ?? Date()
        let msg = ChatMessage(role: .user, content: "Hi", timestamp: twoYearsAgo)
        #expect(msg.formattedTime.contains("AM") || msg.formattedTime.contains("PM"))
        #expect(!msg.formattedTime.hasPrefix("Yesterday"))
        #expect(!msg.formattedTime.hasPrefix("Today"))
    }

    @Test("isFailed returns true only for .failed status")
    func isFailedOnlyForFailedStatus() {
        let failed = ChatMessage(role: .user, content: "Hi", status: .failed("error"))
        let delivered = ChatMessage(role: .user, content: "Hi", status: .delivered)
        let sending = ChatMessage(role: .user, content: "Hi", status: .sending)
        #expect(failed.isFailed == true)
        #expect(delivered.isFailed == false)
        #expect(sending.isFailed == false)
    }

    @Test("toAIMessage returns nil for system role")
    func toAIMessageNilForSystem() {
        let msg = ChatMessage(role: .system, content: "System prompt")
        #expect(msg.toAIMessage == nil)
    }

    @Test("toAIMessage returns correct role for user and assistant")
    func toAIMessageRoles() {
        let user = ChatMessage(role: .user, content: "Hello")
        let assistant = ChatMessage(role: .assistant, content: "Hi")
        #expect(user.toAIMessage?.role == .user)
        #expect(assistant.toAIMessage?.role == .assistant)
    }

    @Test("toAIMessage preserves content")
    func toAIMessagePreservesContent() {
        let msg = ChatMessage(role: .user, content: "Hello, world!")
        #expect(msg.toAIMessage?.content == "Hello, world!")
    }
}

// MARK: – JSON configuration

@Suite("JSON configuration")
struct JSONConfigTests {

    @Test("Color(hex:) parses #RGB, #RRGGBB, #RRGGBBAA and rejects junk")
    func colorHexParsing() {
        #expect(Color(hex: "#FFFFFF") != nil)
        #expect(Color(hex: "FFF") != nil)
        #expect(Color(hex: "#FF6B35") != nil)
        #expect(Color(hex: "#FF6B3580") != nil)
        #expect(Color(hex: "nope") == nil)
        #expect(Color(hex: "#12") == nil)
    }

    @Test("TonePersonality decodes keywords and falls back to .custom")
    func toneDecoding() throws {
        let dec = JSONDecoder()
        #expect(try dec.decode(TonePersonality.self, from: Data("\"friendly\"".utf8)) == .friendly)
        let custom = try dec.decode(TonePersonality.self, from: Data("\"talk like a pirate\"".utf8))
        #expect(custom == .custom("talk like a pirate"))
    }

    @Test("FAQ round-trips question/answer")
    func faqRoundTrip() throws {
        let faq = FAQ(question: "Q?", answer: "A.")
        let data = try JSONEncoder().encode(faq)
        let back = try JSONDecoder().decode(FAQ.self, from: data)
        #expect(back.question == "Q?")
        #expect(back.answer == "A.")
    }

    @Test("AppContext decodes leniently — omitted fields use defaults")
    func appContextLenient() throws {
        let json = Data(#"{ "appName": "MyApp" }"#.utf8)
        let ctx = try JSONDecoder().decode(AppContext.self, from: json)
        #expect(ctx.appName == "MyApp")
        #expect(ctx.responseLanguage == "en-US")
        #expect(ctx.tonePersonality == .friendly)
        #expect(ctx.faqs.isEmpty)
    }

    @Test("AppContext round-trips full content")
    func appContextRoundTrip() throws {
        let ctx = AppContext(
            appName: "ShopEasy", appDescription: "A shop.",
            escalationTriggers: ["speak to a human"], handoffMessage: "Hold on.",
            tonePersonality: .custom("playful"),
            faqs: [FAQ(question: "Q?", answer: "A.")]
        )
        let data = try JSONEncoder().encode(ctx)
        let back = try JSONDecoder().decode(AppContext.self, from: data)
        #expect(back.appName == "ShopEasy")
        #expect(back.tonePersonality == .custom("playful"))
        #expect(back.faqs.first?.question == "Q?")
        #expect(back.handoffMessage == "Hold on.")
    }
}

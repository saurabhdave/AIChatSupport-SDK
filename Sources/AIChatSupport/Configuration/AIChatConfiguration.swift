import SwiftUI

/// Controls how the chat view is presented.
public enum PresentationStyle: Sendable {
    case sheet
    case fullScreen
    case inline
}

/// Controls the bot's avatar appearance.
public enum AvatarStyle: Sendable {
    case sfSymbol(String)
    case assetName(String)
    case initials(String)
    case none
}

/// A welcome message shown when the chat opens, with an optional stagger delay.
public struct WelcomeMessage: Identifiable, Sendable {
    public let id: UUID
    public let text: String
    /// Seconds to wait before showing this message.
    public let delay: TimeInterval

    public init(id: UUID = UUID(), text: String, delay: TimeInterval = 0) {
        self.id = id
        self.text = text
        self.delay = delay
    }

    public static var defaults: [WelcomeMessage] {
        [WelcomeMessage(text: "👋 Hi! How can I help you today?", delay: 0.4)]
    }
}

/// Receives lifecycle events from the chat session.
@MainActor
public protocol AIChatDelegate: AnyObject {
    func chatDidSendMessage(_ message: String)
    func chatDidReceiveResponse(_ response: String)
    func chatDidEncounterError(_ error: any Error)
    func chatDidDismiss()
}

public extension AIChatDelegate {
    func chatDidSendMessage(_ message: String) {}
    func chatDidReceiveResponse(_ response: String) {}
    func chatDidEncounterError(_ error: any Error) {}
    func chatDidDismiss() {}
}

/// The complete configuration for an AIChatSupport session.
public struct AIChatConfiguration: Sendable {

    // MARK: – AI Backend

    public var provider: AIProvider

    // MARK: – Bot Identity

    /// Default: "Support"
    public var botName: String
    /// Default: "Ask me anything"
    public var botSubtitle: String?
    /// Default: .sfSymbol("bubble.left.and.bubble.right.fill")
    public var botAvatarStyle: AvatarStyle

    // MARK: – Appearance

    /// Base theme. Overridden by hostAppTheme when non-nil.
    public var theme: AIChatTheme
    /// When set, resolved() merges these brand tokens onto theme.
    public var hostAppTheme: HostAppTheme?

    // MARK: – App / Product Knowledge

    public var appContext: AppContext

    // MARK: – Presentation

    /// Default: .sheet
    public var presentationStyle: PresentationStyle

    // MARK: – Content

    /// Default: WelcomeMessage.defaults
    public var welcomeMessages: [WelcomeMessage]
    /// Default: []
    public var suggestedPrompts: [String]
    /// Appended after the AppContext block in the system prompt.
    public var systemPrompt: String

    // MARK: – Behaviour

    /// Default: 20 (user+assistant pairs)
    public var maxContextTurns: Int
    /// Default: true
    public var showAttribution: Bool
    /// Default: true
    public var enableFeedback: Bool
    /// Default: true
    public var showTypingIndicator: Bool

    // MARK: – Lifecycle

    /// Lifecycle delegate. Marked nonisolated(unsafe) because AIChatDelegate is @MainActor-constrained
    /// and only ever accessed from the main actor in ChatViewModel — the type system cannot prove this automatically.
    public nonisolated(unsafe) var delegate: (any AIChatDelegate)?

    public init(
        provider: AIProvider,
        botName: String = "Support",
        botSubtitle: String? = "Ask me anything",
        botAvatarStyle: AvatarStyle = .sfSymbol("bubble.left.and.bubble.right.fill"),
        theme: AIChatTheme = .light,
        hostAppTheme: HostAppTheme? = nil,
        appContext: AppContext = AppContext(),
        presentationStyle: PresentationStyle = .sheet,
        welcomeMessages: [WelcomeMessage] = WelcomeMessage.defaults,
        suggestedPrompts: [String] = [],
        systemPrompt: String = "",
        maxContextTurns: Int = 20,
        showAttribution: Bool = true,
        enableFeedback: Bool = true,
        showTypingIndicator: Bool = true,
        delegate: (any AIChatDelegate)? = nil
    ) {
        self.provider = provider
        self.botName = botName
        self.botSubtitle = botSubtitle
        self.botAvatarStyle = botAvatarStyle
        self.theme = theme
        self.hostAppTheme = hostAppTheme
        self.appContext = appContext
        self.presentationStyle = presentationStyle
        self.welcomeMessages = welcomeMessages
        self.suggestedPrompts = suggestedPrompts
        self.systemPrompt = systemPrompt
        self.maxContextTurns = maxContextTurns
        self.showAttribution = showAttribution
        self.enableFeedback = enableFeedback
        self.showTypingIndicator = showTypingIndicator
        self.delegate = delegate
    }
}

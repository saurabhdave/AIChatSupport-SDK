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
///
/// The protocol is `@MainActor`-isolated and refines `Sendable` so it can be stored in the
/// `Sendable` ``AIChatConfiguration`` without an unsafe escape hatch. Conforming reference types
/// are main-actor isolated, which provides the required synchronization.
@MainActor
public protocol AIChatDelegate: AnyObject, Sendable {
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

    /// Lifecycle delegate, invoked on the main actor.
    public var delegate: (any AIChatDelegate)?

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

// MARK: - Codable

extension AvatarStyle: Codable {
    private enum CodingKeys: String, CodingKey { case type, value }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        switch try c.decode(String.self, forKey: .type) {
        case "sfSymbol": self = .sfSymbol(try c.decode(String.self, forKey: .value))
        case "assetName": self = .assetName(try c.decode(String.self, forKey: .value))
        case "initials": self = .initials(try c.decode(String.self, forKey: .value))
        case "none": self = .none
        case let other:
            throw DecodingError.dataCorruptedError(forKey: .type, in: c,
                debugDescription: "Unknown avatar type '\(other)'")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .sfSymbol(let v): try c.encode("sfSymbol", forKey: .type); try c.encode(v, forKey: .value)
        case .assetName(let v): try c.encode("assetName", forKey: .type); try c.encode(v, forKey: .value)
        case .initials(let v): try c.encode("initials", forKey: .type); try c.encode(v, forKey: .value)
        case .none: try c.encode("none", forKey: .type)
        }
    }
}

extension PresentationStyle: Codable, Equatable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        switch try container.decode(String.self) {
        case "sheet": self = .sheet
        case "fullScreen": self = .fullScreen
        case "inline": self = .inline
        case let other:
            throw DecodingError.dataCorruptedError(in: container,
                debugDescription: "Unknown presentationStyle '\(other)'")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .sheet: try c.encode("sheet")
        case .fullScreen: try c.encode("fullScreen")
        case .inline: try c.encode("inline")
        }
    }
}

extension WelcomeMessage: Codable {
    private enum CodingKeys: String, CodingKey { case text, delay }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(text: try c.decode(String.self, forKey: .text),
                  delay: try c.decodeIfPresent(TimeInterval.self, forKey: .delay) ?? 0)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(text, forKey: .text)
        try c.encode(delay, forKey: .delay)
    }
}

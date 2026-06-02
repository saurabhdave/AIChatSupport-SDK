import SwiftUI

/// Brand tokens decoded from JSON (hex colors / weight names) → `HostAppTheme`.
public struct BrandThemeConfig: Codable, Sendable {
    public var primaryColor: String?
    public var accentColor: String?
    public var backgroundColor: String?
    public var surfaceColor: String?
    public var onPrimaryColor: String?
    public var errorColor: String?
    public var prefersDarkMode: Bool?
    public var preferredFontFamily: String?
    public var headingFontWeight: String?
    public var bodyFontWeight: String?
    public var messageFontSize: CGFloat?
    public var usesDynamicType: Bool?
    public var cornerRadiusStyle: CornerRadiusStyle?
    public var prefersBorderedInput: Bool?
    public var reducedMotion: Bool?

    func makeHostAppTheme() -> HostAppTheme {
        HostAppTheme(
            brandPrimaryColor: primaryColor.flatMap(Color.init(hex:)),
            brandAccentColor: accentColor.flatMap(Color.init(hex:)),
            brandBackgroundColor: backgroundColor.flatMap(Color.init(hex:)),
            brandSurfaceColor: surfaceColor.flatMap(Color.init(hex:)),
            brandOnPrimaryColor: onPrimaryColor.flatMap(Color.init(hex:)),
            brandErrorColor: errorColor.flatMap(Color.init(hex:)),
            prefersDarkMode: prefersDarkMode,
            preferredFontFamily: preferredFontFamily,
            headingFontWeight: headingFontWeight.flatMap(FontWeightName.weight(from:)),
            bodyFontWeight: bodyFontWeight.flatMap(FontWeightName.weight(from:)),
            messageFontSize: messageFontSize,
            usesDynamicType: usesDynamicType ?? true,
            cornerRadiusStyle: cornerRadiusStyle ?? .rounded,
            prefersBorderedInput: prefersBorderedInput ?? false,
            reducedMotion: reducedMotion ?? false
        )
    }
}

/// A JSON-decodable chat configuration. All fields are optional; missing ones fall back to the
/// same defaults as `AIChatConfiguration`. The `provider` and `delegate` are supplied in code
/// (never ship API keys in a bundled file).
public struct AIChatConfigurationFile: Codable, Sendable {
    public var botName: String?
    public var botSubtitle: String?
    public var botAvatar: AvatarStyle?
    public var presentationStyle: PresentationStyle?
    public var welcomeMessages: [WelcomeMessage]?
    public var suggestedPrompts: [String]?
    public var systemPrompt: String?
    public var maxContextTurns: Int?
    public var showAttribution: Bool?
    public var enableFeedback: Bool?
    public var showTypingIndicator: Bool?
    public var themePreset: String?
    public var brand: BrandThemeConfig?
    public var appContext: AppContext?

    public enum LoadError: Error, CustomStringConvertible {
        case resourceNotFound(String)
        public var description: String {
            switch self {
            case .resourceNotFound(let name): return "JSON config resource '\(name).json' not found in bundle."
            }
        }
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    /// Decodes a configuration file from raw JSON data.
    public init(data: Data) throws {
        self = try Self.makeDecoder().decode(Self.self, from: data)
    }

    /// Decodes a configuration file from a JSON file URL.
    public init(contentsOf url: URL) throws {
        try self.init(data: Data(contentsOf: url))
    }

    /// Decodes a configuration file from a bundled `<name>.json` resource.
    public init(resource name: String, bundle: Bundle = .main) throws {
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw LoadError.resourceNotFound(name)
        }
        try self.init(contentsOf: url)
    }

    /// Builds a runtime configuration. Provide the AI backend (and optional delegate) in code.
    public func makeConfiguration(
        provider: AIProvider,
        delegate: (any AIChatDelegate)? = nil
    ) -> AIChatConfiguration {
        AIChatConfiguration(
            provider: provider,
            botName: botName ?? "Support",
            botSubtitle: botSubtitle ?? "Ask me anything",
            botAvatarStyle: botAvatar ?? .sfSymbol("bubble.left.and.bubble.right.fill"),
            theme: Self.preset(named: themePreset),
            hostAppTheme: brand?.makeHostAppTheme(),
            appContext: appContext ?? AppContext(),
            presentationStyle: presentationStyle ?? .sheet,
            welcomeMessages: welcomeMessages ?? WelcomeMessage.defaults,
            suggestedPrompts: suggestedPrompts ?? [],
            systemPrompt: systemPrompt ?? "",
            maxContextTurns: maxContextTurns ?? 20,
            showAttribution: showAttribution ?? true,
            enableFeedback: enableFeedback ?? true,
            showTypingIndicator: showTypingIndicator ?? true,
            delegate: delegate
        )
    }

    private static func preset(named name: String?) -> AIChatTheme {
        switch name?.lowercased() {
        case "dark": return .dark
        case "minimal": return .minimal
        default: return .light
        }
    }
}

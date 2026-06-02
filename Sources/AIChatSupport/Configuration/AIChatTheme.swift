import SwiftUI

/// The full visual token system for the chat UI.
public struct AIChatTheme: Sendable {

    // MARK: – Colors

    public var primaryColor: Color
    public var backgroundColor: Color
    public var secondaryBackgroundColor: Color
    public var userBubbleColor: Color
    public var userBubbleTextColor: Color
    public var botBubbleColor: Color
    public var botBubbleTextColor: Color
    public var inputBackgroundColor: Color
    public var inputBorderColor: Color
    public var inputTextColor: Color
    public var inputPlaceholderColor: Color
    public var headerBackgroundColor: Color
    public var headerTextColor: Color
    public var headerSubtitleColor: Color
    public var sendButtonColor: Color
    public var sendButtonIconColor: Color
    public var timestampColor: Color
    public var errorColor: Color
    public var onlineIndicatorColor: Color
    public var chipBorderColor: Color
    public var chipTextColor: Color
    public var chipSelectedBackgroundColor: Color
    public var attributionTextColor: Color

    // MARK: – Typography

    /// Default: 16pt.
    public var messageFontSize: CGFloat
    /// Default: 11pt.
    public var timestampFontSize: CGFloat
    /// Default: 17pt.
    public var headerTitleFontSize: CGFloat
    /// Default: 13pt.
    public var headerSubtitleFontSize: CGFloat
    /// Default: 16pt.
    public var inputFontSize: CGFloat
    /// nil = system font.
    public var preferredFontFamily: String?
    /// Weight for the header bot name. Default: .semibold.
    public var headingFontWeight: Font.Weight
    /// Weight for message-bubble and input text. Default: .regular.
    public var bodyFontWeight: Font.Weight
    /// When true, the chat honors the system Dynamic Type setting. Default: true.
    public var usesDynamicType: Bool

    // MARK: – Shape

    /// Default: 18pt.
    public var bubbleCornerRadius: CGFloat
    /// Default: 24pt.
    public var inputCornerRadius: CGFloat
    /// Default: 36pt.
    public var avatarSize: CGFloat
    /// Default: 4pt spacing between bubbles.
    public var messageSpacing: CGFloat
    /// Default: false.
    public var prefersBorderedInput: Bool

    // MARK: – Motion

    /// Default: false. Set to true to disable animations.
    public var reducedMotion: Bool

    // MARK: – Presets

    public static var `default`: AIChatTheme { .light }

    public static var light: AIChatTheme {
        AIChatTheme(
            primaryColor: Color(red: 0.0, green: 0.478, blue: 1.0),
            backgroundColor: Color(UIColor.systemBackground),
            secondaryBackgroundColor: Color(UIColor.secondarySystemBackground),
            userBubbleColor: Color(red: 0.0, green: 0.478, blue: 1.0),
            userBubbleTextColor: .white,
            botBubbleColor: Color(UIColor.secondarySystemBackground),
            botBubbleTextColor: Color(UIColor.label),
            inputBackgroundColor: Color(UIColor.secondarySystemBackground),
            inputBorderColor: Color(UIColor.separator),
            inputTextColor: Color(UIColor.label),
            inputPlaceholderColor: Color(UIColor.placeholderText),
            headerBackgroundColor: Color(UIColor.systemBackground),
            headerTextColor: Color(UIColor.label),
            headerSubtitleColor: Color(UIColor.secondaryLabel),
            sendButtonColor: Color(red: 0.0, green: 0.478, blue: 1.0),
            sendButtonIconColor: .white,
            timestampColor: Color(UIColor.tertiaryLabel),
            errorColor: .red,
            onlineIndicatorColor: Color(red: 0.2, green: 0.78, blue: 0.35),
            chipBorderColor: Color(UIColor.separator),
            chipTextColor: Color(UIColor.secondaryLabel),
            chipSelectedBackgroundColor: Color(red: 0.0, green: 0.478, blue: 1.0),
            attributionTextColor: Color(UIColor.tertiaryLabel),
            messageFontSize: 16,
            timestampFontSize: 11,
            headerTitleFontSize: 17,
            headerSubtitleFontSize: 13,
            inputFontSize: 16,
            preferredFontFamily: nil,
            bubbleCornerRadius: 18,
            inputCornerRadius: 24,
            avatarSize: 36,
            messageSpacing: 4,
            prefersBorderedInput: false,
            reducedMotion: false
        )
    }

    public static var dark: AIChatTheme {
        AIChatTheme(
            primaryColor: Color(red: 0.25, green: 0.6, blue: 1.0),
            backgroundColor: Color(red: 0.11, green: 0.11, blue: 0.12),
            secondaryBackgroundColor: Color(red: 0.17, green: 0.17, blue: 0.18),
            userBubbleColor: Color(red: 0.25, green: 0.6, blue: 1.0),
            userBubbleTextColor: .white,
            botBubbleColor: Color(red: 0.22, green: 0.22, blue: 0.23),
            botBubbleTextColor: .white,
            inputBackgroundColor: Color(red: 0.17, green: 0.17, blue: 0.18),
            inputBorderColor: Color(red: 0.35, green: 0.35, blue: 0.37),
            inputTextColor: .white,
            inputPlaceholderColor: Color(white: 0.55),
            headerBackgroundColor: Color(red: 0.11, green: 0.11, blue: 0.12),
            headerTextColor: .white,
            headerSubtitleColor: Color(white: 0.65),
            sendButtonColor: Color(red: 0.25, green: 0.6, blue: 1.0),
            sendButtonIconColor: .white,
            timestampColor: Color(white: 0.45),
            errorColor: Color(red: 1.0, green: 0.35, blue: 0.35),
            onlineIndicatorColor: Color(red: 0.2, green: 0.78, blue: 0.35),
            chipBorderColor: Color(red: 0.35, green: 0.35, blue: 0.37),
            chipTextColor: Color(white: 0.65),
            chipSelectedBackgroundColor: Color(red: 0.25, green: 0.6, blue: 1.0),
            attributionTextColor: Color(white: 0.35),
            messageFontSize: 16,
            timestampFontSize: 11,
            headerTitleFontSize: 17,
            headerSubtitleFontSize: 13,
            inputFontSize: 16,
            preferredFontFamily: nil,
            bubbleCornerRadius: 18,
            inputCornerRadius: 24,
            avatarSize: 36,
            messageSpacing: 4,
            prefersBorderedInput: false,
            reducedMotion: false
        )
    }

    public static var minimal: AIChatTheme {
        AIChatTheme(
            primaryColor: Color(UIColor.label),
            backgroundColor: Color(UIColor.systemBackground),
            secondaryBackgroundColor: Color(UIColor.systemBackground),
            userBubbleColor: Color(UIColor.label),
            userBubbleTextColor: Color(UIColor.systemBackground),
            botBubbleColor: Color(UIColor.systemBackground),
            botBubbleTextColor: Color(UIColor.label),
            inputBackgroundColor: Color(UIColor.systemBackground),
            inputBorderColor: Color(UIColor.separator),
            inputTextColor: Color(UIColor.label),
            inputPlaceholderColor: Color(UIColor.placeholderText),
            headerBackgroundColor: Color(UIColor.systemBackground),
            headerTextColor: Color(UIColor.label),
            headerSubtitleColor: Color(UIColor.secondaryLabel),
            sendButtonColor: Color(UIColor.label),
            sendButtonIconColor: Color(UIColor.systemBackground),
            timestampColor: Color(UIColor.tertiaryLabel),
            errorColor: .red,
            onlineIndicatorColor: Color(UIColor.secondaryLabel),
            chipBorderColor: Color(UIColor.separator),
            chipTextColor: Color(UIColor.label),
            chipSelectedBackgroundColor: Color(UIColor.label),
            attributionTextColor: Color(UIColor.tertiaryLabel),
            messageFontSize: 16,
            timestampFontSize: 11,
            headerTitleFontSize: 17,
            headerSubtitleFontSize: 13,
            inputFontSize: 16,
            preferredFontFamily: nil,
            bubbleCornerRadius: 8,
            inputCornerRadius: 10,
            avatarSize: 36,
            messageSpacing: 4,
            prefersBorderedInput: true,
            reducedMotion: false
        )
    }

    /// Build a custom theme by mutating a copy of the light preset.
    public static func custom(_ configure: (inout AIChatTheme) -> Void) -> AIChatTheme {
        var theme = AIChatTheme.light
        configure(&theme)
        return theme
    }

    /// Merges a HostAppTheme on top of this theme, returning a fully resolved token set.
    public func resolved(hostTheme: HostAppTheme?) -> AIChatTheme {
        guard let host = hostTheme else { return self }

        var base = host.prefersDarkMode == true ? AIChatTheme.dark : self

        if let primary = host.brandPrimaryColor {
            base.primaryColor = primary
            base.userBubbleColor = primary
            base.sendButtonColor = primary
            base.chipSelectedBackgroundColor = primary
        }
        if let accent = host.brandAccentColor {
            base.onlineIndicatorColor = accent
        }
        if let bg = host.brandBackgroundColor {
            base.backgroundColor = bg
        }
        if let surface = host.brandSurfaceColor {
            base.botBubbleColor = surface
            base.inputBackgroundColor = surface
            base.headerBackgroundColor = surface
            base.secondaryBackgroundColor = surface
        }
        if let onPrimary = host.brandOnPrimaryColor {
            base.userBubbleTextColor = onPrimary
            base.sendButtonIconColor = onPrimary
        }
        if let error = host.brandErrorColor {
            base.errorColor = error
        }

        base.bubbleCornerRadius = host.cornerRadiusStyle.bubbleRadius
        base.inputCornerRadius = host.cornerRadiusStyle.inputRadius

        if let family = host.preferredFontFamily {
            base.preferredFontFamily = family
        }
        if let size = host.messageFontSize {
            base.messageFontSize = size
            base.inputFontSize = size
        }
        if let weight = host.headingFontWeight {
            base.headingFontWeight = weight
        }
        if let weight = host.bodyFontWeight {
            base.bodyFontWeight = weight
        }
        base.usesDynamicType = host.usesDynamicType

        base.prefersBorderedInput = host.prefersBorderedInput
        base.reducedMotion = host.reducedMotion

        return base
    }

    public init(
        primaryColor: Color,
        backgroundColor: Color,
        secondaryBackgroundColor: Color,
        userBubbleColor: Color,
        userBubbleTextColor: Color,
        botBubbleColor: Color,
        botBubbleTextColor: Color,
        inputBackgroundColor: Color,
        inputBorderColor: Color,
        inputTextColor: Color,
        inputPlaceholderColor: Color,
        headerBackgroundColor: Color,
        headerTextColor: Color,
        headerSubtitleColor: Color,
        sendButtonColor: Color,
        sendButtonIconColor: Color,
        timestampColor: Color,
        errorColor: Color,
        onlineIndicatorColor: Color,
        chipBorderColor: Color,
        chipTextColor: Color,
        chipSelectedBackgroundColor: Color,
        attributionTextColor: Color,
        messageFontSize: CGFloat = 16,
        timestampFontSize: CGFloat = 11,
        headerTitleFontSize: CGFloat = 17,
        headerSubtitleFontSize: CGFloat = 13,
        inputFontSize: CGFloat = 16,
        preferredFontFamily: String? = nil,
        headingFontWeight: Font.Weight = .semibold,
        bodyFontWeight: Font.Weight = .regular,
        usesDynamicType: Bool = true,
        bubbleCornerRadius: CGFloat = 18,
        inputCornerRadius: CGFloat = 24,
        avatarSize: CGFloat = 36,
        messageSpacing: CGFloat = 4,
        prefersBorderedInput: Bool = false,
        reducedMotion: Bool = false
    ) {
        self.primaryColor = primaryColor
        self.backgroundColor = backgroundColor
        self.secondaryBackgroundColor = secondaryBackgroundColor
        self.userBubbleColor = userBubbleColor
        self.userBubbleTextColor = userBubbleTextColor
        self.botBubbleColor = botBubbleColor
        self.botBubbleTextColor = botBubbleTextColor
        self.inputBackgroundColor = inputBackgroundColor
        self.inputBorderColor = inputBorderColor
        self.inputTextColor = inputTextColor
        self.inputPlaceholderColor = inputPlaceholderColor
        self.headerBackgroundColor = headerBackgroundColor
        self.headerTextColor = headerTextColor
        self.headerSubtitleColor = headerSubtitleColor
        self.sendButtonColor = sendButtonColor
        self.sendButtonIconColor = sendButtonIconColor
        self.timestampColor = timestampColor
        self.errorColor = errorColor
        self.onlineIndicatorColor = onlineIndicatorColor
        self.chipBorderColor = chipBorderColor
        self.chipTextColor = chipTextColor
        self.chipSelectedBackgroundColor = chipSelectedBackgroundColor
        self.attributionTextColor = attributionTextColor
        self.messageFontSize = messageFontSize
        self.timestampFontSize = timestampFontSize
        self.headerTitleFontSize = headerTitleFontSize
        self.headerSubtitleFontSize = headerSubtitleFontSize
        self.inputFontSize = inputFontSize
        self.preferredFontFamily = preferredFontFamily
        self.headingFontWeight = headingFontWeight
        self.bodyFontWeight = bodyFontWeight
        self.usesDynamicType = usesDynamicType
        self.bubbleCornerRadius = bubbleCornerRadius
        self.inputCornerRadius = inputCornerRadius
        self.avatarSize = avatarSize
        self.messageSpacing = messageSpacing
        self.prefersBorderedInput = prefersBorderedInput
        self.reducedMotion = reducedMotion
    }
}

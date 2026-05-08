import SwiftUI

/// Controls how bubble and input field corners are styled.
public enum CornerRadiusStyle: Sendable {
    /// Standard chat feel — bubble: 18pt, input: 24pt.
    case rounded
    /// Very rounded — bubble: 99pt, input: 99pt.
    case pill
    /// Card-style — bubble: 8pt, input: 10pt.
    case subtle
    /// Flat/brutalist — bubble: 0pt, input: 4pt.
    case sharp
    /// Explicit custom radii.
    case custom(bubble: CGFloat, input: CGFloat)

    var bubbleRadius: CGFloat {
        switch self {
        case .rounded: return 18
        case .pill: return 99
        case .subtle: return 8
        case .sharp: return 0
        case .custom(let b, _): return b
        }
    }

    var inputRadius: CGFloat {
        switch self {
        case .rounded: return 24
        case .pill: return 99
        case .subtle: return 10
        case .sharp: return 4
        case .custom(_, let i): return i
        }
    }
}

/// Allows a host app to pass its brand identity so the chat UI adopts it automatically.
public struct HostAppTheme: Sendable {

    // MARK: – Brand Colors

    /// Maps to: user bubble, send button, FAB, selected chip background.
    public var brandPrimaryColor: Color?
    /// Maps to: online dot, positive feedback icon.
    public var brandAccentColor: Color?
    /// Maps to: main chat background.
    public var brandBackgroundColor: Color?
    /// Maps to: bot bubbles, input field background, header background, secondary background.
    public var brandSurfaceColor: Color?
    /// Maps to: text on primary-colored elements (user bubble text, send button icon).
    public var brandOnPrimaryColor: Color?
    /// Maps to: error banner, failed message tint.
    public var brandErrorColor: Color?

    // MARK: – Base Scheme

    /// nil = follow system, true/false = force dark/light.
    public var prefersDarkMode: Bool?

    // MARK: – Typography

    /// e.g. "Georgia", "Helvetica Neue". nil = system font.
    public var preferredFontFamily: String?
    /// Font weight used for the header bot name.
    public var headingFontWeight: Font.Weight?
    /// Font weight used in message bubbles.
    public var bodyFontWeight: Font.Weight?
    /// Overrides the SDK default of 16pt.
    public var messageFontSize: CGFloat?
    /// Default: true.
    public var usesDynamicType: Bool

    // MARK: – Shape Language

    /// Default: .rounded.
    public var cornerRadiusStyle: CornerRadiusStyle

    // MARK: – Input Style

    /// Border stroke instead of filled background.
    public var prefersBorderedInput: Bool

    // MARK: – Motion

    /// Overrides and respects accessibility setting.
    public var reducedMotion: Bool

    public init(
        brandPrimaryColor: Color? = nil,
        brandAccentColor: Color? = nil,
        brandBackgroundColor: Color? = nil,
        brandSurfaceColor: Color? = nil,
        brandOnPrimaryColor: Color? = nil,
        brandErrorColor: Color? = nil,
        prefersDarkMode: Bool? = nil,
        preferredFontFamily: String? = nil,
        headingFontWeight: Font.Weight? = nil,
        bodyFontWeight: Font.Weight? = nil,
        messageFontSize: CGFloat? = nil,
        usesDynamicType: Bool = true,
        cornerRadiusStyle: CornerRadiusStyle = .rounded,
        prefersBorderedInput: Bool = false,
        reducedMotion: Bool = false
    ) {
        self.brandPrimaryColor = brandPrimaryColor
        self.brandAccentColor = brandAccentColor
        self.brandBackgroundColor = brandBackgroundColor
        self.brandSurfaceColor = brandSurfaceColor
        self.brandOnPrimaryColor = brandOnPrimaryColor
        self.brandErrorColor = brandErrorColor
        self.prefersDarkMode = prefersDarkMode
        self.preferredFontFamily = preferredFontFamily
        self.headingFontWeight = headingFontWeight
        self.bodyFontWeight = bodyFontWeight
        self.messageFontSize = messageFontSize
        self.usesDynamicType = usesDynamicType
        self.cornerRadiusStyle = cornerRadiusStyle
        self.prefersBorderedInput = prefersBorderedInput
        self.reducedMotion = reducedMotion
    }
}

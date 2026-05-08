import SwiftUI

/// The primary entry point for integrating AIChatSupport into your app.
public enum AIChatSupport {

    /// Returns a fully configured ChatView ready to embed anywhere.
    @MainActor
    public static func makeView(configuration: AIChatConfiguration) -> some View {
        ChatView(configuration: configuration, isModal: false)
    }

    /// Quick-start factory — minimal required params, sensible defaults for everything else.
    public static func quickStart(
        provider: AIProvider,
        appContext: AppContext,
        botName: String = "Support",
        botSubtitle: String? = "Ask me anything"
    ) -> AIChatConfiguration {
        AIChatConfiguration(
            provider: provider,
            botName: botName,
            botSubtitle: botSubtitle,
            appContext: appContext
        )
    }
}

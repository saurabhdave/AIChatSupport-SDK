import SwiftUI

public extension View {

    /// Present the AI chat as a sheet or fullscreen cover based on the configuration's presentationStyle.
    func aiChatSupport(
        isPresented: Binding<Bool>,
        configuration: AIChatConfiguration
    ) -> some View {
        self.modifier(AIChatLauncherModifier(isPresented: isPresented, configuration: configuration))
    }

    /// Attach a floating action button that opens the chat when tapped.
    func aiChatFloatingButton(configuration: AIChatConfiguration) -> some View {
        self.modifier(AIChatFloatingButtonModifier(configuration: configuration))
    }

    /// Embed the chat view inline without any presentation chrome.
    func aiChatInline(configuration: AIChatConfiguration) -> some View {
        self.modifier(AIChatInlineModifier(configuration: configuration))
    }
}

/// Embeds the chat view in a ZStack overlay for inline presentation.
private struct AIChatInlineModifier: ViewModifier {
    let configuration: AIChatConfiguration

    func body(content: Content) -> some View {
        ZStack {
            content
            ChatView(configuration: configuration, isModal: false)
        }
    }
}

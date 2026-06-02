import SwiftUI

/// The navigation bar area of the chat — bot identity, online status, menu, and optional close button.
struct ChatHeaderView: View {
    let configuration: AIChatConfiguration
    let theme: AIChatTheme
    let isModal: Bool
    let onDismiss: () -> Void
    let onClearConversation: () -> Void

    @State private var showClearConfirmation: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            if isModal {
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(theme.headerSubtitleColor)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Close chat")
                .accessibilityHint("Double tap to close the chat")
            }

            BotAvatarView(avatarStyle: configuration.botAvatarStyle, theme: theme)

            VStack(alignment: .leading, spacing: 2) {
                Text(configuration.botName)
                    .font((theme.preferredFontFamily.map {
                        Font.custom($0, size: theme.headerTitleFontSize)
                    } ?? Font.system(size: theme.headerTitleFontSize)).weight(theme.headingFontWeight))
                    .foregroundStyle(theme.headerTextColor)

                if let subtitle = configuration.botSubtitle {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(theme.onlineIndicatorColor)
                            .frame(width: 6, height: 6)
                            .accessibilityHidden(true)
                        Text(subtitle)
                            .font(.system(size: theme.headerSubtitleFontSize))
                            .foregroundStyle(theme.headerSubtitleColor)
                    }
                }
            }

            Spacer()

            Menu {
                Button(role: .destructive) {
                    showClearConfirmation = true
                } label: {
                    Label("Clear Conversation", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(theme.headerSubtitleColor)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Chat options")
            .accessibilityHint("Double tap to open chat options")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(theme.headerBackgroundColor)
        .confirmationDialog(
            "Clear Conversation",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear", role: .destructive) { onClearConversation() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all messages in this conversation.")
        }
    }
}

#Preview {
    let config = AIChatConfiguration(
        provider: .mock(MockAIConfig()),
        botName: "ShopEasy Support",
        botSubtitle: "Typically replies instantly",
        botAvatarStyle: .sfSymbol("bag.fill")
    )
    ChatHeaderView(
        configuration: config,
        theme: .light,
        isModal: true,
        onDismiss: {},
        onClearConversation: {}
    )
}

import SwiftUI

/// The root chat screen. Owns the ChatViewModel and wires all sub-views together.
public struct ChatView: View {
    @State private var viewModel: ChatViewModel
    private let configuration: AIChatConfiguration
    let isModal: Bool

    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion

    public init(configuration: AIChatConfiguration, isModal: Bool = false) {
        self.configuration = configuration
        self.isModal = isModal
        self._viewModel = State(initialValue: ChatViewModel(configuration: configuration))
    }

    public var body: some View {
        let theme = resolvedTheme

        VStack(spacing: 0) {
            ChatHeaderView(
                configuration: configuration,
                theme: theme,
                isModal: isModal,
                onDismiss: { configuration.delegate?.chatDidDismiss() },
                onClearConversation: { viewModel.clearConversation() }
            )

            Divider()
                .opacity(0.5)

            MessageListView(
                viewModel: viewModel,
                theme: theme,
                enableFeedback: configuration.enableFeedback,
                avatarStyle: configuration.botAvatarStyle
            )
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 0) {
                    Divider()
                        .opacity(0.5)
                    ChatInputView(viewModel: viewModel, theme: theme)
                }
            }
        }
        .background(theme.backgroundColor.ignoresSafeArea())
        .task {
            await viewModel.onAppear()
        }
    }

    private var resolvedTheme: AIChatTheme {
        var theme = configuration.theme.resolved(hostTheme: configuration.hostAppTheme)
        if accessibilityReduceMotion {
            theme.reducedMotion = true
        }
        return theme
    }
}

#Preview {
    let config = AIChatConfiguration(
        provider: .mock(MockAIConfig()),
        botName: "Support",
        botSubtitle: "Ask me anything",
        suggestedPrompts: ["Track my order", "Start a return", "Find my size"]
    )
    ChatView(configuration: config, isModal: true)
}

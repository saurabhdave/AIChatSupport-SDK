import SwiftUI

/// Scrollable list of all chat messages with auto-scroll, transitions, and error banner overlay.
struct MessageListView: View {
    @Bindable var viewModel: ChatViewModel
    let theme: AIChatTheme
    let enableFeedback: Bool
    let avatarStyle: AvatarStyle

    private let bottomID = "chatBottom"

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    DateHeaderView(date: Date(), theme: theme)

                    ForEach(viewModel.messages) { message in
                        if message.role != .system {
                            MessageBubbleView(
                                message: message,
                                isLastAssistantMessage: isLastAssistant(message),
                                theme: theme,
                                enableFeedback: enableFeedback,
                                avatarStyle: avatarStyle,
                                onRetry: { viewModel.retry(messageID: message.id) },
                                onFeedback: { viewModel.setFeedback($0, for: message.id) }
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 3)
                            .transition(
                                .asymmetric(
                                    insertion: message.isUser
                                        ? .push(from: .trailing).combined(with: .opacity)
                                        : .push(from: .leading).combined(with: .opacity),
                                    removal: .opacity.animation(.easeOut(duration: 0.2))
                                )
                            )
                        }
                    }

                    if viewModel.isTyping {
                        TypingIndicatorView(theme: theme)
                            .transition(
                                .push(from: .leading).combined(with: .opacity)
                            )
                    }

                    if viewModel.showSuggestedPrompts {
                        SuggestedPromptsView(
                            prompts: viewModel.suggestedPrompts,
                            theme: theme,
                            onSelect: { viewModel.sendSuggestedPrompt($0) }
                        )
                    }

                    Spacer()
                        .frame(height: 8)
                        .id(bottomID)
                }
            }
            .overlay(alignment: .top) {
                if let errorMessage = viewModel.error {
                    ErrorBannerView(
                        message: errorMessage,
                        theme: theme,
                        onRetry: {
                            viewModel.clearError()
                        },
                        onDismiss: {
                            withAnimation {
                                viewModel.clearError()
                            }
                        }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .onChange(of: viewModel.messages.count) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel.isTyping) {
                scrollToBottom(proxy: proxy)
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.spring(duration: 0.35)) {
            proxy.scrollTo(bottomID, anchor: .bottom)
        }
    }

    private func isLastAssistant(_ message: ChatMessage) -> Bool {
        let assistantMessages = viewModel.messages.filter { $0.role == .assistant }
        return assistantMessages.last?.id == message.id
    }

}

#Preview {
    let config = AIChatConfiguration(
        provider: .mock(MockAIConfig()),
        suggestedPrompts: ["Track my order", "Start a return"]
    )
    let vm = ChatViewModel(configuration: config)
    MessageListView(
        viewModel: vm,
        theme: .light,
        enableFeedback: true,
        avatarStyle: .sfSymbol("bubble.left.fill")
    )
    .background(Color(UIColor.systemBackground))
}

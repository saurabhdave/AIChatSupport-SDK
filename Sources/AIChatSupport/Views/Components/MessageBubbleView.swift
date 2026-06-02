import SwiftUI

/// Renders a single chat message as a user or bot bubble.
struct MessageBubbleView: View {
    let message: ChatMessage
    let isLastAssistantMessage: Bool
    let theme: AIChatTheme
    let enableFeedback: Bool
    let avatarStyle: AvatarStyle
    let onRetry: () -> Void
    let onFeedback: (ChatMessage.Feedback) -> Void

    @State private var cursorVisible: Bool = false
    private let cursorTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            switch message.role {
            case .user:
                userBubble
            case .assistant:
                assistantBubble
            case .system:
                EmptyView()
            }
        }
    }

    private var userBubble: some View {
        HStack(alignment: .bottom) {
            Spacer(minLength: 60)
            VStack(alignment: .trailing, spacing: 2) {
                bubbleContent(
                    text: message.content,
                    backgroundColor: theme.userBubbleColor,
                    textColor: theme.userBubbleTextColor,
                    isFailed: message.isFailed
                )
                Text(message.formattedTime)
                    .font(.system(size: theme.timestampFontSize))
                    .foregroundStyle(theme.timestampColor)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("You: \(message.content), sent at \(message.formattedTime)")
    }

    private var assistantBubble: some View {
        HStack(alignment: .bottom, spacing: 6) {
            BotAvatarView(avatarStyle: avatarStyle, theme: theme)

            VStack(alignment: .leading, spacing: 2) {
                bubbleContent(
                    text: message.content + (message.isStreaming && !theme.reducedMotion && cursorVisible ? "|" : ""),
                    backgroundColor: theme.botBubbleColor,
                    textColor: theme.botBubbleTextColor,
                    isFailed: message.isFailed
                )

                HStack(spacing: 8) {
                    Text(message.formattedTime)
                        .font(.system(size: theme.timestampFontSize))
                        .foregroundStyle(theme.timestampColor)

                    if enableFeedback && isLastAssistantMessage && !message.isStreaming {
                        FeedbackView(
                            messageID: message.id,
                            currentFeedback: message.feedback,
                            theme: theme,
                            onFeedback: onFeedback
                        )
                    }
                }
            }

            Spacer(minLength: 60)
        }
        .onReceive(cursorTimer) { _ in
            if message.isStreaming && !theme.reducedMotion {
                cursorVisible.toggle()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Assistant: \(message.content), received at \(message.formattedTime)")
    }

    @ViewBuilder
    private func bubbleContent(text: String, backgroundColor: Color, textColor: Color, isFailed: Bool) -> some View {
        let content = (try? AttributedString(markdown: text, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))) ?? AttributedString(text)

        VStack(alignment: .leading, spacing: 4) {
            Text(content)
                .font((theme.preferredFontFamily.map {
                    Font.custom($0, size: theme.messageFontSize)
                } ?? Font.system(size: theme.messageFontSize)).weight(theme.bodyFontWeight))
                .foregroundStyle(textColor)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)

            if isFailed {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(theme.errorColor)
                    Button("Retry") { onRetry() }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(theme.errorColor)
                        .accessibilityLabel("Retry sending this message")
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: theme.bubbleCornerRadius)
                .fill(backgroundColor)
                .overlay(
                    isFailed
                    ? RoundedRectangle(cornerRadius: theme.bubbleCornerRadius)
                        .stroke(theme.errorColor, lineWidth: 1.5)
                    : nil
                )
        )
    }
}

#Preview {
    let theme = AIChatTheme.light
    VStack(spacing: 8) {
        MessageBubbleView(
            message: ChatMessage(role: .user, content: "Hello! Can you help me?", status: .delivered),
            isLastAssistantMessage: false,
            theme: theme,
            enableFeedback: true,
            avatarStyle: .sfSymbol("bubble.left.fill"),
            onRetry: {},
            onFeedback: { _ in }
        )
        MessageBubbleView(
            message: ChatMessage(role: .assistant, content: "Of course! I'd be happy to help you today.", status: .delivered),
            isLastAssistantMessage: true,
            theme: theme,
            enableFeedback: true,
            avatarStyle: .sfSymbol("bubble.left.fill"),
            onRetry: {},
            onFeedback: { _ in }
        )
    }
    .padding()
    .background(Color(UIColor.systemBackground))
}

import SwiftUI

/// Thumbs-up / thumbs-down feedback buttons shown below the last bot message.
struct FeedbackView: View {
    let messageID: UUID
    let currentFeedback: ChatMessage.Feedback?
    let theme: AIChatTheme
    let onFeedback: (ChatMessage.Feedback) -> Void

    @State private var thumbsUpScale: CGFloat = 1.0
    @State private var thumbsDownScale: CGFloat = 1.0

    var body: some View {
        HStack(spacing: 4) {
            feedbackButton(
                isPositive: true,
                isSelected: currentFeedback == .positive,
                scale: $thumbsUpScale
            )
            feedbackButton(
                isPositive: false,
                isSelected: currentFeedback == .negative,
                scale: $thumbsDownScale
            )
        }
    }

    @ViewBuilder
    private func feedbackButton(isPositive: Bool, isSelected: Bool, scale: Binding<CGFloat>) -> some View {
        let icon = isSelected
            ? (isPositive ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
            : (isPositive ? "hand.thumbsup" : "hand.thumbsdown")

        let color: Color = isSelected
            ? (isPositive ? theme.onlineIndicatorColor : theme.errorColor)
            : Color(UIColor.tertiaryLabel)

        Button {
            let feedback: ChatMessage.Feedback = isPositive ? .positive : .negative
            onFeedback(feedback)
            HapticManager.selection()
            if !theme.reducedMotion {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale.wrappedValue = 1.3
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        scale.wrappedValue = 1.0
                    }
                }
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
                .scaleEffect(scale.wrappedValue)
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(isPositive ? "Thumbs up" : "Thumbs down")
        .accessibilityHint(isPositive ? "Mark this response as helpful" : "Mark this response as unhelpful")
    }
}

#Preview {
    FeedbackView(
        messageID: UUID(),
        currentFeedback: .positive,
        theme: .light,
        onFeedback: { _ in }
    )
    .padding()
}

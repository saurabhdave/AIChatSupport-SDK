import SwiftUI

/// Animated three-dot typing indicator displayed while the bot is generating a response.
struct TypingIndicatorView: View {
    let theme: AIChatTheme

    @State private var animating: Bool = false

    private let dotDelays: [Double] = [0, 0.15, 0.30]

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            dotRow
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: theme.bubbleCornerRadius)
                        .fill(theme.botBubbleColor)
                )
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 3)
        .onAppear {
            if !theme.reducedMotion { animating = true }
        }
        .accessibilityLabel("Bot is typing")
    }

    private var dotRow: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(theme.botBubbleTextColor.opacity(theme.reducedMotion ? 0.7 : 0.6))
                    .frame(width: 8, height: 8)
                    .scaleEffect(theme.reducedMotion ? 1.0 : (animating ? 1.0 : 0.5))
                    .animation(
                        theme.reducedMotion ? nil :
                            .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(dotDelays[index]),
                        value: animating
                    )
            }
        }
    }
}

#Preview {
    TypingIndicatorView(theme: .light)
        .padding()
        .background(Color(UIColor.systemBackground))
}

import SwiftUI

/// Horizontal scrolling chip row shown before the user sends their first message.
struct SuggestedPromptsView: View {
    let prompts: [String]
    let theme: AIChatTheme
    let onSelect: (String) -> Void

    @State private var selectedPrompt: String? = nil
    @State private var isVisible: Bool = true

    var body: some View {
        Group {
            if isVisible {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(prompts, id: \.self) { prompt in
                            ChipButton(
                                text: prompt,
                                isSelected: selectedPrompt == prompt,
                                theme: theme
                            ) {
                                select(prompt)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
        }
        .transition(theme.reducedMotion ? .opacity : .opacity.animation(.easeOut(duration: 0.25)))
    }

    private func select(_ prompt: String) {
        selectedPrompt = prompt
        if !theme.reducedMotion {
            withAnimation(.easeOut(duration: 0.3)) {
                isVisible = false
            }
        } else {
            isVisible = false
        }
        onSelect(prompt)
    }
}

private struct ChipButton: View {
    let text: String
    let isSelected: Bool
    let theme: AIChatTheme
    let onTap: () -> Void

    @State private var scale: CGFloat = 1.0

    var body: some View {
        Button {
            if !theme.reducedMotion {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    scale = 0.93
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        scale = 1.0
                    }
                }
            }
            onTap()
        } label: {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isSelected ? .white : theme.chipTextColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? theme.chipSelectedBackgroundColor : Color.clear)
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? Color.clear : theme.chipBorderColor, lineWidth: 1.5)
                        )
                )
                .scaleEffect(scale)
        }
        .accessibilityLabel("Suggested prompt: \(text)")
        .accessibilityHint("Double tap to send this message")
    }
}

#Preview {
    SuggestedPromptsView(
        prompts: ["Track my order", "Start a return", "Find my size"],
        theme: .light,
        onSelect: { _ in }
    )
    .padding()
    .background(Color(UIColor.systemBackground))
}

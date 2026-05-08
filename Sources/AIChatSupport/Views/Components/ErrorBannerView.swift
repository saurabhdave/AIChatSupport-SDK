import SwiftUI

/// A dismissible error banner that slides in from the top of the message list.
struct ErrorBannerView: View {
    let message: String
    let theme: AIChatTheme
    let onRetry: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(theme.errorColor)
                .font(.system(size: 16))
                .accessibilityHidden(true)

            Text(message)
                .font(.system(size: theme.timestampFontSize + 1))
                .foregroundStyle(theme.errorColor)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Retry") {
                onRetry()
            }
            .font(.system(size: theme.timestampFontSize + 1, weight: .semibold))
            .foregroundStyle(theme.errorColor)
            .accessibilityLabel("Retry sending message")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: theme.bubbleCornerRadius)
                .fill(theme.errorColor.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: theme.bubbleCornerRadius)
                        .stroke(theme.errorColor, lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .onTapGesture { onDismiss() }
        .task {
            try? await Task.sleep(for: .seconds(4))
            onDismiss()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message)")
    }
}

#Preview {
    ErrorBannerView(
        message: "Unable to send. Please check your connection.",
        theme: .light,
        onRetry: {},
        onDismiss: {}
    )
    .padding()
    .background(Color(UIColor.systemBackground))
}

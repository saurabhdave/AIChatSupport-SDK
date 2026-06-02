import SwiftUI

/// The message composition area with a multiline text field and send button.
struct ChatInputView: View {
    @Bindable var viewModel: ChatViewModel
    let theme: AIChatTheme

    @FocusState private var isFocused: Bool

    private let maxLines: Int = 5
    private let characterCountThreshold: Int = 400

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            textField
            sendButton
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(theme.backgroundColor)
    }

    private var textField: some View {
        VStack(alignment: .trailing, spacing: 0) {
            TextField("Message...", text: $viewModel.inputText, axis: .vertical)
                .font(.system(size: theme.inputFontSize, weight: theme.bodyFontWeight))
                .foregroundStyle(theme.inputTextColor)
                .lineLimit(1...maxLines)
                .focused($isFocused)
                .submitLabel(.send)
                .onSubmit {
                    // With a vertical-axis TextField, a hardware-keyboard Return submits while
                    // Shift+Return inserts a newline; the software keyboard inserts newlines.
                    if viewModel.canSend {
                        viewModel.sendMessage()
                    }
                }

            if viewModel.inputText.count > characterCountThreshold {
                Text("\(viewModel.inputText.count)")
                    .font(.system(size: theme.timestampFontSize))
                    .foregroundStyle(theme.timestampColor)
                    .padding(.top, 2)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: theme.inputCornerRadius)
                .fill(theme.prefersBorderedInput ? Color.clear : theme.inputBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.inputCornerRadius)
                        .stroke(theme.prefersBorderedInput ? theme.inputBorderColor : Color.clear, lineWidth: 1.5)
                )
        )
        .frame(minHeight: 44)
    }

    private var sendButton: some View {
        Button {
            HapticManager.impact(.medium)
            viewModel.sendMessage()
        } label: {
            Image(systemName: "arrow.up")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(theme.sendButtonIconColor)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(viewModel.canSend ? theme.sendButtonColor : theme.sendButtonColor.opacity(0.4))
                )
        }
        .disabled(!viewModel.canSend)
        .buttonStyle(SpringButtonStyle(reducedMotion: theme.reducedMotion))
        .accessibilityLabel("Send message")
        .accessibilityHint("Double tap to send your message")
        .frame(width: 44, height: 44)
    }
}

private struct SpringButtonStyle: ButtonStyle {
    let reducedMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reducedMotion ? 0.88 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    let config = AIChatConfiguration(provider: .mock(MockAIConfig()))
    let vm = ChatViewModel(configuration: config)
    ChatInputView(viewModel: vm, theme: .light)
        .background(Color(UIColor.systemBackground))
}

import SwiftUI

/// Attaches a floating action button (FAB) that presents the chat as a sheet.
struct AIChatFloatingButtonModifier: ViewModifier {
    let configuration: AIChatConfiguration

    @State private var isPresented: Bool = false
    @State private var isPulsing: Bool = false

    private var theme: AIChatTheme {
        configuration.theme.resolved(hostTheme: configuration.hostAppTheme)
    }

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottomTrailing) {
                fabOverlay
            }
            .sheet(isPresented: $isPresented, onDismiss: {
                configuration.delegate?.chatDidDismiss()
            }) {
                ChatView(configuration: configuration, isModal: true)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
    }

    private var fabOverlay: some View {
        ZStack {
            if !theme.reducedMotion {
                Circle()
                    .stroke(theme.primaryColor, lineWidth: 2)
                    .frame(width: 56, height: 56)
                    .scaleEffect(isPulsing ? 1.5 : 1.0)
                    .opacity(isPulsing ? 0 : 0.6)
                    .animation(
                        .easeOut(duration: 1.2).repeatForever(autoreverses: false),
                        value: isPulsing
                    )
            }

            Button {
                HapticManager.impact(.medium)
                isPresented = true
            } label: {
                Image(systemName: "bubble.left.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(theme.primaryColor)
                    )
                    .shadow(color: theme.primaryColor.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .accessibilityLabel("Open chat support")
            .accessibilityHint("Double tap to open the AI chat support window")
        }
        .padding(20)
        .onAppear {
            if !theme.reducedMotion {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isPulsing = true
                }
            }
        }
    }
}

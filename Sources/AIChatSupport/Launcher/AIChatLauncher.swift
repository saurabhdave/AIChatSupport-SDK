import SwiftUI

/// Presents the chat view as a sheet, fullscreen cover, or inline overlay.
struct AIChatLauncherModifier: ViewModifier {
    @Binding var isPresented: Bool
    let configuration: AIChatConfiguration

    func body(content: Content) -> some View {
        switch configuration.presentationStyle {
        case .sheet:
            content
                .sheet(isPresented: $isPresented, onDismiss: {
                    configuration.delegate?.chatDidDismiss()
                }) {
                    ChatView(configuration: configuration, isModal: true)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
        case .fullScreen:
            content
                .fullScreenCover(isPresented: $isPresented, onDismiss: {
                    configuration.delegate?.chatDidDismiss()
                }) {
                    ChatView(configuration: configuration, isModal: true)
                }
        case .inline:
            ZStack {
                content
                if isPresented {
                    ChatView(configuration: configuration, isModal: false)
                }
            }
        }
    }
}

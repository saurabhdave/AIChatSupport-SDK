import AIChatSupport
import SwiftUI

/// Presents the chat as a sheet or a fullscreen cover.
struct PresentationDemo: View {
    let persona: DemoPersona
    @State private var showSheet = false
    @State private var showFullScreen = false

    var body: some View {
        List {
            Button("Open as sheet") { showSheet = true }
            Button("Open fullscreen") { showFullScreen = true }
        }
        .aiChatSupport(
            isPresented: $showSheet,
            configuration: persona.makeConfiguration(presentationStyle: .sheet)
        )
        .aiChatSupport(
            isPresented: $showFullScreen,
            configuration: persona.makeConfiguration(presentationStyle: .fullScreen)
        )
        .navigationTitle("Presentation")
        .navigationBarTitleDisplayMode(.inline)
    }
}

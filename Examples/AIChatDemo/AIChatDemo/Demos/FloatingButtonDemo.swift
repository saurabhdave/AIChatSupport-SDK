import AIChatSupport
import SwiftUI

/// A faux host screen with the SDK's floating action button overlaid.
struct FloatingButtonDemo: View {
    let persona: DemoPersona

    var body: some View {
        List {
            Section("Your app's content") {
                ForEach(["Orders", "Wishlist", "Account", "Settings"], id: \.self) { row in
                    Label(row, systemImage: "square.grid.2x2")
                }
            }
            Section {
                Text("The floating button at the bottom-right opens the AI chat.")
                    .foregroundStyle(.secondary)
            }
        }
        .aiChatFloatingButton(configuration: persona.makeConfiguration())
        .navigationTitle("Floating Button")
        .navigationBarTitleDisplayMode(.inline)
    }
}

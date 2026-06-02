import AIChatSupport
import SwiftUI

/// Embeds the chat view directly, with no launcher chrome.
struct InlineDemo: View {
    var body: some View {
        // Hide the nav title so the chat's own header is the only header; the back button remains.
        AIChatSupport.makeView(configuration: SampleData.configuration())
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
    }
}

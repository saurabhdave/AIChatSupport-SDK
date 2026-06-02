import AIChatSupport
import SwiftUI

/// Embeds the chat view directly, with no launcher chrome.
struct InlineDemo: View {
    var body: some View {
        AIChatSupport.makeView(configuration: SampleData.configuration())
            .navigationTitle("Inline Embed")
            .navigationBarTitleDisplayMode(.inline)
    }
}

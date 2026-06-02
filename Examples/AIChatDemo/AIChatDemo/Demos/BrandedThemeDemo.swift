import AIChatSupport
import SwiftUI

/// Shows white-labeling via HostAppTheme brand tokens.
struct BrandedThemeDemo: View {
    let persona: DemoPersona

    var body: some View {
        // Hide the nav title so the chat's own header is the only header; the back button remains.
        AIChatSupport.makeView(configuration: persona.makeConfiguration(hostAppTheme: persona.brandTheme))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
    }
}

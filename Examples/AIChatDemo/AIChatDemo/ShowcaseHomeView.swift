import SwiftUI

/// Root menu linking to each integration demo.
struct ShowcaseHomeView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Launchers") {
                    NavigationLink("Floating button") { FloatingButtonDemo() }
                    NavigationLink("Presentation styles") { PresentationDemo() }
                    NavigationLink("Inline embed") { InlineDemo() }
                }
                Section("Customization") {
                    NavigationLink("Branded theme") { BrandedThemeDemo() }
                    NavigationLink("Delegate & events") { DelegateDemo() }
                }
                Section {
                    Text("Runs on the mock provider. Set OPENAI_API_KEY or ANTHROPIC_API_KEY in the scheme to use live streaming.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("AIChatSupport Demo")
        }
    }
}

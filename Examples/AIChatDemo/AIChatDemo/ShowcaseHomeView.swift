import SwiftUI

/// Root menu for one domain, linking to each integration demo.
struct ShowcaseHomeView: View {
    let persona: DemoPersona

    var body: some View {
        NavigationStack {
            List {
                Section("Launchers") {
                    NavigationLink("Floating button") { FloatingButtonDemo(persona: persona) }
                    NavigationLink("Presentation styles") { PresentationDemo(persona: persona) }
                    NavigationLink("Inline embed") { InlineDemo(persona: persona) }
                }
                Section("Customization") {
                    NavigationLink("Branded theme") { BrandedThemeDemo(persona: persona) }
                    NavigationLink("Delegate & events") { DelegateDemo(persona: persona) }
                }
                Section {
                    Text("Same SDK, different context. Runs on the mock provider; set OPENAI_API_KEY or ANTHROPIC_API_KEY in the scheme for live, context-aware streaming.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(persona.tabTitle)
        }
    }
}

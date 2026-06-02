import SwiftUI

@main
struct AIChatDemoApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                Tab(DemoPersona.shopEasy.tabTitle, systemImage: DemoPersona.shopEasy.tabSystemImage) {
                    ShowcaseHomeView(persona: .shopEasy)
                }
                Tab(DemoPersona.wanderly.tabTitle, systemImage: DemoPersona.wanderly.tabSystemImage) {
                    ShowcaseHomeView(persona: .wanderly)
                }
            }
        }
    }
}

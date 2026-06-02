import AIChatSupport
import SwiftUI

/// Shows white-labeling via HostAppTheme brand tokens.
struct BrandedThemeDemo: View {
    private var brand: HostAppTheme {
        HostAppTheme(
            brandPrimaryColor: Color(red: 1.0, green: 0.42, blue: 0.21),
            brandSurfaceColor: Color(red: 0.98, green: 0.96, blue: 0.94),
            brandOnPrimaryColor: .white,
            headingFontWeight: .bold,
            cornerRadiusStyle: .pill
        )
    }

    var body: some View {
        // Hide the nav title so the chat's own header is the only header; the back button remains.
        AIChatSupport.makeView(configuration: SampleData.configuration(hostAppTheme: brand))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
    }
}

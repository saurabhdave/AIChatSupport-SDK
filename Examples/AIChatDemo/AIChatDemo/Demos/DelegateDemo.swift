import AIChatSupport
import SwiftUI

/// Chat alongside a live log of AIChatDelegate callbacks.
struct DelegateDemo: View {
    @State private var delegate = DemoChatDelegate()

    var body: some View {
        VStack(spacing: 0) {
            AIChatSupport.makeView(configuration: SampleData.configuration(delegate: delegate))
                .frame(maxHeight: .infinity)
            Divider()
            eventLog
        }
        // Hide the nav title so the chat's own header is the only header; the back button remains.
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var eventLog: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                if delegate.events.isEmpty {
                    Text("Delegate events will appear here…")
                        .foregroundStyle(.secondary)
                }
                ForEach(delegate.events, id: \.self) { event in
                    Text(event).font(.caption.monospaced())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .frame(height: 160)
        .background(Color(.secondarySystemBackground))
    }
}

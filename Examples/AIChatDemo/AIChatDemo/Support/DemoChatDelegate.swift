import AIChatSupport
import Foundation
import Observation

/// Records SDK lifecycle callbacks into an observable, newest-first event log.
@MainActor
@Observable
final class DemoChatDelegate: AIChatDelegate {

    private(set) var events: [String] = []

    func chatDidSendMessage(_ message: String) { log("Sent: \(message)") }
    func chatDidReceiveResponse(_ response: String) { log("Received (\(response.count) chars)") }
    func chatDidEncounterError(_ error: any Error) { log("Error: \(error.localizedDescription)") }
    func chatDidDismiss() { log("Dismissed") }

    private func log(_ line: String) {
        let time = Date().formatted(date: .omitted, time: .standard)
        events.insert("[\(time)] \(line)", at: 0)
    }
}

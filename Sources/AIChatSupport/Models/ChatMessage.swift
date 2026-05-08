import Foundation

/// A single message in the chat conversation.
public struct ChatMessage: Identifiable, Equatable, Sendable {

    public let id: UUID
    public let role: Role
    public var content: String
    public let timestamp: Date
    public var status: Status
    public var feedback: Feedback?
    public var isStreaming: Bool

    public enum Role: Equatable, Sendable {
        case user
        case assistant
        case system
    }

    public enum Status: Equatable, Sendable {
        case sending
        case sent
        case delivered
        case failed(String)
    }

    public enum Feedback: Equatable, Sendable {
        case positive
        case negative
    }

    public init(
        id: UUID = UUID(),
        role: Role,
        content: String,
        timestamp: Date = Date(),
        status: Status = .sending,
        feedback: Feedback? = nil,
        isStreaming: Bool = false
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.status = status
        self.feedback = feedback
        self.isStreaming = isStreaming
    }

    /// True when this message was sent by the user.
    public var isUser: Bool { role == .user }

    /// True when this message was sent by the assistant.
    public var isAssistant: Bool { role == .assistant }

    /// True when this message failed to send or receive.
    public var isFailed: Bool {
        if case .failed = status { return true }
        return false
    }

    /// Human-readable timestamp: "2:45 PM" today, "Yesterday 2:45 PM", "Monday, Mar 3 2:45 PM", or "Mar 3, 2024 2:45 PM".
    public var formattedTime: String {
        let calendar = Calendar.current
        let now = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"

        if calendar.isDateInToday(timestamp) {
            return timeFormatter.string(from: timestamp)
        } else if calendar.isDateInYesterday(timestamp) {
            return "Yesterday \(timeFormatter.string(from: timestamp))"
        } else if calendar.isDate(timestamp, equalTo: now, toGranularity: .year) {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE, MMM d"
            return "\(dayFormatter.string(from: timestamp)) \(timeFormatter.string(from: timestamp))"
        } else {
            let fullFormatter = DateFormatter()
            fullFormatter.dateFormat = "MMM d, yyyy"
            return "\(fullFormatter.string(from: timestamp)) \(timeFormatter.string(from: timestamp))"
        }
    }

    /// Converts this message to the wire format used by AI providers. Returns nil for system messages.
    public var toAIMessage: AIMessage? {
        guard role != .system else { return nil }
        let wireRole: AIMessage.Role = role == .user ? .user : .assistant
        return AIMessage(role: wireRole, content: content)
    }
}

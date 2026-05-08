import SwiftUI
import Observation

/// The central state machine for a chat session.
@MainActor
@Observable
public final class ChatViewModel {

    // MARK: – Observed State

    public private(set) var messages: [ChatMessage] = []
    public private(set) var isLoading: Bool = false
    public private(set) var isTyping: Bool = false
    public private(set) var error: String? = nil
    public var inputText: String = ""

    // MARK: – Private State

    private let configuration: AIChatConfiguration
    private var isRetryingAfterContextTrim: Bool = false

    // MARK: – Init

    public init(configuration: AIChatConfiguration) {
        self.configuration = configuration
    }

    // MARK: – Computed

    /// True when the user can send a message (non-empty text, not loading).
    public var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }

    /// True when no user messages exist yet and there are suggested prompts to show.
    public var showSuggestedPrompts: Bool {
        !messages.contains(where: { $0.role == .user }) && !configuration.suggestedPrompts.isEmpty
    }

    /// The suggested prompts from configuration, for display in the UI.
    public var suggestedPrompts: [String] { configuration.suggestedPrompts }

    /// The fully resolved visual theme, merging hostAppTheme if set.
    public var resolvedTheme: AIChatTheme {
        configuration.theme.resolved(hostTheme: configuration.hostAppTheme)
    }

    // MARK: – Public Interface

    /// Called when the chat view appears. Delivers staggered welcome messages.
    public func onAppear() async {
        guard messages.isEmpty else { return }
        await deliverWelcomeMessages()
    }

    /// Sends the current inputText as a user message.
    public func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isLoading else { return }
        inputText = ""
        Task { await send(text: text) }
    }

    /// Sends a suggested prompt as if the user typed it.
    public func sendSuggestedPrompt(_ text: String) {
        guard !isLoading else { return }
        Task { await send(text: text) }
    }

    /// Retries sending after a failed bot response.
    public func retry(messageID: UUID) {
        guard let failedIndex = messages.firstIndex(where: { $0.id == messageID && $0.isFailed }) else { return }
        messages.remove(at: failedIndex)

        guard let lastUserMessage = messages.last(where: { $0.role == .user }) else { return }
        Task { await send(text: lastUserMessage.content) }
    }

    /// Records thumbs-up or thumbs-down feedback on a message.
    public func setFeedback(_ feedback: ChatMessage.Feedback, for messageID: UUID) {
        guard let index = messages.firstIndex(where: { $0.id == messageID }) else { return }
        messages[index].feedback = feedback
    }

    /// Clears the current error banner.
    public func clearError() { error = nil }

    /// Removes all messages and resets conversation state.
    public func clearConversation() {
        messages = []
        error = nil
        inputText = ""
    }

    // MARK: – Private

    private func send(text: String) async {
        let userMessage = ChatMessage(role: .user, content: text, status: .sent)
        withAnimation(.spring(duration: 0.35)) {
            messages.append(userMessage)
        }
        configuration.delegate?.chatDidSendMessage(text)
        await streamBotResponse(userText: text)
    }

    private func deliverWelcomeMessages() async {
        for welcome in configuration.welcomeMessages {
            if welcome.delay > 0 {
                try? await Task.sleep(for: .seconds(welcome.delay))
            }
            let msg = ChatMessage(role: .assistant, content: welcome.text, status: .delivered)
            withAnimation(.spring(duration: 0.35)) {
                messages.append(msg)
            }
        }
    }

    private func buildSystemPrompt() -> String {
        let contextBlock = configuration.appContext.buildSystemPromptBlock()
        let custom = configuration.systemPrompt

        if contextBlock.isEmpty {
            return custom
        } else if custom.isEmpty {
            return contextBlock
        } else {
            return "\(contextBlock)\n\n\(custom)"
        }
    }

    private func buildContext() -> [AIMessage] {
        let maxMessages = configuration.maxContextTurns * 2
        let eligible = messages.filter { $0.role != .system }
        let trimmed = eligible.suffix(maxMessages)
        return trimmed.compactMap { $0.toAIMessage }
    }

    private func streamBotResponse(userText: String) async {
        isLoading = true

        if configuration.showTypingIndicator {
            withAnimation(.spring(duration: 0.35)) { isTyping = true }
            try? await Task.sleep(for: .milliseconds(700))
            withAnimation(.spring(duration: 0.35)) { isTyping = false }
        }

        var placeholder = ChatMessage(
            role: .assistant,
            content: "",
            status: .sending,
            isStreaming: true
        )
        withAnimation(.spring(duration: 0.35)) {
            messages.append(placeholder)
        }

        let placeholderID = placeholder.id
        guard let placeholderIndex = messages.firstIndex(where: { $0.id == placeholderID }) else {
            isLoading = false
            return
        }

        do {
            let stream = try await configuration.provider.engine.streamResponse(
                messages: buildContext(),
                systemPrompt: buildSystemPrompt()
            )

            for try await token in stream {
                guard let idx = messages.firstIndex(where: { $0.id == placeholderID }) else { break }
                messages[idx].content += token
            }

            if let idx = messages.firstIndex(where: { $0.id == placeholderID }) {
                messages[idx].isStreaming = false
                messages[idx].status = .delivered
                let finalContent = messages[idx].content
                configuration.delegate?.chatDidReceiveResponse(finalContent)
            }

        } catch AIProviderError.contextLengthExceeded where !isRetryingAfterContextTrim {
            isRetryingAfterContextTrim = true
            if let idx = messages.firstIndex(where: { $0.id == placeholderID }) {
                messages.remove(at: idx)
            }
            let nonSystemMessages = messages.filter { $0.role != .system }
            if nonSystemMessages.count >= 4 {
                let toRemove = 4
                var removed = 0
                messages.removeAll { msg in
                    guard removed < toRemove, msg.role != .system else { return false }
                    removed += 1
                    return true
                }
            }
            isLoading = false
            isRetryingAfterContextTrim = false
            await streamBotResponse(userText: userText)
            return

        } catch {
            let errorMessage = (error as? AIProviderError)?.localizedDescription ?? error.localizedDescription
            if let idx = messages.firstIndex(where: { $0.id == placeholderID }) {
                messages[idx].isStreaming = false
                messages[idx].status = .failed(errorMessage)
            }
            self.error = errorMessage
            configuration.delegate?.chatDidEncounterError(error)
        }

        isRetryingAfterContextTrim = false
        isLoading = false
    }
}

import AIChatSupport
import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Bridges Apple's on-device **Foundation Models** LLM to the SDK through the `.custom` provider —
/// the model runs entirely on the device, no network and no API key.
///
/// For a genuinely *custom-trained* variant, load a trained adapter with
/// `SystemLanguageModel(adapter:)` and pass that model into `LanguageModelSession(model:)`.
/// This demo uses the default system model.
struct OnDeviceModelProvider: AIProviderProtocol {

    func streamResponse(
        messages: [AIMessage],
        systemPrompt: String
    ) async throws(AIProviderError) -> AsyncThrowingStream<String, any Error> {
        #if canImport(FoundationModels)
        let availability = SystemLanguageModel.default.availability
        guard case .available = availability else {
            throw AIProviderError.serverError(
                statusCode: 0,
                message: "On-device model unavailable. \(Self.reason(for: availability))"
            )
        }

        let instructions = systemPrompt.isEmpty ? "You are a helpful, concise assistant." : systemPrompt
        let prompt = Self.buildPrompt(from: messages)

        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let session = LanguageModelSession(instructions: instructions)
                    // Foundation Models streams *cumulative* snapshots; the SDK consumes deltas,
                    // so yield only the newly-appended suffix of each snapshot.
                    var previous = ""
                    for try await snapshot in session.streamResponse(to: prompt) {
                        let text = snapshot.content
                        let delta = text.hasPrefix(previous) ? String(text.dropFirst(previous.count)) : text
                        previous = text
                        if !delta.isEmpty { continuation.yield(delta) }
                    }
                    continuation.finish()
                } catch is CancellationError {
                    continuation.finish(throwing: AIProviderError.cancelled)
                } catch {
                    continuation.finish(throwing: AIProviderError.serverError(statusCode: 0, message: error.localizedDescription))
                }
            }
            // The SDK's cancel() closes the stream, which cancels generation.
            continuation.onTermination = { _ in task.cancel() }
        }
        #else
        throw AIProviderError.serverError(statusCode: 0, message: "FoundationModels is unavailable in this build.")
        #endif
    }

    /// Flattens the recent conversation into a single prompt (a fresh session is used per call).
    private static func buildPrompt(from messages: [AIMessage]) -> String {
        let lines = messages.suffix(12).map { message -> String in
            switch message.role {
            case .user: return "User: \(message.content)"
            case .assistant: return "Assistant: \(message.content)"
            case .system: return message.content
            }
        }
        let joined = lines.joined(separator: "\n")
        return joined.isEmpty ? "Hello" : joined
    }

    #if canImport(FoundationModels)
    private static func reason(for availability: SystemLanguageModel.Availability) -> String {
        guard case .unavailable(let reason) = availability else { return "" }
        switch reason {
        case .deviceNotEligible:
            return "This device doesn't support Apple Intelligence."
        case .appleIntelligenceNotEnabled:
            return "Turn on Apple Intelligence in Settings to use the on-device model."
        case .modelNotReady:
            return "The on-device model is still downloading or warming up — try again shortly."
        @unknown default:
            return "The on-device model is not ready."
        }
    }
    #endif
}

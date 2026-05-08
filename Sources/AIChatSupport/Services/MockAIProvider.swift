import Foundation

final class MockAIProvider: AIProviderProtocol, Sendable {

    private let config: MockAIConfig
    private let responseIndex: ResponseIndex

    init(config: MockAIConfig) {
        self.config = config
        self.responseIndex = ResponseIndex()
    }

    func streamResponse(
        messages: [AIMessage],
        systemPrompt: String
    ) async throws(AIProviderError) -> AsyncThrowingStream<String, any Error> {
        let cfg = config
        let index = await responseIndex.next(count: cfg.responses.count)
        let response = cfg.responses.isEmpty ? MockAIConfig.defaultResponses[0] : cfg.responses[index]

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    try await Task.sleep(for: .seconds(cfg.streamDelay))
                } catch {
                    continuation.finish(throwing: AIProviderError.cancelled)
                    return
                }

                if cfg.shouldFail {
                    continuation.finish(throwing: AIProviderError.networkError(underlying: "Simulated network failure"))
                    return
                }

                let words = response.components(separatedBy: " ")
                for (i, word) in words.enumerated() {
                    let token = i == 0 ? word : " \(word)"
                    continuation.yield(token)
                    do {
                        try await Task.sleep(for: .seconds(cfg.tokenDelay))
                    } catch {
                        continuation.finish(throwing: AIProviderError.cancelled)
                        return
                    }
                }
                continuation.finish()
            }
        }
    }
}

/// Actor that safely tracks the cycling response index.
private actor ResponseIndex {
    private var current: Int = 0

    func next(count: Int) -> Int {
        guard count > 0 else { return 0 }
        let index = current % count
        current += 1
        return index
    }
}

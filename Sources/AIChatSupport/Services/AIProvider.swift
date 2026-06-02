import Foundation

/// A wire-format message exchanged with AI providers.
public struct AIMessage: Sendable, Codable {
    public let role: Role
    public let content: String

    public enum Role: String, Sendable, Codable {
        case user
        case assistant
        case system
    }

    public init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
}

/// Errors that AI providers can throw.
public enum AIProviderError: LocalizedError, Sendable {
    case invalidAPIKey
    case networkError(underlying: String)
    case rateLimited(retryAfter: TimeInterval?)
    case contextLengthExceeded
    case serverError(statusCode: Int, message: String)
    case decodingError
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "The API key is invalid or missing. Please check your configuration."
        case .networkError(let underlying):
            return "A network error occurred: \(underlying)"
        case .rateLimited(let retryAfter):
            if let seconds = retryAfter {
                return "Rate limited. Retry after \(Int(seconds)) seconds."
            }
            return "Rate limited. Please wait before sending another message."
        case .contextLengthExceeded:
            return "The conversation is too long. Older messages have been trimmed."
        case .serverError(let code, let message):
            return "Server error \(code): \(message)"
        case .decodingError:
            return "The server returned an unexpected response."
        case .cancelled:
            return "The request was cancelled."
        }
    }
}

/// A streaming AI provider that yields text tokens over an AsyncThrowingStream.
public protocol AIProviderProtocol: Sendable {
    func streamResponse(
        messages: [AIMessage],
        systemPrompt: String
    ) async throws(AIProviderError) -> AsyncThrowingStream<String, any Error>
}

/// Configuration for the OpenAI chat completions API.
public struct OpenAIConfig: Sendable {
    public var apiKey: String
    /// Default: "gpt-4o"
    public var model: String
    /// Default: 1024
    public var maxTokens: Int
    /// Default: 0.7
    public var temperature: Double
    /// Default: "https://api.openai.com/v1"
    public var baseURL: String
    public var organizationID: String?

    public init(
        apiKey: String,
        model: String = "gpt-4o",
        maxTokens: Int = 1024,
        temperature: Double = 0.7,
        baseURL: String = "https://api.openai.com/v1",
        organizationID: String? = nil
    ) {
        self.apiKey = apiKey
        self.model = model
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.baseURL = baseURL
        self.organizationID = organizationID
    }
}

/// Configuration for the Anthropic Messages API.
public struct AnthropicConfig: Sendable {
    public var apiKey: String
    /// Default: "claude-opus-4-8"
    public var model: String
    /// Default: 1024
    public var maxTokens: Int

    public init(
        apiKey: String,
        model: String = "claude-opus-4-8",
        maxTokens: Int = 1024
    ) {
        self.apiKey = apiKey
        self.model = model
        self.maxTokens = maxTokens
    }
}

/// Configuration for the deterministic mock provider used in development and tests.
public struct MockAIConfig: Sendable {

    /// Five varied customer-support-style default responses.
    public static let defaultResponses: [String] = [
        "Thanks for reaching out! I'd be happy to help you with that. Could you give me a bit more detail so I can find the best solution for you?",
        "Great question! Let me look into that for you. Based on what you've shared, here are a few things that might help resolve the issue quickly.",
        "I completely understand your concern. This is something we take very seriously, and I want to make sure we get this sorted out for you right away.",
        "Absolutely! That feature is available in your current plan. Here's how you can access it: navigate to Settings → Features, then toggle the option you need.",
        "Thank you for your patience! I've reviewed your account and everything looks good on our end. Here's a summary of what I found and the next steps."
    ]

    /// Response strings cycled through in order.
    public var responses: [String]
    /// Simulated network delay before the stream begins.
    public var streamDelay: TimeInterval
    /// Per-token delay to simulate typing speed.
    public var tokenDelay: TimeInterval
    /// When true, throws .networkError after streamDelay instead of streaming.
    public var shouldFail: Bool

    public init(
        responses: [String] = MockAIConfig.defaultResponses,
        streamDelay: TimeInterval = 0.5,
        tokenDelay: TimeInterval = 0.03,
        shouldFail: Bool = false
    ) {
        self.responses = responses
        self.streamDelay = streamDelay
        self.tokenDelay = tokenDelay
        self.shouldFail = shouldFail
    }
}

/// The top-level AI provider selection.
public enum AIProvider: Sendable {
    case openAI(OpenAIConfig)
    case anthropic(AnthropicConfig)
    case custom(any AIProviderProtocol)
    case mock(MockAIConfig)

    /// Returns the concrete provider implementation for this configuration.
    var engine: any AIProviderProtocol {
        switch self {
        case .openAI(let config): return OpenAIProvider(config: config)
        case .anthropic(let config): return AnthropicProvider(config: config)
        case .custom(let provider): return provider
        case .mock(let config): return MockAIProvider(config: config)
        }
    }
}

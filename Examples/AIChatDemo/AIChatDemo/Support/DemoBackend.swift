import AIChatSupport
import Foundation

/// Chooses the AI provider for every demo screen.
///
/// Runs on the bundled mock provider by default — no API key required. To try live streaming,
/// set `OPENAI_API_KEY` or `ANTHROPIC_API_KEY` in the Run scheme's environment
/// (Product ▸ Scheme ▸ Edit Scheme… ▸ Run ▸ Arguments ▸ Environment Variables).
enum DemoBackend {
    static var provider: AIProvider {
        let env = ProcessInfo.processInfo.environment
        if let key = env["OPENAI_API_KEY"], !key.isEmpty {
            return .openAI(OpenAIConfig(apiKey: key))
        }
        if let key = env["ANTHROPIC_API_KEY"], !key.isEmpty {
            return .anthropic(AnthropicConfig(apiKey: key))
        }
        return .mock(MockAIConfig())
    }
}

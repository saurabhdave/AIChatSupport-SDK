import Foundation

final class OpenAIProvider: AIProviderProtocol, Sendable {

    private let config: OpenAIConfig

    init(config: OpenAIConfig) {
        self.config = config
    }

    func streamResponse(
        messages: [AIMessage],
        systemPrompt: String
    ) async throws(AIProviderError) -> AsyncThrowingStream<String, any Error> {
        let request: URLRequest
        do {
            request = try buildRequest(messages: messages, systemPrompt: systemPrompt)
        } catch let error as AIProviderError {
            throw error
        } catch {
            throw AIProviderError.networkError(underlying: error.localizedDescription)
        }

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse else {
                        continuation.finish(throwing: AIProviderError.networkError(underlying: "Invalid response type"))
                        return
                    }

                    if httpResponse.statusCode != 200 {
                        var bodyData = Data()
                        for try await byte in bytes {
                            bodyData.append(byte)
                        }
                        let bodyString = String(data: bodyData, encoding: .utf8) ?? ""
                        continuation.finish(throwing: mapHTTPError(statusCode: httpResponse.statusCode, body: bodyString, headers: httpResponse.allHeaderFields))
                        return
                    }

                    for try await line in bytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let data = String(line.dropFirst(6))
                        guard data != "[DONE]" else { break }

                        if let tokenData = data.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: tokenData) as? [String: Any],
                           let choices = json["choices"] as? [[String: Any]],
                           let delta = choices.first?["delta"] as? [String: Any],
                           let text = delta["content"] as? String {
                            continuation.yield(text)
                        }
                    }
                    continuation.finish()
                } catch is CancellationError {
                    continuation.finish(throwing: AIProviderError.cancelled)
                } catch let error as AIProviderError {
                    continuation.finish(throwing: error)
                } catch {
                    continuation.finish(throwing: AIProviderError.networkError(underlying: error.localizedDescription))
                }
            }
        }
    }

    private func buildRequest(messages: [AIMessage], systemPrompt: String) throws -> URLRequest {
        guard let url = URL(string: "\(config.baseURL)/chat/completions") else {
            throw AIProviderError.networkError(underlying: "Invalid base URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")

        if let orgID = config.organizationID {
            request.setValue(orgID, forHTTPHeaderField: "X-OpenAI-Organization")
        }

        var wireMessages: [[String: String]] = []
        if !systemPrompt.isEmpty {
            wireMessages.append(["role": "system", "content": systemPrompt])
        }
        for message in messages {
            wireMessages.append(["role": message.role.rawValue, "content": message.content])
        }

        let body: [String: Any] = [
            "model": config.model,
            "messages": wireMessages,
            "max_tokens": config.maxTokens,
            "temperature": config.temperature,
            "stream": true
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    private func mapHTTPError(statusCode: Int, body: String, headers: [AnyHashable: Any]) -> AIProviderError {
        switch statusCode {
        case 401:
            return .invalidAPIKey
        case 429:
            var retryAfter: TimeInterval? = nil
            if let retryHeader = headers["Retry-After"] as? String,
               let seconds = TimeInterval(retryHeader) {
                retryAfter = seconds
            }
            return .rateLimited(retryAfter: retryAfter)
        case 400:
            if body.contains("context_length_exceeded") {
                return .contextLengthExceeded
            }
            return .serverError(statusCode: statusCode, message: body)
        case 500...599:
            let message = extractErrorMessage(from: body) ?? "Internal server error"
            return .serverError(statusCode: statusCode, message: message)
        default:
            return .serverError(statusCode: statusCode, message: body)
        }
    }

    private func extractErrorMessage(from body: String) -> String? {
        guard let data = body.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let error = json["error"] as? [String: Any],
              let message = error["message"] as? String else {
            return nil
        }
        return message
    }
}

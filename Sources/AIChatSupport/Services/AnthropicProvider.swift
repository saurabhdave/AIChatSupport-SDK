import Foundation

final class AnthropicProvider: AIProviderProtocol, Sendable {

    private let config: AnthropicConfig
    private let endpoint = "https://api.anthropic.com/v1/messages"
    private let anthropicVersion = "2023-06-01"

    init(config: AnthropicConfig) {
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

                    var currentEvent: String = ""

                    for try await line in bytes.lines {
                        if line.hasPrefix("event: ") {
                            currentEvent = String(line.dropFirst(7)).trimmingCharacters(in: .whitespaces)
                        } else if line.hasPrefix("data: ") {
                            let dataString = String(line.dropFirst(6))

                            switch currentEvent {
                            case "content_block_delta":
                                if let data = dataString.data(using: .utf8),
                                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                                   let delta = json["delta"] as? [String: Any],
                                   let text = delta["text"] as? String {
                                    continuation.yield(text)
                                }
                            case "message_stop":
                                continuation.finish()
                                return
                            case "error":
                                if let data = dataString.data(using: .utf8),
                                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                                   let error = json["error"] as? [String: Any],
                                   let message = error["message"] as? String {
                                    continuation.finish(throwing: AIProviderError.serverError(statusCode: 0, message: message))
                                } else {
                                    continuation.finish(throwing: AIProviderError.decodingError)
                                }
                                return
                            default:
                                break
                            }
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
        guard let url = URL(string: endpoint) else {
            throw AIProviderError.networkError(underlying: "Invalid endpoint URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(config.apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(anthropicVersion, forHTTPHeaderField: "anthropic-version")

        let wireMessages: [[String: String]] = messages.compactMap { msg in
            guard msg.role == .user || msg.role == .assistant else { return nil }
            return ["role": msg.role.rawValue, "content": msg.content]
        }

        var body: [String: Any] = [
            "model": config.model,
            "max_tokens": config.maxTokens,
            "messages": wireMessages,
            "stream": true
        ]
        if !systemPrompt.isEmpty {
            body["system"] = systemPrompt
        }

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
            if body.contains("context_length_exceeded") || body.contains("too many tokens") {
                return .contextLengthExceeded
            }
            return .serverError(statusCode: statusCode, message: body)
        case 500...599:
            return .serverError(statusCode: statusCode, message: body)
        default:
            return .serverError(statusCode: statusCode, message: body)
        }
    }
}

import Foundation

enum CoachAPIClient {
    private static let chatModel = "deepseek-chat"
    private static let maxAttempts = 3

    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 45
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        return URLSession(configuration: config)
    }()

    private struct ChatCompletionResponse: Decodable {
        struct Choice: Decodable {
            struct Message: Decodable {
                let content: String
            }
            let message: Message
        }
        let choices: [Choice]
    }

    private static func chatJSON<T: Decodable>(
        systemPrompt: String,
        userPayload: [String: Any]
    ) async throws -> T {
        var lastError: Error = URLError(.unknown)

        for attempt in 1...maxAttempts {
            do {
                return try await performChatJSON(systemPrompt: systemPrompt, userPayload: userPayload)
            } catch {
                lastError = error
                guard attempt < maxAttempts, shouldRetry(error) else { throw error }
                try await Task.sleep(nanoseconds: UInt64(attempt) * 1_000_000_000)
            }
        }

        throw lastError
    }

    private static func performChatJSON<T: Decodable>(
        systemPrompt: String,
        userPayload: [String: Any]
    ) async throws -> T {
        let url = HyperliquidDrinkSmarterConfig.chatURL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let userJSON = try JSONSerialization.data(withJSONObject: userPayload)
        let userString = String(data: userJSON, encoding: .utf8) ?? "{}"

        let body: [String: Any] = [
            "model": chatModel,
            "response_format": ["type": "json_object"],
            "temperature": 0.5,
            "max_tokens": 768,
            "stream": false,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userString],
            ],
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse, userInfo: ["status": http.statusCode])
        }

        let completion = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let content = completion.choices.first?.message.content else {
            throw URLError(.cannotDecodeRawData)
        }

        return try decodeJSONObject(T.self, from: content)
    }

    private static func shouldRetry(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut, .networkConnectionLost, .notConnectedToInternet,
                 .cannotConnectToHost, .dnsLookupFailed, .cannotFindHost:
                return true
            case .badServerResponse:
                if let status = urlError.userInfo["status"] as? Int, status >= 500 {
                    return true
                }
            default:
                break
            }
        }
        return false
    }

    private static func decodeJSONObject<T: Decodable>(_ type: T.Type, from content: String) throws -> T {
        let sanitized = sanitizeJSONContent(content)
        guard let data = sanitized.data(using: .utf8) else {
            throw URLError(.cannotDecodeRawData)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            if let extracted = extractFirstJSONObject(from: sanitized),
               let extractedData = extracted.data(using: .utf8) {
                return try JSONDecoder().decode(T.self, from: extractedData)
            }
            throw error
        }
    }

    private static func sanitizeJSONContent(_ content: String) -> String {
        var text = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("```") {
            text = text.replacingOccurrences(of: "```json", with: "")
            text = text.replacingOccurrences(of: "```", with: "")
            text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return text
    }

    private static func extractFirstJSONObject(from text: String) -> String? {
        guard let start = text.firstIndex(of: "{"),
              let end = text.lastIndex(of: "}") else { return nil }
        return String(text[start...end])
    }

    static func estimateNutrition(description: String, portionHint: String?) async throws -> NutritionEstimate {
        let input: [String: Any] = [
            "descriptionText": description,
            "portionHint": portionHint ?? "medium",
        ]
        return try await chatJSON(systemPrompt: CoachAPIPrompts.nutrition, userPayload: input)
    }

    static func askCoach(question: String, context: [String: Any]) async throws -> CoachAdviceDTO {
        let input: [String: Any] = [
            "question": question,
            "context": context,
        ]
        return try await chatJSON(systemPrompt: CoachAPIPrompts.coach, userPayload: input)
    }

    static func dailyInsight(input: [String: Any]) async throws -> DailyInsightDTO {
        return try await chatJSON(systemPrompt: CoachAPIPrompts.dailyInsight, userPayload: input)
    }

    static func weeklySummary(input: [String: Any]) async throws -> WeeklySummaryDTO {
        return try await chatJSON(systemPrompt: CoachAPIPrompts.weeklySummary, userPayload: input)
    }
}

import Foundation

enum HyperliquidDrinkSmarterConfig {
    static var apiBaseURL: URL {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "HyperliquidDrinkSmarterAPIBaseURL") as? String,
              let url = URL(string: raw), url.scheme != nil else {
            return URL(string: "https://hyperliquiddrinksmarter-api-proxy.invalid")!
        }
        return url
    }

    static var isAPIConfigured: Bool {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "HyperliquidDrinkSmarterAPIBaseURL") as? String,
              let host = URL(string: raw)?.host else { return false }
        return !raw.contains("YOUR-ACCOUNT") && !host.hasSuffix(".invalid")
    }

    static var chatURL: URL { apiBaseURL.appending(path: "chat") }

    static var healthURL: URL { apiBaseURL.appending(path: "health") }
}

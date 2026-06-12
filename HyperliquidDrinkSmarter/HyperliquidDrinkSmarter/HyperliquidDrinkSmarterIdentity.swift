import Foundation

enum HyperliquidDrinkSmarterIdentity {
    static let displayName = "Hyperliquid Drink Smarter"
    static let appName = displayName
    static let appStoreName = displayName
    static let slogan = "Drink smarter, eat smarter — your AI hydration & nutrition coach."

    static let bundleIdentifier = "com.hyperliquiddrinksmarter.app"
    static let bundlePrefix = "com.hyperliquiddrinksmarter"
    static let marketingVersion = "1.0.0"
    static let buildNumber = "1"

    static let defaultAPIBaseURL = "https://hyperliquiddrinksmarter-api-proxy.southwickbethany050.workers.dev"

    static let privacyPolicyURL = "https://hyperliquiddrinksmarter3121.info/privacy/"
    static let termsOfUseURL = "https://hyperliquiddrinksmarter3121.info/terms/"
    static let supportEmail = "support@hyperliquiddrinksmarter3121.info"

    static var privacyPolicyLink: URL { URL(string: privacyPolicyURL)! }
    static var termsOfUseLink: URL { URL(string: termsOfUseURL)! }
    static var supportMailtoLink: URL { URL(string: "mailto:\(supportEmail)")! }

    static let medicalDisclaimerShort = "\(displayName) provides general wellness information and is not a substitute for professional medical or nutritional advice."
    static let aiDataDisclosure = "When enabled, meal descriptions, coach questions, and aggregate daily or weekly totals (hydration ml, calories, goals) are sent over HTTPS to our server proxy, which forwards them to a third-party AI API. No account, device ID, or location is included."
    static let aiOptInNotice = "AI Coach is off by default. Nothing is sent unless you turn it on. See Privacy Policy for full details."

    static let version: String = {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(v) (\(b))"
    }()
}

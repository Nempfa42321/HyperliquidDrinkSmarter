import Foundation

enum HyperliquidDrinkSmarterTab: String, CaseIterable, Identifiable {
    case today
    case log
    case coach
    case trends

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: return "Today"
        case .log: return "Log"
        case .coach: return "Coach"
        case .trends: return "Trends"
        }
    }

    var systemImage: String {
        switch self {
        case .today: return "drop.fill"
        case .log: return "list.bullet"
        case .coach: return "message"
        case .trends: return "chart.line.uptrend.xyaxis"
        }
    }
}

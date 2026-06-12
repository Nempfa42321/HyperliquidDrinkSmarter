import SwiftUI
import SwiftData

@main
struct HyperliquidDrinkSmarterApp: App {
    @AppStorage("hyperliquiddrinksmarter.settings.onboarding.completed") private var didCompleteOnboarding = false
    @AppStorage("hyperliquiddrinksmarter.settings.appearance") private var appearance = "system"

    private var resolvedColorScheme: ColorScheme? {
        switch appearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if didCompleteOnboarding {
                    HyperliquidDrinkSmarterShellView()
                } else {
                    HyperliquidDrinkSmarterOnboardingView {
                        didCompleteOnboarding = true
                    }
                }
            }
            .preferredColorScheme(resolvedColorScheme)
        }
        .modelContainer(for: [
            IntakeEntry.self,
            DailyGoalSettings.self,
            DailyInsightRecord.self,
            CoachThreadMessage.self,
            WeeklySummaryRecord.self
        ])
    }
}

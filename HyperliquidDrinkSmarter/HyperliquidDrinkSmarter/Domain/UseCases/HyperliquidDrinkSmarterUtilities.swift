import Foundation
import UserNotifications

enum HyperliquidDrinkSmarterSettingsKeys {
    static let volumeUnit = "hyperliquiddrinksmarter.settings.units.volume"
    static let remindersEnabled = "hyperliquiddrinksmarter.settings.reminders.enabled"
    static let remindersIntervalHours = "hyperliquiddrinksmarter.settings.reminders.intervalHours"
    static let remindersStartHour = "hyperliquiddrinksmarter.settings.reminders.startHour"
    static let remindersEndHour = "hyperliquiddrinksmarter.settings.reminders.endHour"
}

enum VolumeFormatting {
    static let mlPerOz = 29.5735295625

    static func isOz(_ unit: String) -> Bool { unit == "oz" }

    static func mlToDisplay(_ ml: Double, unit: String) -> Double {
        isOz(unit) ? ml / mlPerOz : ml
    }

    static func displayToMl(_ value: Double, unit: String) -> Double {
        isOz(unit) ? value * mlPerOz : value
    }

    static func formatVolume(ml: Double, unit: String, decimals: Int = 0) -> String {
        let value = mlToDisplay(ml, unit: unit)
        let suffix = isOz(unit) ? "oz" : "ml"
        if decimals == 0 {
            return "\(Int(value.rounded())) \(suffix)"
        }
        return String(format: "%.\(decimals)f \(suffix)", value)
    }

    static func formatVolumeNumber(_ ml: Double, unit: String) -> String {
        let value = mlToDisplay(ml, unit: unit)
        if isOz(unit) {
            return String(format: "%.0f", value.rounded())
        }
        return String(format: "%.0f", value)
    }

    static func unitSuffix(_ unit: String) -> String {
        isOz(unit) ? "oz" : "ml"
    }
}

struct ComputeHydrationStreakUseCase {
    func currentStreak(intakeRepo: IntakeRepository, goalMl: Double) -> Int {
        var streak = 0
        let calendar = Calendar.current

        for offset in 0..<365 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: .now) else { break }
            let entries = intakeRepo.fetchEntries(for: day)
            let totals = ComputeDailyTotalsUseCase().execute(entries)
            if totals.hydrationMl >= goalMl * 0.95 {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }
}

enum HydrationReminderScheduler {
    private static let identifierPrefix = "hyperliquiddrinksmarter.hydration.reminder."

    static func schedule(enabled: Bool, intervalHours: Int, startHour: Int, endHour: Int) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ids = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(identifierPrefix) }
            center.removePendingNotificationRequests(withIdentifiers: ids)

            guard enabled, intervalHours > 0 else { return }

            let safeStart = min(max(startHour, 0), 23)
            let safeEnd = min(max(endHour, safeStart), 23)
            let step = max(1, intervalHours)

            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                guard granted else { return }

                let content = UNMutableNotificationContent()
                content.title = HyperliquidDrinkSmarterIdentity.displayName
                content.body = "Time for a small sip?"
                content.sound = .default

                var hour = safeStart
                var index = 0
                while hour <= safeEnd {
                    var components = DateComponents()
                    components.hour = hour
                    components.minute = 0

                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                    let request = UNNotificationRequest(
                        identifier: "\(identifierPrefix)\(index)",
                        content: content,
                        trigger: trigger
                    )
                    center.add(request)
                    hour += step
                    index += 1
                }
            }
        }
    }
}

enum AICoachUserMessages {
    static func estimateFailure(isAPIConfigured: Bool) -> String {
        if !isAPIConfigured {
            return "AI Coach isn't available in this build yet. Enter nutrition manually, or try again later."
        }
        return "Couldn't reach AI Coach. Check your internet connection and try again."
    }

    static func coachFailure(isAPIConfigured: Bool) -> String {
        if !isAPIConfigured {
            return "AI Coach isn't available in this build yet. Enable it in Settings once connected."
        }
        return "AI Coach couldn't respond — the server may be busy. Wait a moment and tap your question again."
    }
}

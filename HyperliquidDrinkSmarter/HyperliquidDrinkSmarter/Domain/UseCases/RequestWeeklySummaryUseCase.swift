import Foundation

struct RequestWeeklySummaryUseCase {
    private let cache: InsightCacheRepository
    private let goalsRepo: GoalsRepository
    private let intakeRepo: IntakeRepository

    init(cache: InsightCacheRepository, goalsRepo: GoalsRepository, intakeRepo: IntakeRepository) {
        self.cache = cache
        self.goalsRepo = goalsRepo
        self.intakeRepo = intakeRepo
    }

    func getWeeklySummary(aiEnabled: Bool, weekStart: Date, dailyData: [(date: Date, hydration: Double, goal: Double, cals: Int)]) async -> WeeklySummaryRecord {
        if let cached = cache.weekly(for: weekStart) {
            return cached
        }

        if aiEnabled, !dailyData.isEmpty {
            do {
                let payloadDaily = dailyData.map { item in
                    [
                        "date": ISO8601DateFormatter().string(from: item.date),
                        "hydrationMl": item.hydration,
                        "goalMl": item.goal,
                        "calories": item.cals
                    ]
                }

                let input: [String: Any] = [
                    "weekStart": ISO8601DateFormatter().string(from: weekStart),
                    "dailyTotals": payloadDaily,
                    "goalMl": dailyData.first?.goal ?? 2500
                ]

                let dto: WeeklySummaryDTO = try await CoachAPIClient.weeklySummary(input: input)

                let record = WeeklySummaryRecord(
                    weekStart: weekStart,
                    headline: dto.headline,
                    insightText: dto.insightText,
                    observations: dto.observations,
                    disclaimer: dto.disclaimer.isEmpty ? HyperliquidDrinkSmarterIdentity.medicalDisclaimerShort : dto.disclaimer
                )
                cache.saveWeekly(record)
                return record
            } catch {
            }
        }

        return getOfflineSummary(weekStart: weekStart, dailyData: dailyData)
    }

    func getOfflineSummary(weekStart: Date, dailyData: [(date: Date, hydration: Double, goal: Double, cals: Int)]) -> WeeklySummaryRecord {
        let avg = dailyData.isEmpty ? 0 : Int(dailyData.map { $0.hydration }.reduce(0, +) / Double(dailyData.count))
        let best = dailyData.max(by: { $0.hydration < $1.hydration })?.hydration ?? 0

        let observations = [
            "Average intake this week: \(avg) ml.",
            best > 0 ? "Your best day reached \(Int(best)) ml." : "",
            "Weekends often trend lower — try a morning reminder."
        ].filter { !$0.isEmpty }

        return WeeklySummaryRecord(
            weekStart: weekStart,
            headline: "Weekly snapshot",
            insightText: "You logged \(dailyData.count) days. Local calculation (AI summaries available when enabled).",
            observations: observations,
            disclaimer: HyperliquidDrinkSmarterIdentity.medicalDisclaimerShort
        )
    }
}

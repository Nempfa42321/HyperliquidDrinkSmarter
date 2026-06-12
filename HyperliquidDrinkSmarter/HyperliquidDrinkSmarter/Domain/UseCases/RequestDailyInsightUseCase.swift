import Foundation

struct RequestDailyInsightUseCase {
    private let cache: InsightCacheRepository
    private let goalsRepo: GoalsRepository
    private let intakeRepo: IntakeRepository
    private let offline = OfflineInsightHeuristics()

    init(cache: InsightCacheRepository, goalsRepo: GoalsRepository, intakeRepo: IntakeRepository) {
        self.cache = cache
        self.goalsRepo = goalsRepo
        self.intakeRepo = intakeRepo
    }

    func getTodayInsight(aiEnabled: Bool, forceRefresh: Bool = false) async -> DailyInsightRecord {
        let today = Calendar.current.startOfDay(for: .now)
        if !forceRefresh, let cached = cache.dailyInsight(for: today) {
            return cached
        }

        let settings = goalsRepo.current()
        let entries = intakeRepo.fetchEntries(for: .now)
        let totals = ComputeDailyTotalsUseCase().execute(entries)

        if aiEnabled {
            do {
                let streak = ComputeHydrationStreakUseCase().currentStreak(
                    intakeRepo: intakeRepo,
                    goalMl: settings.hydrationGoalMl
                )
                let input: [String: Any] = [
                    "date": ISO8601DateFormatter().string(from: today),
                    "hydrationMl": totals.hydrationMl,
                    "hydrationGoalMl": settings.hydrationGoalMl,
                    "meals": entries.filter { $0.kind == .meal }.map { [
                        "description": $0.mealDescription ?? "",
                        "calories": $0.estimatedCalories ?? 0
                    ] },
                    "streakDays": streak
                ]

                let dto: DailyInsightDTO = try await CoachAPIClient.dailyInsight(input: input)

                let record = DailyInsightRecord(
                    date: today,
                    headline: dto.headline,
                    insightText: dto.insightText,
                    hydrationAdvice: dto.hydrationAdvice,
                    nutritionTip: dto.nutritionTip,
                    encouragement: dto.encouragement,
                    disclaimer: dto.disclaimer.isEmpty ? HyperliquidDrinkSmarterIdentity.medicalDisclaimerShort : dto.disclaimer,
                    isAIGenerated: true
                )
                cache.saveDaily(record)
                return record
            } catch {
            }
        }

        let record = offline.dailyInsight(
            currentMl: totals.hydrationMl,
            goalMl: settings.hydrationGoalMl,
            calories: totals.calories,
            trackCalories: settings.trackCalories
        )
        cache.saveDaily(record)
        return record
    }
}

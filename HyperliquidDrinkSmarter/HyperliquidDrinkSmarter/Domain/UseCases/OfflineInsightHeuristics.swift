import Foundation

struct OfflineInsightHeuristics {
    func dailyInsight(currentMl: Double, goalMl: Double, calories: Int, trackCalories: Bool) -> DailyInsightRecord {
        let pct = goalMl > 0 ? Int((currentMl / goalMl) * 100) : 0
        let headline: String
        let insight: String
        let hydrationAdvice: String
        let nutritionTip: String
        let encouragement: String

        if pct >= 100 {
            headline = "Great work today"
            insight = "You hit or exceeded your hydration goal."
            hydrationAdvice = "Keep the steady pace — consistency beats bursts."
            nutritionTip = trackCalories ? "Nice balance of intake and hydration." : "Remember to pair water with meals."
            encouragement = "You're building a strong habit."
        } else if pct >= 70 {
            headline = "Solid progress"
            insight = "You're at \(pct)% of your daily goal."
            hydrationAdvice = "Try a glass with your next meal or snack."
            nutritionTip = "Even small top-ups add up fast."
            encouragement = "Almost there — one more glass and you're golden."
        } else if pct >= 40 {
            headline = "Room to grow"
            insight = "At \(pct)% — a little behind the curve."
            hydrationAdvice = "Set a reminder or keep a bottle at your desk."
            nutritionTip = trackCalories ? "Watch that afternoon energy dip with a bit more water." : ""
            encouragement = "You've got this. Small sips, big difference."
        } else {
            headline = "Let's get some water in"
            insight = "Only \(pct)% so far. Your body will thank you."
            hydrationAdvice = "Start with 250 ml right now."
            nutritionTip = "Coffee and tea count a bit less — add extra water."
            encouragement = "Today is a fresh start."
        }

        return DailyInsightRecord(
            date: Calendar.current.startOfDay(for: .now),
            headline: headline,
            insightText: insight,
            hydrationAdvice: hydrationAdvice,
            nutritionTip: nutritionTip,
            encouragement: encouragement,
            disclaimer: HyperliquidDrinkSmarterIdentity.medicalDisclaimerShort,
            isAIGenerated: false
        )
    }
}

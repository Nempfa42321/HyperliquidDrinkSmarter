import Foundation


struct NutritionEstimate: Codable, Equatable {
    let estimatedCalories: Int
    let proteinG: Double
    let carbsG: Double
    let fatG: Double
    let notes: String
}

struct CoachAdviceDTO: Codable, Equatable {
    let tip: String
    let reasoning: String
    let actionSteps: [String]
    let disclaimer: String
}

struct DailyInsightDTO: Codable, Equatable {
    let headline: String
    let insightText: String
    let hydrationAdvice: String
    let nutritionTip: String
    let encouragement: String
    let disclaimer: String
}

struct WeeklySummaryDTO: Codable, Equatable {
    let headline: String
    let insightText: String
    let observations: [String]
    let disclaimer: String
}

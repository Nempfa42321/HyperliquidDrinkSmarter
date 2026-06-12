import Foundation
import SwiftData


@Model
final class IntakeEntry {
    var id: UUID
    var kind: IntakeKind
    var timestamp: Date

    var beverageType: BeverageType?
    var volumeMl: Double?
    var hydrationFactor: Double?

    var mealDescription: String?
    var estimatedCalories: Int?
    var proteinG: Double?
    var carbsG: Double?
    var fatG: Double?
    var estimateSource: EstimateSource?

    init(id: UUID = UUID(),
         kind: IntakeKind,
         timestamp: Date = .now,
         beverageType: BeverageType? = nil,
         volumeMl: Double? = nil,
         hydrationFactor: Double? = nil,
         mealDescription: String? = nil,
         estimatedCalories: Int? = nil,
         proteinG: Double? = nil,
         carbsG: Double? = nil,
         fatG: Double? = nil,
         estimateSource: EstimateSource? = nil) {
        self.id = id
        self.kind = kind
        self.timestamp = timestamp
        self.beverageType = beverageType
        self.volumeMl = volumeMl
        self.hydrationFactor = hydrationFactor
        self.mealDescription = mealDescription
        self.estimatedCalories = estimatedCalories
        self.proteinG = proteinG
        self.carbsG = carbsG
        self.fatG = fatG
        self.estimateSource = estimateSource
    }
}

enum IntakeKind: String, Codable, CaseIterable {
    case drink
    case meal
}

enum BeverageType: String, Codable, CaseIterable {
    case water, coffee, tea, juice, soda, alcohol, other

    var defaultHydrationFactor: Double {
        switch self {
        case .water: return 1.0
        case .tea, .juice: return 0.9
        case .coffee, .soda: return 0.85
        case .alcohol: return 0.5
        case .other: return 0.8
        }
    }

    var displayName: String {
        switch self {
        case .water: return "Water"
        case .coffee: return "Coffee"
        case .tea: return "Tea"
        case .juice: return "Juice"
        case .soda: return "Soda"
        case .alcohol: return "Alcohol"
        case .other: return "Other"
        }
    }
}

enum EstimateSource: String, Codable {
    case ai
    case manual
}


@Model
final class DailyGoalSettings {
    var hydrationGoalMl: Double
    var calorieGoal: Int?
    var weightKg: Double?
    var trackCalories: Bool

    init(hydrationGoalMl: Double = 2500,
         calorieGoal: Int? = nil,
         weightKg: Double? = nil,
         trackCalories: Bool = false) {
        self.hydrationGoalMl = hydrationGoalMl
        self.calorieGoal = calorieGoal
        self.weightKg = weightKg
        self.trackCalories = trackCalories
    }
}


@Model
final class DailyInsightRecord {
    var id: UUID
    var date: Date             
    var headline: String
    var insightText: String
    var hydrationAdvice: String
    var nutritionTip: String
    var encouragement: String
    var disclaimer: String
    var isAIGenerated: Bool

    init(id: UUID = UUID(),
         date: Date,
         headline: String,
         insightText: String,
         hydrationAdvice: String,
         nutritionTip: String,
         encouragement: String,
         disclaimer: String,
         isAIGenerated: Bool) {
        self.id = id
        self.date = date
        self.headline = headline
        self.insightText = insightText
        self.hydrationAdvice = hydrationAdvice
        self.nutritionTip = nutritionTip
        self.encouragement = encouragement
        self.disclaimer = disclaimer
        self.isAIGenerated = isAIGenerated
    }
}

@Model
final class CoachThreadMessage {
    var id: UUID
    var role: CoachMessageRole
    var text: String
    var structured: CoachAdvice?
    var createdAt: Date

    init(id: UUID = UUID(),
         role: CoachMessageRole,
         text: String,
         structured: CoachAdvice? = nil,
         createdAt: Date = .now) {
        self.id = id
        self.role = role
        self.text = text
        self.structured = structured
        self.createdAt = createdAt
    }
}

enum CoachMessageRole: String, Codable {
    case user
    case assistant
}

struct CoachAdvice: Codable, Equatable {
    var tip: String
    var reasoning: String
    var actionSteps: [String]
    var disclaimer: String
}

@Model
final class WeeklySummaryRecord {
    var id: UUID
    var weekStart: Date
    var headline: String
    var insightText: String
    var observations: [String]
    var disclaimer: String

    init(id: UUID = UUID(),
         weekStart: Date,
         headline: String,
         insightText: String,
         observations: [String],
         disclaimer: String) {
        self.id = id
        self.weekStart = weekStart
        self.headline = headline
        self.insightText = insightText
        self.observations = observations
        self.disclaimer = disclaimer
    }
}

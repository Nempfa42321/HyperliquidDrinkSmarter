import Foundation

struct LogIntakeUseCase {
    private let repository: IntakeRepository

    init(repository: IntakeRepository) {
        self.repository = repository
    }

    func logDrink(type: BeverageType, volumeMl: Double) {
        let factor = type.defaultHydrationFactor
        let entry = IntakeEntry(
            kind: .drink,
            beverageType: type,
            volumeMl: volumeMl,
            hydrationFactor: factor
        )
        repository.insert(entry)
    }

    func logMeal(description: String, calories: Int?, protein: Double?, carbs: Double?, fat: Double?, source: EstimateSource?) {
        let entry = IntakeEntry(
            kind: .meal,
            mealDescription: description,
            estimatedCalories: calories,
            proteinG: protein,
            carbsG: carbs,
            fatG: fat,
            estimateSource: source
        )
        repository.insert(entry)
    }
}

import Foundation

struct ComputeDailyTotalsUseCase {
    func execute(_ entries: [IntakeEntry]) -> DailyTotals {
        var hyd = 0.0
        var cals = 0
        var p = 0.0, c = 0.0, f = 0.0

        for e in entries {
            if e.kind == .drink, let vol = e.volumeMl, let fac = e.hydrationFactor {
                hyd += vol * fac
            }
            if let cal = e.estimatedCalories { cals += cal }
            p += e.proteinG ?? 0
            c += e.carbsG ?? 0
            f += e.fatG ?? 0
        }

        return DailyTotals(
            hydrationMl: hyd,
            calories: cals,
            proteinG: p,
            carbsG: c,
            fatG: f
        )
    }
}

struct DailyTotals {
    let hydrationMl: Double
    let calories: Int
    let proteinG: Double
    let carbsG: Double
    let fatG: Double
}

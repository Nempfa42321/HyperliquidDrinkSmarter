import Foundation
import SwiftData

@Observable
final class IntakeRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchEntries(for date: Date) -> [IntakeEntry] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        let end = cal.date(byAdding: .day, value: 1, to: start)!

        let descriptor = FetchDescriptor<IntakeEntry>(
            predicate: #Predicate { entry in
                entry.timestamp >= start && entry.timestamp < end
            },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchAll() -> [IntakeEntry] {
        let descriptor = FetchDescriptor<IntakeEntry>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func insert(_ entry: IntakeEntry) {
        modelContext.insert(entry)
        try? modelContext.save()
    }

    func delete(_ entry: IntakeEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
    }

    func update(_ entry: IntakeEntry) {
        try? modelContext.save()
    }

    func totalHydrationMl(_ entries: [IntakeEntry]) -> Double {
        entries.reduce(0) { sum, e in
            if e.kind == .drink, let vol = e.volumeMl, let factor = e.hydrationFactor {
                return sum + vol * factor
            }
            return sum
        }
    }

    func totalCalories(_ entries: [IntakeEntry]) -> Int {
        entries.reduce(0) { $0 + ($1.estimatedCalories ?? 0) }
    }

    func macroTotals(_ entries: [IntakeEntry]) -> (protein: Double, carbs: Double, fat: Double) {
        let p = entries.reduce(0) { $0 + ($1.proteinG ?? 0) }
        let c = entries.reduce(0) { $0 + ($1.carbsG ?? 0) }
        let f = entries.reduce(0) { $0 + ($1.fatG ?? 0) }
        return (p, c, f)
    }
}

import Foundation
import SwiftData

@Observable
final class GoalsRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func current() -> DailyGoalSettings {
        let descriptor = FetchDescriptor<DailyGoalSettings>()
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        let fresh = DailyGoalSettings()
        modelContext.insert(fresh)
        try? modelContext.save()
        return fresh
    }

    func update(_ settings: DailyGoalSettings) {
        try? modelContext.save()
    }

    func deleteAll() {
        let descriptor = FetchDescriptor<DailyGoalSettings>()
        guard let all = try? modelContext.fetch(descriptor) else { return }
        for settings in all {
            modelContext.delete(settings)
        }
        try? modelContext.save()
    }
}

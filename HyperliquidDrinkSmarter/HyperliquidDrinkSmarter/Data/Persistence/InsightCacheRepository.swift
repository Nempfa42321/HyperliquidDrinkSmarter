import Foundation
import SwiftData

@Observable
final class InsightCacheRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func dailyInsight(for date: Date) -> DailyInsightRecord? {
        let start = Calendar.current.startOfDay(for: date)
        let descriptor = FetchDescriptor<DailyInsightRecord>(
            predicate: #Predicate { $0.date == start }
        )
        return try? modelContext.fetch(descriptor).first
    }

    func saveDaily(_ record: DailyInsightRecord) {
        if let old = dailyInsight(for: record.date) {
            modelContext.delete(old)
        }
        modelContext.insert(record)
        try? modelContext.save()
    }

    func weekly(for weekStart: Date) -> WeeklySummaryRecord? {
        let descriptor = FetchDescriptor<WeeklySummaryRecord>(
            predicate: #Predicate { $0.weekStart == weekStart }
        )
        return try? modelContext.fetch(descriptor).first
    }

    func saveWeekly(_ record: WeeklySummaryRecord) {
        if let old = weekly(for: record.weekStart) {
            modelContext.delete(old)
        }
        modelContext.insert(record)
        try? modelContext.save()
    }

    func allDailyInsights() -> [DailyInsightRecord] {
        let descriptor = FetchDescriptor<DailyInsightRecord>(sortBy: [SortDescriptor(\.date)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func allWeeklySummaries() -> [WeeklySummaryRecord] {
        let descriptor = FetchDescriptor<WeeklySummaryRecord>(sortBy: [SortDescriptor(\.weekStart)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func deleteAll() {
        let dailyDescriptor = FetchDescriptor<DailyInsightRecord>()
        let weeklyDescriptor = FetchDescriptor<WeeklySummaryRecord>()
        for record in (try? modelContext.fetch(dailyDescriptor)) ?? [] {
            modelContext.delete(record)
        }
        for record in (try? modelContext.fetch(weeklyDescriptor)) ?? [] {
            modelContext.delete(record)
        }
        try? modelContext.save()
    }
}

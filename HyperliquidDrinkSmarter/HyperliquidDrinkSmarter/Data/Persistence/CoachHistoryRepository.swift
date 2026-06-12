import Foundation
import SwiftData

@Observable
final class CoachHistoryRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func allMessages() -> [CoachThreadMessage] {
        let descriptor = FetchDescriptor<CoachThreadMessage>(sortBy: [SortDescriptor(\.createdAt)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func append(_ message: CoachThreadMessage) {
        modelContext.insert(message)
        try? modelContext.save()
    }

    func clear() {
        for m in allMessages() {
            modelContext.delete(m)
        }
        try? modelContext.save()
    }
}

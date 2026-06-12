import SwiftUI
import SwiftData
import Charts

struct TrendsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var scheme

    @State private var intakeRepo: IntakeRepository?
    @State private var goalsRepo: GoalsRepository?
    @State private var insightCache: InsightCacheRepository?

    @State private var range: TrendRange = .sevenDays
    @State private var dailyData: [(date: Date, hydration: Double, goal: Double, calories: Int)] = []
    @State private var streak: Int = 0
    @State private var weeklySummary: WeeklySummaryRecord?
    @State private var isGeneratingWeekly = false
    @AppStorage("hyperliquiddrinksmarter.settings.aiCoach.enabled") private var aiCoachEnabled = false

    enum TrendRange: String, CaseIterable {
        case sevenDays = "7 days"
        case thirtyDays = "30 days"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Picker("Range", selection: $range) {
                    ForEach(TrendRange.allCases, id: \.self) { r in
                        Text(r.rawValue).tag(r)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: range) { _, _ in loadData() }

                VStack(alignment: .leading) {
                    Text("Hydration")
                        .font(HyperliquidDrinkSmarterTypography.headline)
                    Chart(dailyData, id: \.date) { item in
                        BarMark(
                            x: .value("Day", item.date, unit: .day),
                            y: .value("ml", item.hydration)
                        )
                        .foregroundStyle(HyperliquidDrinkSmarterColors.accentInfo(for: scheme))

                        RuleMark(y: .value("Goal", item.goal))
                            .foregroundStyle(HyperliquidDrinkSmarterColors.accentPrimary(for: scheme).opacity(0.6))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [4]))
                    }
                    .frame(height: 180)
                    .chartYAxis { AxisMarks(position: .leading) }
                }
                .padding(16)
                .pillCard()

                streakCard

                if let summary = weeklySummary {
                    WeeklySummaryCard(summary: summary)
                } else {
                    offlineWeeklyCard
                }

                Button {
                    Task { await generateWeeklySummary() }
                } label: {
                    if isGeneratingWeekly {
                        ProgressView()
                    } else {
                        Label(aiCoachEnabled ? "Generate weekly AI summary" : "View local weekly summary", systemImage: aiCoachEnabled ? "sparkles" : "chart.bar")
                    }
                }
                .buttonStyle(HyperliquidDrinkSmarterSecondaryButtonStyle())
                .disabled(isGeneratingWeekly)
                .padding(.horizontal, 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(HyperliquidDrinkSmarterColors.background(for: scheme).ignoresSafeArea())
        .navigationTitle("Trends")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadData)
    }

    private var streakCard: some View {
        HStack {
            Image(systemName: "flame.fill")
                .font(.system(size: 28))
                .foregroundStyle(.orange)
            VStack(alignment: .leading) {
                Text("\(streak)")
                    .font(HyperliquidDrinkSmarterTypography.largeTitle)
                Text("day streak")
                    .font(HyperliquidDrinkSmarterTypography.body)
            }
            Spacer()
            Text("Keep it going!")
                .font(HyperliquidDrinkSmarterTypography.footnote)
                .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
        }
        .padding(20)
        .pillCard()
    }

    private var offlineWeeklyCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekly snapshot")
                .font(HyperliquidDrinkSmarterTypography.headline)
            Text("Local averages and observations. Turn on AI Coach in Settings for richer weekly pattern summaries.")
                .font(HyperliquidDrinkSmarterTypography.caption)
                .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
        }
        .padding(20)
        .pillCard()
    }

    @MainActor
    private func generateWeeklySummary() async {
        guard let i = intakeRepo, let g = goalsRepo, let c = insightCache else { return }
        isGeneratingWeekly = true
        defer { isGeneratingWeekly = false }

        let settings = g.current()
        let goal = settings.hydrationGoalMl
        let weekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)) ?? .now

        var weekData: [(Date, Double, Double, Int)] = []
        for offset in 0..<7 {
            guard let d = Calendar.current.date(byAdding: .day, value: -offset, to: .now) else { continue }
            let entries = i.fetchEntries(for: d)
            let totals = ComputeDailyTotalsUseCase().execute(entries)
            weekData.append((d, totals.hydrationMl, goal, totals.calories))
        }

        let useCase = RequestWeeklySummaryUseCase(cache: c, goalsRepo: g, intakeRepo: i)
        let summary = await useCase.getWeeklySummary(aiEnabled: aiCoachEnabled, weekStart: weekStart, dailyData: weekData.map { (date: $0.0, hydration: $0.1, goal: $0.2, cals: $0.3) })

        weeklySummary = summary
    }

    private func loadData() {
        let iRepo = IntakeRepository(modelContext: modelContext)
        let gRepo = GoalsRepository(modelContext: modelContext)
        let cRepo = InsightCacheRepository(modelContext: modelContext)

        intakeRepo = iRepo
        goalsRepo = gRepo
        insightCache = cRepo

        let settings = gRepo.current()
        let goal = settings.hydrationGoalMl

        let days = range == .sevenDays ? 7 : 30
        var data: [(Date, Double, Double, Int)] = []

        for offset in (0..<days).reversed() {
            guard let d = Calendar.current.date(byAdding: .day, value: -offset, to: .now) else { continue }
            let entries = iRepo.fetchEntries(for: d)
            let totals = ComputeDailyTotalsUseCase().execute(entries)
            data.append((d, totals.hydrationMl, goal, totals.calories))
        }

        dailyData = data.map { (date: $0.0, hydration: $0.1, goal: $0.2, calories: $0.3) }
        streak = ComputeHydrationStreakUseCase().currentStreak(intakeRepo: iRepo, goalMl: goal)

        let weekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)) ?? .now
        weeklySummary = cRepo.weekly(for: weekStart)
    }
}

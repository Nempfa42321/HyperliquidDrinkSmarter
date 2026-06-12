import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var scheme

    @AppStorage("hyperliquiddrinksmarter.settings.aiCoach.enabled") private var aiCoachEnabled = false
    @AppStorage(HyperliquidDrinkSmarterSettingsKeys.volumeUnit) private var volumeUnit: String = "ml"

    @State private var goalsRepo: GoalsRepository?
    @State private var intakeRepo: IntakeRepository?
    @State private var insightCache: InsightCacheRepository?

    @State private var settings: DailyGoalSettings?
    @State private var todayEntries: [IntakeEntry] = []
    @State private var insight: DailyInsightRecord?
    @State private var isGeneratingInsight = false

    private var totals: DailyTotals {
        ComputeDailyTotalsUseCase().execute(todayEntries)
    }

    private var hydrationGoal: Double {
        settings?.hydrationGoalMl ?? 2500
    }

    private var currentHydration: Double {
        totals.hydrationMl
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                LiquidProgressRing(
                    currentMl: currentHydration,
                    goalMl: hydrationGoal,
                    unitLabel: volumeUnit,
                    diameter: 260
                )
                .fixedSize()
                .padding(.top, 12)

                QuickAddRow(volumeUnit: volumeUnit) { amount in
                    addQuickWater(amount)
                }

                if settings?.trackCalories == true {
                    nutritionCard
                }

                DailyInsightCard(
                    insight: insight,
                    isGenerating: isGeneratingInsight,
                    aiEnabled: aiCoachEnabled,
                    onGenerate: { Task { await generateInsight(forceRefresh: true) } }
                )

                Text(HyperliquidDrinkSmarterIdentity.medicalDisclaimerShort)
                    .font(HyperliquidDrinkSmarterTypography.caption)
                    .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
            .padding(.horizontal, 20)
        }
        .background(HyperliquidDrinkSmarterColors.background(for: scheme).ignoresSafeArea())
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadToday)
        .onChange(of: modelContext) { _, _ in loadToday() }
    }

    private var nutritionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's nutrition")
                .font(HyperliquidDrinkSmarterTypography.headline)
                .foregroundStyle(HyperliquidDrinkSmarterColors.textPrimary(for: scheme))

            MacroRingsView(
                protein: totals.proteinG,
                carbs: totals.carbsG,
                fat: totals.fatG,
                proteinGoal: nil,
                carbsGoal: nil,
                fatGoal: nil
            )
            .frame(maxWidth: .infinity, alignment: .center)

            if let goal = settings?.calorieGoal {
                Text("\(totals.calories) / \(goal) kcal")
                    .font(HyperliquidDrinkSmarterTypography.subheadline)
                    .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
            } else {
                Text("\(totals.calories) kcal logged")
                    .font(HyperliquidDrinkSmarterTypography.subheadline)
                    .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
            }
        }
        .padding(20)
        .pillCard()
    }

    private func loadToday() {
        let gRepo = GoalsRepository(modelContext: modelContext)
        let iRepo = IntakeRepository(modelContext: modelContext)
        let cRepo = InsightCacheRepository(modelContext: modelContext)

        goalsRepo = gRepo
        intakeRepo = iRepo
        insightCache = cRepo

        settings = gRepo.current()
        todayEntries = iRepo.fetchEntries(for: .now)

        if let cached = cRepo.dailyInsight(for: .now) {
            insight = cached
        } else {
            Task { await generateInsight(forceOffline: !aiCoachEnabled) }
        }
    }

    private func addQuickWater(_ ml: Double) {
        guard let repo = intakeRepo else { return }
        let useCase = LogIntakeUseCase(repository: repo)
        useCase.logDrink(type: .water, volumeMl: ml)
        todayEntries = repo.fetchEntries(for: .now)
        Task { await generateInsight(forceRefresh: true) }
    }

    private func generateInsight(forceOffline: Bool = false, forceRefresh: Bool = false) async {
        guard let g = goalsRepo, let i = intakeRepo, let c = insightCache else { return }
        isGeneratingInsight = true
        defer { isGeneratingInsight = false }

        let useCase = RequestDailyInsightUseCase(
            cache: c,
            goalsRepo: g,
            intakeRepo: i
        )

        let record = await useCase.getTodayInsight(
            aiEnabled: aiCoachEnabled && !forceOffline,
            forceRefresh: forceRefresh
        )
        insight = record
    }
}

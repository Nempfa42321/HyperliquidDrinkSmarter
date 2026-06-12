import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss

    @AppStorage(HyperliquidDrinkSmarterSettingsKeys.volumeUnit) private var volumeUnit = "ml"
    @AppStorage("hyperliquiddrinksmarter.settings.goals.hydrationMl") private var goalMl: Double = 2500
    @AppStorage("hyperliquiddrinksmarter.settings.goals.trackCalories") private var trackCals = false
    @AppStorage("hyperliquiddrinksmarter.settings.goals.calorieTarget") private var calTarget = 2000

    @AppStorage("hyperliquiddrinksmarter.settings.aiCoach.enabled") private var aiEnabled = false

    @AppStorage(HyperliquidDrinkSmarterSettingsKeys.remindersEnabled) private var remindersOn = false
    @AppStorage(HyperliquidDrinkSmarterSettingsKeys.remindersIntervalHours) private var reminderHours = 2
    @AppStorage(HyperliquidDrinkSmarterSettingsKeys.remindersStartHour) private var reminderStart = 8
    @AppStorage(HyperliquidDrinkSmarterSettingsKeys.remindersEndHour) private var reminderEnd = 22

    @AppStorage("hyperliquiddrinksmarter.settings.appearance") private var appearance = "system"

    @State private var showDeleteConfirm = false
    @State private var goalsRepo: GoalsRepository?
    @State private var intakeRepo: IntakeRepository?

    var body: some View {
        NavigationStack {
            Form {
                Section("Units") {
                    Picker("Volume", selection: $volumeUnit) {
                        Text("ml").tag("ml")
                        Text("oz").tag("oz")
                    }
                }

                Section("Goals") {
                    HStack {
                        Text("Hydration goal")
                        Spacer()
                        Text(VolumeFormatting.formatVolume(ml: goalMl, unit: volumeUnit))
                    }
                    Slider(value: $goalMl, in: 1000...5000, step: 50)

                    Toggle("Track calories & macros", isOn: $trackCals)
                    if trackCals {
                        Stepper("Daily calories: \(calTarget)", value: $calTarget, in: 1200...4500, step: 50)
                    }
                }

                Section("Reminders") {
                    Toggle("Enable reminders", isOn: $remindersOn)
                        .onChange(of: remindersOn) { _, newValue in
                            rescheduleReminders(enabled: newValue)
                        }
                    if remindersOn {
                        Picker("Every", selection: $reminderHours) {
                            Text("1 hour").tag(1)
                            Text("2 hours").tag(2)
                            Text("3 hours").tag(3)
                        }
                        .onChange(of: reminderHours) { _, _ in
                            if remindersOn { rescheduleReminders(enabled: true) }
                        }

                        HStack {
                            Picker("From", selection: $reminderStart) {
                                ForEach(6..<24, id: \.self) { hour in
                                    Text(hourLabel(hour)).tag(hour)
                                }
                            }
                            Picker("To", selection: $reminderEnd) {
                                ForEach(6..<24, id: \.self) { hour in
                                    Text(hourLabel(hour)).tag(hour)
                                }
                            }
                        }
                        .onChange(of: reminderStart) { _, _ in
                            if remindersOn { rescheduleReminders(enabled: true) }
                        }
                        .onChange(of: reminderEnd) { _, _ in
                            if remindersOn { rescheduleReminders(enabled: true) }
                        }
                    }
                }

                Section("AI Coach") {
                    Toggle("Enable AI Coach", isOn: $aiEnabled)
                        .tint(HyperliquidDrinkSmarterColors.accentPrimary)

                    DisclosureGroup("What gets sent when enabled") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(HyperliquidDrinkSmarterIdentity.aiDataDisclosure)
                                .font(HyperliquidDrinkSmarterTypography.caption)
                            Link("Privacy Policy", destination: HyperliquidDrinkSmarterIdentity.privacyPolicyLink)
                                .font(HyperliquidDrinkSmarterTypography.caption)
                        }
                    }

                    Button("Clear coach conversation history") {
                        CoachHistoryRepository(modelContext: modelContext).clear()
                    }
                    .foregroundStyle(.red)
                }

                Section("Appearance") {
                    Picker("Theme", selection: $appearance) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)
                }

                Section("Data") {
                    if let jsonURL = makeExportJSONFile() {
                        ShareLink(item: jsonURL, preview: SharePreview("\(HyperliquidDrinkSmarterIdentity.displayName) data export", image: Image(HyperliquidDrinkSmarterAssets.appLogo))) {
                            Label("Export my data as JSON", systemImage: "square.and.arrow.up")
                        }
                    } else {
                        Button("Export my data as JSON") {  }
                            .disabled(true)
                    }

                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Text("Delete all local data")
                    }
                }

                Section("About & Legal") {
                    VStack(spacing: 10) {
                        HyperliquidDrinkSmarterMarkView(cornerRadius: 16)
                            .frame(width: 64, height: 64)
                        HyperliquidDrinkSmarterBrandTitleView(style: .headline)
                            .padding(.horizontal, 12)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)

                    LabeledContent("Version", value: HyperliquidDrinkSmarterIdentity.version)
                    Link("Privacy Policy", destination: HyperliquidDrinkSmarterIdentity.privacyPolicyLink)
                    Link("Terms of Use", destination: HyperliquidDrinkSmarterIdentity.termsOfUseLink)
                    Link(destination: HyperliquidDrinkSmarterIdentity.supportMailtoLink) {
                        LabeledContent("Support", value: HyperliquidDrinkSmarterIdentity.supportEmail)
                    }

                    Text(HyperliquidDrinkSmarterIdentity.medicalDisclaimerShort)
                        .font(HyperliquidDrinkSmarterTypography.caption)
                        .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                let repo = GoalsRepository(modelContext: modelContext)
                goalsRepo = repo
                intakeRepo = IntakeRepository(modelContext: modelContext)
                let g = repo.current()
                goalMl = g.hydrationGoalMl
                trackCals = g.trackCalories
                calTarget = g.calorieGoal ?? calTarget
            }
            .onChange(of: goalMl) { _, new in
                guard let repo = goalsRepo else { return }
                let g = repo.current()
                g.hydrationGoalMl = new
                repo.update(g)
            }
            .onChange(of: trackCals) { _, new in
                guard let repo = goalsRepo else { return }
                let g = repo.current()
                g.trackCalories = new
                g.calorieGoal = new ? calTarget : nil
                repo.update(g)
            }
            .onChange(of: calTarget) { _, new in
                guard let repo = goalsRepo, trackCals else { return }
                let g = repo.current()
                g.calorieGoal = new
                repo.update(g)
            }
            .confirmationDialog("Delete everything?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Delete logs, goals, coach history, and insights", role: .destructive) {
                    deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes hydration and meal logs, goals, coach conversation history, and cached daily/weekly insights from this device. App preferences such as units, theme, reminders, and AI Coach on/off are kept. This cannot be undone.")
            }
        }
    }

    private func deleteAllData() {
        let iRepo = IntakeRepository(modelContext: modelContext)
        for e in iRepo.fetchAll() { iRepo.delete(e) }

        CoachHistoryRepository(modelContext: modelContext).clear()
        InsightCacheRepository(modelContext: modelContext).deleteAll()
        GoalsRepository(modelContext: modelContext).deleteAll()

        goalMl = 2500
        trackCals = false
        calTarget = 2000

        try? modelContext.save()
    }

    private func makeExportJSONFile() -> URL? {
        let iRepo = intakeRepo ?? IntakeRepository(modelContext: modelContext)
        let gRepo = goalsRepo ?? GoalsRepository(modelContext: modelContext)
        let coachRepo = CoachHistoryRepository(modelContext: modelContext)
        let cacheRepo = InsightCacheRepository(modelContext: modelContext)

        let intakes = iRepo.fetchAll()
        let goals = gRepo.current()
        let coachMessages = coachRepo.allMessages()
        let dailyInsights = cacheRepo.allDailyInsights()
        let weeklySummaries = cacheRepo.allWeeklySummaries()

        guard !intakes.isEmpty || !coachMessages.isEmpty || !dailyInsights.isEmpty || !weeklySummaries.isEmpty else {
            return nil
        }

        struct ExportBundle: Codable {
            let exportedAt: Date
            let appVersion: String
            let intakes: [ExportedIntake]
            let goals: ExportedGoals
            let coachMessages: [ExportedCoachMessage]
            let dailyInsights: [ExportedDailyInsight]
            let weeklySummaries: [ExportedWeeklySummary]
        }

        struct ExportedIntake: Codable {
            let id: String
            let kind: String
            let timestamp: Date
            let beverageType: String?
            let volumeMl: Double?
            let hydrationFactor: Double?
            let mealDescription: String?
            let estimatedCalories: Int?
            let proteinG: Double?
            let carbsG: Double?
            let fatG: Double?
            let estimateSource: String?
        }

        struct ExportedGoals: Codable {
            let hydrationGoalMl: Double
            let calorieGoal: Int?
            let weightKg: Double?
            let trackCalories: Bool
        }

        struct ExportedCoachMessage: Codable {
            let id: String
            let role: String
            let text: String
            let createdAt: Date
        }

        struct ExportedDailyInsight: Codable {
            let date: Date
            let headline: String
            let insightText: String
            let isAIGenerated: Bool
        }

        struct ExportedWeeklySummary: Codable {
            let weekStart: Date
            let headline: String
            let insightText: String
        }

        let payload = ExportBundle(
            exportedAt: .now,
            appVersion: HyperliquidDrinkSmarterIdentity.version,
            intakes: intakes.map { e in
                ExportedIntake(
                    id: e.id.uuidString,
                    kind: e.kind.rawValue,
                    timestamp: e.timestamp,
                    beverageType: e.beverageType?.rawValue,
                    volumeMl: e.volumeMl,
                    hydrationFactor: e.hydrationFactor,
                    mealDescription: e.mealDescription,
                    estimatedCalories: e.estimatedCalories,
                    proteinG: e.proteinG,
                    carbsG: e.carbsG,
                    fatG: e.fatG,
                    estimateSource: e.estimateSource?.rawValue
                )
            },
            goals: ExportedGoals(
                hydrationGoalMl: goals.hydrationGoalMl,
                calorieGoal: goals.calorieGoal,
                weightKg: goals.weightKg,
                trackCalories: goals.trackCalories
            ),
            coachMessages: coachMessages.map { m in
                ExportedCoachMessage(
                    id: m.id.uuidString,
                    role: m.role.rawValue,
                    text: m.text,
                    createdAt: m.createdAt
                )
            },
            dailyInsights: dailyInsights.map { d in
                ExportedDailyInsight(
                    date: d.date,
                    headline: d.headline,
                    insightText: d.insightText,
                    isAIGenerated: d.isAIGenerated
                )
            },
            weeklySummaries: weeklySummaries.map { w in
                ExportedWeeklySummary(
                    weekStart: w.weekStart,
                    headline: w.headline,
                    insightText: w.insightText
                )
            }
        )

        guard let data = try? JSONEncoder().encode(payload) else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("HyperliquidDrinkSmarter-Export-\(Int(Date().timeIntervalSince1970)).json")
        try? data.write(to: url)
        return url
    }

    private func hourLabel(_ hour: Int) -> String {
        String(format: "%d:00", hour)
    }

    private func rescheduleReminders(enabled: Bool) {
        let start = min(reminderStart, reminderEnd)
        let end = max(reminderStart, reminderEnd)
        HydrationReminderScheduler.schedule(
            enabled: enabled,
            intervalHours: reminderHours,
            startHour: start,
            endHour: end
        )
    }
}

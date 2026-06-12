import SwiftUI
import SwiftData

struct HyperliquidDrinkSmarterOnboardingView: View {
    var onComplete: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var step = 1
    @State private var displayWeight: Double = 70
    @State private var useKg = true
    @State private var hydrationGoal: Double = 2500
    @State private var trackCalories = false
    @State private var calorieGoal: Int = 2000
    @State private var aiEnabled = false
    @State private var reminderEnabled = false
    @State private var reminderInterval = 2
    @State private var reminderStart = 8
    @State private var reminderEnd = 22

    @State private var goalsRepo: GoalsRepository?

    private var weightRange: ClosedRange<Double> {
        useKg ? 40...140 : 88...308
    }

    var body: some View {
        NavigationStack {
            VStack {
                switch step {
                case 1: welcomeStep
                case 2: goalStep
                case 3: aiConsentStep
                case 4: remindersStep
                default: EmptyView()
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(HyperliquidDrinkSmarterColors.background.ignoresSafeArea())
            .toolbar {
                if step > 1 {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Back") { withAnimation { step -= 1 } }
                    }
                }
            }
            .onAppear {
                goalsRepo = GoalsRepository(modelContext: modelContext)
            }
        }
    }

    private var welcomeStep: some View {
        VStack(spacing: 32) {
            Spacer()

            HyperliquidDrinkSmarterMarkView(cornerRadius: 18)
                .frame(width: 88, height: 88)
                .shadow(color: HyperliquidDrinkSmarterColors.accentInfo.opacity(0.22), radius: 16, y: 8)

            VStack(spacing: 12) {
                HyperliquidDrinkSmarterBrandTitleView(style: .hero)
                    .padding(.horizontal, 8)
                Text("Small sips, better days.")
                    .font(HyperliquidDrinkSmarterTypography.title)
                    .foregroundStyle(HyperliquidDrinkSmarterColors.accentPrimary)
            }

            Text(HyperliquidDrinkSmarterIdentity.slogan)
                .font(HyperliquidDrinkSmarterTypography.body)
                .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted)
                .multilineTextAlignment(.center)

            Spacer()

            Button("Get started") {
                withAnimation(.spring) { step = 2 }
            }
            .buttonStyle(HyperliquidDrinkSmarterPrimaryButtonStyle())
        }
    }

    private var goalStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Set your goal")
                .font(HyperliquidDrinkSmarterTypography.largeTitle)

            Text("We use a simple estimate: weight (kg) × 33 ≈ daily ml. This is a general wellness starting point, not medical advice.")
                .font(HyperliquidDrinkSmarterTypography.body)
                .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted)

            Toggle("Use kg (or lb)", isOn: $useKg)
                .tint(HyperliquidDrinkSmarterColors.accentPrimary)
                .onChange(of: useKg) { _, newValue in
                    displayWeight = newValue
                        ? displayWeight * 0.453592
                        : displayWeight / 0.453592
                    displayWeight = min(max(displayWeight, weightRange.lowerBound), weightRange.upperBound)
                }

            HStack {
                Text(useKg ? "Weight (kg)" : "Weight (lb)")
                Spacer()
                TextField("70", value: $displayWeight, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            .font(HyperliquidDrinkSmarterTypography.body)

            Slider(value: $displayWeight, in: weightRange, step: 1)

            VStack(alignment: .leading, spacing: 8) {
                Text("Daily hydration goal")
                    .font(HyperliquidDrinkSmarterTypography.label)
                Slider(value: $hydrationGoal, in: 1000...5000, step: 50)
                Text("\(Int(hydrationGoal)) ml")
                    .font(HyperliquidDrinkSmarterTypography.progressNumber)
                    .foregroundStyle(HyperliquidDrinkSmarterColors.accentPrimary)
            }

            Toggle("Track calories & macros too", isOn: $trackCalories)
                .tint(HyperliquidDrinkSmarterColors.accentSecondary)

            if trackCalories {
                Stepper("Calorie goal: \(calorieGoal)", value: $calorieGoal, in: 1200...4000, step: 50)
            }

            Spacer()

            Button("Continue") {
                saveGoals()
                withAnimation { step = 3 }
            }
            .buttonStyle(HyperliquidDrinkSmarterPrimaryButtonStyle())
        }
    }

    private var aiConsentStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("AI Coach is off by default")
                .font(HyperliquidDrinkSmarterTypography.largeTitle)

            Text(HyperliquidDrinkSmarterIdentity.aiDataDisclosure)
                .font(HyperliquidDrinkSmarterTypography.body)

            Text("Don't include sensitive medical information in meal descriptions or coach questions.")
                .font(HyperliquidDrinkSmarterTypography.caption)
                .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted)

            HStack(spacing: 16) {
                Link("Privacy Policy", destination: HyperliquidDrinkSmarterIdentity.privacyPolicyLink)
                Link("Terms of Use", destination: HyperliquidDrinkSmarterIdentity.termsOfUseLink)
            }
            .font(HyperliquidDrinkSmarterTypography.caption)

            Toggle("Enable AI Coach", isOn: $aiEnabled)
                .tint(HyperliquidDrinkSmarterColors.accentPrimary)
                .padding(.vertical, 8)

            Text(HyperliquidDrinkSmarterIdentity.aiOptInNotice)
                .font(HyperliquidDrinkSmarterTypography.caption)
                .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted)

            Spacer()

            Button(aiEnabled ? "Enable & continue" : "Continue without AI") {
                saveAIConsent()
                withAnimation { step = 4 }
            }
            .buttonStyle(HyperliquidDrinkSmarterPrimaryButtonStyle())
        }
    }

    private var remindersStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Stay on track")
                .font(HyperliquidDrinkSmarterTypography.largeTitle)

            Text("Optional reminders help you log throughout the day. You can change this anytime in Settings.")
                .font(HyperliquidDrinkSmarterTypography.body)

            Toggle("Enable reminders", isOn: $reminderEnabled)
                .tint(HyperliquidDrinkSmarterColors.accentInfo)

            if reminderEnabled {
                Picker("Every", selection: $reminderInterval) {
                    Text("1 hour").tag(1)
                    Text("2 hours").tag(2)
                    Text("3 hours").tag(3)
                }
                .pickerStyle(.segmented)

                HStack {
                    Picker("From", selection: $reminderStart) {
                        ForEach(6..<24, id: \.self) { hour in
                            Text("\(hour):00").tag(hour)
                        }
                    }
                    Picker("To", selection: $reminderEnd) {
                        ForEach(6..<24, id: \.self) { hour in
                            Text("\(hour):00").tag(hour)
                        }
                    }
                }
            }

            Spacer()

            Button("Finish & start tracking") {
                saveReminders()
                onComplete()
            }
            .buttonStyle(HyperliquidDrinkSmarterPrimaryButtonStyle())

            Button("Skip for now") {
                onComplete()
            }
            .buttonStyle(HyperliquidDrinkSmarterSecondaryButtonStyle())
        }
    }

    private func saveGoals() {
        let g = goalsRepo?.current() ?? DailyGoalSettings()
        g.hydrationGoalMl = hydrationGoal
        g.weightKg = useKg ? displayWeight : displayWeight * 0.453592
        g.trackCalories = trackCalories
        g.calorieGoal = trackCalories ? calorieGoal : nil
        goalsRepo?.update(g)
    }

    private func saveAIConsent() {
        UserDefaults.standard.set(aiEnabled, forKey: "hyperliquiddrinksmarter.settings.aiCoach.enabled")
    }

    private func saveReminders() {
        UserDefaults.standard.set(reminderEnabled, forKey: HyperliquidDrinkSmarterSettingsKeys.remindersEnabled)
        UserDefaults.standard.set(reminderInterval, forKey: HyperliquidDrinkSmarterSettingsKeys.remindersIntervalHours)
        UserDefaults.standard.set(reminderStart, forKey: HyperliquidDrinkSmarterSettingsKeys.remindersStartHour)
        UserDefaults.standard.set(reminderEnd, forKey: HyperliquidDrinkSmarterSettingsKeys.remindersEndHour)

        let start = min(reminderStart, reminderEnd)
        let end = max(reminderStart, reminderEnd)
        HydrationReminderScheduler.schedule(
            enabled: reminderEnabled,
            intervalHours: reminderInterval,
            startHour: start,
            endHour: end
        )
    }
}

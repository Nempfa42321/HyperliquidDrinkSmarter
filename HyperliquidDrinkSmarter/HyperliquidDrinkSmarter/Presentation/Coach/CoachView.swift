import SwiftUI
import SwiftData

struct CoachView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var scheme
    @AppStorage("hyperliquiddrinksmarter.settings.aiCoach.enabled") private var aiEnabled = false

    @State private var historyRepo: CoachHistoryRepository?
    @State private var intakeRepo: IntakeRepository?
    @State private var goalsRepo: GoalsRepository?
    @State private var messages: [CoachThreadMessage] = []
    @State private var inputText = ""
    @State private var isThinking = false

    private let quickPrompts = [
        "How much water do I need today?",
        "Is coffee dehydrating?",
        "Suggest a high-protein snack",
        "Why am I always thirsty in the afternoon?"
    ]

    var body: some View {
        VStack(spacing: 0) {
            if !aiEnabled {
                aiDisabledBanner
            }

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(messages, id: \.id) { msg in
                            if msg.role == .user {
                                userBubble(msg.text)
                            } else {
                                coachBubble(msg)
                            }
                        }
                        if isThinking {
                            ProgressView("Coach is thinking…")
                                .padding()
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            if aiEnabled {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(quickPrompts, id: \.self) { q in
                            Button(q) { sendQuick(q) }
                                .buttonStyle(HyperliquidDrinkSmarterQuickPillButtonStyle())
                                .disabled(isThinking)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }

            HStack(spacing: 12) {
                TextField("Ask the coach...", text: $inputText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                    .disabled(!aiEnabled || isThinking)

                Button {
                    send()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || !aiEnabled || isThinking)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(HyperliquidDrinkSmarterColors.surface(for: scheme))
        }
        .background(HyperliquidDrinkSmarterColors.background(for: scheme).ignoresSafeArea())
        .navigationTitle("Coach")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !messages.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") {
                        historyRepo?.clear()
                        messages = []
                    }
                }
            }
        }
        .onAppear(perform: loadHistory)
    }

    private var aiDisabledBanner: some View {
        VStack(spacing: 12) {
            Text("AI Coach is currently disabled.")
                .font(HyperliquidDrinkSmarterTypography.headline)
            Text("Turn it on in Settings → AI Coach to ask questions and get structured tips.")
                .font(HyperliquidDrinkSmarterTypography.body)
                .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
                .multilineTextAlignment(.center)
            NavigationLink("Open Settings") {
                SettingsView()
            }
            .buttonStyle(HyperliquidDrinkSmarterSecondaryButtonStyle())
            .frame(maxWidth: 220)
        }
        .padding()
        .background(HyperliquidDrinkSmarterColors.surfaceAlt(for: scheme))
    }

    private func userBubble(_ text: String) -> some View {
        HStack {
            Spacer()
            Text(text)
                .padding(12)
                .background(HyperliquidDrinkSmarterColors.accentPrimary(for: scheme))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .frame(maxWidth: 260, alignment: .trailing)
        }
    }

    private func coachBubble(_ msg: CoachThreadMessage) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                HyperliquidDrinkSmarterMarkView(cornerRadius: 7)
                    .frame(width: 28, height: 28)
                HyperliquidDrinkSmarterBrandTitleView(style: .compact, suffix: " Coach")
            }

            if let structured = msg.structured {
                Text(structured.tip)
                    .font(HyperliquidDrinkSmarterTypography.headline)
                    .foregroundStyle(HyperliquidDrinkSmarterColors.accentPrimary(for: scheme))

                Text(structured.reasoning)
                    .font(HyperliquidDrinkSmarterTypography.body)

                ForEach(structured.actionSteps, id: \.self) { step in
                    HStack(alignment: .top) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(HyperliquidDrinkSmarterColors.accentSecondary(for: scheme))
                        Text(step)
                    }
                }

                Text(structured.disclaimer)
                    .font(HyperliquidDrinkSmarterTypography.caption)
                    .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
            } else {
                Text(msg.text)
                    .font(HyperliquidDrinkSmarterTypography.body)
            }
        }
        .padding(16)
        .background(HyperliquidDrinkSmarterColors.surfaceAlt(for: scheme))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .frame(maxWidth: 300, alignment: .leading)
    }

    private func loadHistory() {
        historyRepo = CoachHistoryRepository(modelContext: modelContext)
        intakeRepo = IntakeRepository(modelContext: modelContext)
        goalsRepo = GoalsRepository(modelContext: modelContext)
        messages = historyRepo?.allMessages() ?? []
    }

    private func send() {
        let question = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }

        let userMsg = CoachThreadMessage(role: .user, text: question)
        historyRepo?.append(userMsg)
        messages.append(userMsg)

        inputText = ""

        guard aiEnabled else { return }

        Task { @MainActor in
            isThinking = true
            defer { isThinking = false }

            let todayEntries = intakeRepo?.fetchEntries(for: .now) ?? []
            let totals = ComputeDailyTotalsUseCase().execute(todayEntries)
            let settings = goalsRepo?.current()

            let context: [String: Any] = [
                "hydrationMl": totals.hydrationMl,
                "hydrationGoalMl": settings?.hydrationGoalMl ?? 2500,
                "caloriesToday": totals.calories,
                "calorieGoal": settings?.calorieGoal ?? 0
            ]

            do {
                let dto: CoachAdviceDTO = try await CoachAPIClient.askCoach(question: question, context: context)

                let structured = CoachAdvice(
                    tip: dto.tip,
                    reasoning: dto.reasoning,
                    actionSteps: dto.actionSteps,
                    disclaimer: dto.disclaimer.isEmpty ? HyperliquidDrinkSmarterIdentity.medicalDisclaimerShort : dto.disclaimer
                )

                let assistant = CoachThreadMessage(
                    role: .assistant,
                    text: dto.tip,
                    structured: structured
                )
                historyRepo?.append(assistant)
                messages.append(assistant)
            } catch {
                let message = AICoachUserMessages.coachFailure(isAPIConfigured: HyperliquidDrinkSmarterConfig.isAPIConfigured)
                let fallback = CoachAdvice(
                    tip: "Couldn't get an AI answer right now.",
                    reasoning: message,
                    actionSteps: ["Keep a bottle within reach", "Log drinks right after you have them"],
                    disclaimer: HyperliquidDrinkSmarterIdentity.medicalDisclaimerShort
                )
                let assistant = CoachThreadMessage(
                    role: .assistant,
                    text: fallback.tip,
                    structured: fallback
                )
                historyRepo?.append(assistant)
                messages.append(assistant)
            }
        }
    }

    private func sendQuick(_ prompt: String) {
        inputText = prompt
        send()
    }
}

import SwiftUI

struct AddMealSheet: View {
    var onAdd: (String, Int?, Double?, Double?, Double?, EstimateSource?) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    @AppStorage("hyperliquiddrinksmarter.settings.aiCoach.enabled") private var aiEnabled = false

    @State private var description: String = ""
    @State private var calories: Int = 400
    @State private var protein: Double = 20
    @State private var carbs: Double = 40
    @State private var fat: Double = 15
    @State private var portion: String = "Medium"

    @State private var isEstimating = false
    @State private var aiNote: String? = nil
    @State private var lastEstimateSource: EstimateSource? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section("What did you eat?") {
                    TextField("e.g. grilled chicken with rice and broccoli", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }

                if aiEnabled {
                    Section {
                        Button {
                            Task { await estimateWithAI() }
                        } label: {
                            if isEstimating {
                                ProgressView().tint(HyperliquidDrinkSmarterColors.accentPrimary)
                            } else {
                                Label("Estimate with AI", systemImage: "sparkles")
                            }
                        }
                        .disabled(description.trimmingCharacters(in: .whitespaces).isEmpty || isEstimating)

                        if let note = aiNote {
                            Text(note)
                                .font(HyperliquidDrinkSmarterTypography.caption)
                                .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
                        }
                    }
                } else {
                    Section {
                        Text("AI estimates are off. Enter values manually or enable AI Coach in Settings.")
                            .font(HyperliquidDrinkSmarterTypography.caption)
                            .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
                    }
                }

                Section("Portion hint") {
                    Picker("Size", selection: $portion) {
                        Text("Small").tag("Small")
                        Text("Medium").tag("Medium")
                        Text("Large").tag("Large")
                        Text("Custom").tag("Custom")
                    }
                    .pickerStyle(.segmented)
                }

                Section("Nutrition (manual)") {
                    Stepper("Calories: \(calories)", value: $calories, in: 0...2000, step: 10)
                    Stepper("Protein: \(Int(protein)) g", value: $protein, in: 0...150, step: 1)
                    Stepper("Carbs: \(Int(carbs)) g", value: $carbs, in: 0...200, step: 1)
                    Stepper("Fat: \(Int(fat)) g", value: $fat, in: 0...100, step: 1)
                }
            }
            .navigationTitle("Add Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let src = lastEstimateSource ?? .manual
                        onAdd(description, calories, protein, carbs, fat, src)
                        dismiss()
                    }
                    .disabled(description.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.large])
    }

    private func estimateWithAI() async {
        guard !description.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isEstimating = true
        aiNote = nil
        defer { isEstimating = false }

        do {
            let est: NutritionEstimate = try await CoachAPIClient.estimateNutrition(
                description: description,
                portionHint: portion
            )
            calories = est.estimatedCalories
            protein = est.proteinG
            carbs = est.carbsG
            fat = est.fatG
            lastEstimateSource = .ai
            aiNote = est.notes.isEmpty ? "AI estimate applied. You can edit the numbers before saving." : est.notes
        } catch {
            aiNote = AICoachUserMessages.estimateFailure(isAPIConfigured: HyperliquidDrinkSmarterConfig.isAPIConfigured)
            lastEstimateSource = .manual
        }
    }
}

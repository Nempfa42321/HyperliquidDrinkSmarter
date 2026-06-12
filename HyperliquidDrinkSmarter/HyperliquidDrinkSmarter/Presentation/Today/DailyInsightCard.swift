import SwiftUI

struct DailyInsightCard: View {
    let insight: DailyInsightRecord?
    let isGenerating: Bool
    let aiEnabled: Bool
    let onGenerate: () -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Daily Insight")
                    .font(HyperliquidDrinkSmarterTypography.headline)
                    .foregroundStyle(HyperliquidDrinkSmarterColors.textPrimary(for: scheme))
                Spacer()
                statusBadge
            }

            if let insight {
                Text(insight.headline)
                    .font(HyperliquidDrinkSmarterTypography.title)
                    .foregroundStyle(HyperliquidDrinkSmarterColors.accentPrimary(for: scheme))

                Text(insight.insightText)
                    .font(HyperliquidDrinkSmarterTypography.body)
                    .foregroundStyle(HyperliquidDrinkSmarterColors.textPrimary(for: scheme))

                if !insight.hydrationAdvice.isEmpty {
                    insightLine(title: "Hydration", text: insight.hydrationAdvice)
                }
                if !insight.nutritionTip.isEmpty {
                    insightLine(title: "Nutrition", text: insight.nutritionTip)
                }

                Text(insight.encouragement)
                    .font(HyperliquidDrinkSmarterTypography.bodySemibold)
                    .foregroundStyle(HyperliquidDrinkSmarterColors.textPrimary(for: scheme))
                    .padding(.top, 4)

                Text(insight.disclaimer)
                    .font(HyperliquidDrinkSmarterTypography.caption)
                    .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
            } else {
                Text("No insight yet for today.")
                    .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
            }

            if shouldShowGenerateButton {
                Button(action: onGenerate) {
                    if isGenerating {
                        ProgressView().tint(.white)
                    } else {
                        Text(generateButtonTitle)
                    }
                }
                .buttonStyle(HyperliquidDrinkSmarterPrimaryButtonStyle())
                .disabled(isGenerating)
            }
        }
        .padding(20)
        .pillCard()
    }

    private var shouldShowGenerateButton: Bool {
        if insight == nil { return true }
        if !aiEnabled { return true }
        return insight?.isAIGenerated != true
    }

    private var generateButtonTitle: String {
        if aiEnabled {
            return insight?.isAIGenerated == true ? "Refresh today's insight" : "Generate AI insight"
        }
        return "Generate local insight"
    }

    @ViewBuilder
    private var statusBadge: some View {
        if isGenerating {
            Text("Loading…")
                .font(HyperliquidDrinkSmarterTypography.caption)
                .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
        } else if insight?.isAIGenerated == true {
            Label("AI", systemImage: "sparkles")
                .font(.caption)
                .foregroundStyle(HyperliquidDrinkSmarterColors.accentSecondary(for: scheme))
        } else if insight != nil {
            Text("Local")
                .font(HyperliquidDrinkSmarterTypography.caption)
                .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
        } else if aiEnabled {
            Text("Tap below")
                .font(HyperliquidDrinkSmarterTypography.caption)
                .foregroundStyle(HyperliquidDrinkSmarterColors.accentPrimary(for: scheme))
        } else {
            Text("Local mode")
                .font(HyperliquidDrinkSmarterTypography.caption)
                .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
        }
    }

    private func insightLine(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(HyperliquidDrinkSmarterTypography.label)
                .foregroundStyle(HyperliquidDrinkSmarterColors.accentInfo(for: scheme))
            Text(text)
                .font(HyperliquidDrinkSmarterTypography.body)
                .foregroundStyle(HyperliquidDrinkSmarterColors.textPrimary(for: scheme))
        }
    }
}

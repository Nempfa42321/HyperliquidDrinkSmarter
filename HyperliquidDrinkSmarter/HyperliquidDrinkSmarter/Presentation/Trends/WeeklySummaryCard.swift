import SwiftUI

struct WeeklySummaryCard: View {
    let summary: WeeklySummaryRecord
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(summary.headline)
                .font(HyperliquidDrinkSmarterTypography.headline)
                .foregroundStyle(HyperliquidDrinkSmarterColors.accentPrimary(for: scheme))

            Text(summary.insightText)
                .font(HyperliquidDrinkSmarterTypography.body)

            ForEach(summary.observations, id: \.self) { obs in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                    Text(obs)
                }
            }

            Text(summary.disclaimer)
                .font(HyperliquidDrinkSmarterTypography.caption)
                .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
        }
        .padding(20)
        .pillCard()
    }
}

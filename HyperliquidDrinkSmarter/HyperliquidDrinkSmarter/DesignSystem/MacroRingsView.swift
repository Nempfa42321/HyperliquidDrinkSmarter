import SwiftUI

struct MacroRingsView: View {
    let protein: Double  
    let carbs: Double
    let fat: Double

    let proteinGoal: Double?
    let carbsGoal: Double?
    let fatGoal: Double?

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 28) {
            MacroRing(label: "P", value: protein, goal: proteinGoal, color: HyperliquidDrinkSmarterColors.accentPrimary(for: colorScheme))
            MacroRing(label: "C", value: carbs, goal: carbsGoal, color: HyperliquidDrinkSmarterColors.accentSecondary(for: colorScheme))
            MacroRing(label: "F", value: fat, goal: fatGoal, color: HyperliquidDrinkSmarterColors.accentInfo(for: colorScheme))
        }
    }
}

private struct MacroRing: View {
    let label: String
    let value: Double
    let goal: Double?
    let color: Color

    @Environment(\.colorScheme) private var colorScheme

    private var progress: Double {
        guard let g = goal, g > 0 else { return 0.35 }
        return min(max(value / g, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.18), lineWidth: 5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 1) {
                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(color)
                Text(String(format: "%.0f", value))
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(HyperliquidDrinkSmarterColors.textPrimary(for: colorScheme))
            }
        }
        .frame(width: 58, height: 58)
    }
}

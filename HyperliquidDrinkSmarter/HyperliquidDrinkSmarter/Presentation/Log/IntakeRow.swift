import SwiftUI

struct IntakeRow: View {
    let entry: IntakeEntry
    @Environment(\.colorScheme) private var scheme
    @AppStorage(HyperliquidDrinkSmarterSettingsKeys.volumeUnit) private var volumeUnit = "ml"

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: iconName)
                .font(.system(size: 22))
                .foregroundStyle(iconColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                if entry.kind == .drink, let type = entry.beverageType {
                    Text(type.displayName)
                        .font(HyperliquidDrinkSmarterTypography.bodySemibold)
                    if let vol = entry.volumeMl {
                        let net = vol * (entry.hydrationFactor ?? 1)
                        Text("\(VolumeFormatting.formatVolume(ml: vol, unit: volumeUnit))  ·  \(VolumeFormatting.formatVolume(ml: net, unit: volumeUnit)) net")
                            .font(HyperliquidDrinkSmarterTypography.footnote)
                            .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
                    }
                } else {
                    Text(entry.mealDescription ?? "Meal")
                        .font(HyperliquidDrinkSmarterTypography.bodySemibold)
                        .lineLimit(2)
                    if let cal = entry.estimatedCalories {
                        Text("\(cal) kcal")
                            .font(HyperliquidDrinkSmarterTypography.footnote)
                            .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
                    }
                }
            }

            Spacer()

            Text(entry.timestamp, format: .dateTime.hour().minute())
                .font(HyperliquidDrinkSmarterTypography.caption)
                .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
        }
        .padding(.vertical, 4)
    }

    private var iconName: String {
        if entry.kind == .drink {
            switch entry.beverageType {
            case .water: return "drop.fill"
            case .coffee: return "cup.and.saucer.fill"
            case .tea: return "leaf.fill"
            case .juice: return "takeoutbag.and.cup.and.straw.fill"
            case .soda: return "bubbles.and.sparkles.fill"
            case .alcohol: return "wineglass.fill"
            default: return "drop"
            }
        }
        return "fork.knife"
    }

    private var iconColor: Color {
        entry.kind == .drink ? HyperliquidDrinkSmarterColors.accentInfo(for: scheme) : HyperliquidDrinkSmarterColors.accentSecondary(for: scheme)
    }
}

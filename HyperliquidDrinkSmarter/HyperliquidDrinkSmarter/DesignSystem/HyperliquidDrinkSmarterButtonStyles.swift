import SwiftUI

struct HyperliquidDrinkSmarterPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(HyperliquidDrinkSmarterTypography.bodySemibold)
            .foregroundStyle(.white)
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(HyperliquidDrinkSmarterColors.accentPrimary)
                    .opacity(configuration.isPressed ? 0.85 : 1)
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct HyperliquidDrinkSmarterSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(HyperliquidDrinkSmarterTypography.bodySemibold)
            .foregroundStyle(HyperliquidDrinkSmarterColors.accentPrimary)
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(HyperliquidDrinkSmarterColors.surfaceAlt)
                    .opacity(configuration.isPressed ? 0.7 : 1)
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct HyperliquidDrinkSmarterQuickPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(HyperliquidDrinkSmarterTypography.label)
            .foregroundStyle(HyperliquidDrinkSmarterColors.accentInfo)
            .padding(.horizontal, 14)
            .frame(height: 36)
            .background(
                Capsule()
                    .fill(HyperliquidDrinkSmarterColors.accentInfo.opacity(0.12))
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.18, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

import SwiftUI

struct PillCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(HyperliquidDrinkSmarterColors.surface(for: scheme))
                    .shadow(
                        color: HyperliquidDrinkSmarterColors.shadowTint(for: scheme),
                        radius: 24,
                        x: 0,
                        y: 10
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

extension View {
    func pillCard() -> some View {
        modifier(PillCardModifier())
    }
}

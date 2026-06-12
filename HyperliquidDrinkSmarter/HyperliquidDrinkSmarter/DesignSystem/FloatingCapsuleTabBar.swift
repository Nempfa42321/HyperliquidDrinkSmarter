import SwiftUI

enum HyperliquidDrinkSmarterLayout {
    /// Space reserved above the home indicator so content clears the floating tab bar (+ button).
    static let floatingTabBarClearance: CGFloat = 96
}

struct FloatingCapsuleTabBar: View {
    @Binding var selected: HyperliquidDrinkSmarterTab
    var onAddTapped: () -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: 0) {
            ForEach(HyperliquidDrinkSmarterTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selected = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 20, weight: .medium))
                        Text(tab.title)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(selected == tab ? HyperliquidDrinkSmarterColors.accentPrimary(for: scheme) : HyperliquidDrinkSmarterColors.textMuted(for: scheme))
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }

            Spacer()
                .frame(width: 64)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: HyperliquidDrinkSmarterColors.shadowTint(for: scheme), radius: 20, x: 0, y: 8)
        )
        .overlay(alignment: .trailing) {
            Button(action: onAddTapped) {
                ZStack {
                    Circle()
                        .fill(HyperliquidDrinkSmarterColors.accentPrimary(for: scheme))
                        .frame(width: 56, height: 56)
                        .shadow(color: HyperliquidDrinkSmarterColors.accentPrimary(for: scheme).opacity(0.35), radius: 14, x: 0, y: 6)

                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .offset(x: -12, y: -8)
            .accessibilityLabel("Add drink or meal")
        }
        .padding(.horizontal, 20)
    }
}

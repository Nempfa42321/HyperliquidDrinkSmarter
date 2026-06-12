import SwiftUI

enum HyperliquidDrinkSmarterAssets {
    static let appLogo = "AppLogo"
}

struct HyperliquidDrinkSmarterMarkView: View {
    var cornerRadius: CGFloat = 22

    var body: some View {
        Image(HyperliquidDrinkSmarterAssets.appLogo)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

struct HyperliquidDrinkSmarterBrandTitleView: View {
    enum Style {
        case hero
        case headline
        case compact
    }

    var style: Style = .hero
    var suffix: String = ""

    @Environment(\.colorScheme) private var scheme

    private var fontSize: CGFloat {
        switch style {
        case .hero: HyperliquidDrinkSmarterFontSize.brandHero
        case .headline: HyperliquidDrinkSmarterFontSize.brandHeadline
        case .compact: HyperliquidDrinkSmarterFontSize.brandCompact
        }
    }

    var body: some View {
        (Text("Hyperliquid ")
            .foregroundStyle(HyperliquidDrinkSmarterColors.textPrimary(for: scheme))
        + Text("Drink Smarter")
            .foregroundStyle(HyperliquidDrinkSmarterColors.accentPrimary(for: scheme))
        + Text(suffix)
            .foregroundStyle(HyperliquidDrinkSmarterColors.textPrimary(for: scheme)))
        .font(.custom("Quicksand-Bold", size: fontSize))
        .lineLimit(1)
        .minimumScaleFactor(0.72)
        .multilineTextAlignment(.center)
    }
}

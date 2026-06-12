import SwiftUI

struct QuickAddRow: View {
    var volumeUnit: String
    var onAdd: (Double) -> Void

    private let amountsMl: [Double] = [150, 250, 350, 500]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(amountsMl, id: \.self) { ml in
                    Button {
                        onAdd(ml)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 13, weight: .semibold))
                            Text("+\(VolumeFormatting.formatVolume(ml: ml, unit: volumeUnit))")
                                .font(HyperliquidDrinkSmarterTypography.label)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                    }
                    .buttonStyle(HyperliquidDrinkSmarterQuickPillButtonStyle())
                }
            }
            .padding(.horizontal, 2)
        }
    }
}

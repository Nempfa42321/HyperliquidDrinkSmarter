import SwiftUI

struct LiquidProgressRing: View {
    let currentMl: Double
    let goalMl: Double
    let unitLabel: String
    var diameter: CGFloat = 260

    @Environment(\.colorScheme) private var colorScheme
    @State private var wavePhase: CGFloat = 0

    private let ringLineWidth: CGFloat = 18

    private var progress: Double {
        guard goalMl > 0 else { return 0 }
        return min(max(currentMl / goalMl, 0), 1)
    }

    var body: some View {
        let size = diameter
        let innerSize = size * 0.82

        ZStack {
            Circle()
                .stroke(HyperliquidDrinkSmarterColors.surfaceAlt(for: colorScheme), lineWidth: ringLineWidth)
                .frame(width: size, height: size)

            ZStack {
                Circle()
                    .fill(HyperliquidDrinkSmarterColors.accentInfo(for: colorScheme).opacity(0.15))

                WaveShape(amplitude: 6, wavelength: innerSize * 0.45, phase: wavePhase)
                    .fill(HyperliquidDrinkSmarterColors.accentInfo(for: colorScheme).opacity(0.55))
                    .offset(y: (1 - progress) * (innerSize * 0.41))
            }
            .frame(width: innerSize, height: innerSize)
            .clipShape(Circle())

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [
                            HyperliquidDrinkSmarterColors.accentInfo(for: colorScheme),
                            HyperliquidDrinkSmarterColors.accentPrimary(for: colorScheme),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text(VolumeFormatting.formatVolumeNumber(currentMl, unit: unitLabel))
                    .font(HyperliquidDrinkSmarterTypography.progressNumber)
                    .foregroundStyle(HyperliquidDrinkSmarterColors.textPrimary(for: colorScheme))
                    .contentTransition(.numericText())

                Text("/  \(VolumeFormatting.formatVolume(ml: goalMl, unit: unitLabel))")
                    .font(HyperliquidDrinkSmarterTypography.subheadline)
                    .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: colorScheme))
            }
            .zIndex(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(HyperliquidDrinkSmarterColors.background(for: colorScheme).opacity(0.72))
            )
        }
        .frame(width: size, height: size)
        .padding(ringLineWidth / 2)
        .onAppear {
            withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                wavePhase = .pi * 2
            }
        }
    }
}

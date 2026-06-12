import SwiftUI

struct AddDrinkSheet: View {
    var onAdd: (BeverageType, Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    @AppStorage(HyperliquidDrinkSmarterSettingsKeys.volumeUnit) private var volumeUnit = "ml"

    @State private var selectedType: BeverageType = .water
    @State private var displayVolume: Double = 250

    private var isOz: Bool { VolumeFormatting.isOz(volumeUnit) }

    private var quickAmounts: [Double] {
        isOz ? [5, 8, 12, 17] : [150, 250, 330, 500]
    }

    private var volumeRange: ClosedRange<Double> {
        isOz ? 2...50 : 50...1500
    }

    private var step: Double { isOz ? 1 : 50 }

    var body: some View {
        NavigationStack {
            Form {
                Section("Beverage") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(BeverageType.allCases, id: \.self) { t in
                            Text(t.displayName).tag(t)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Amount") {
                    Stepper(value: $displayVolume, in: volumeRange, step: step) {
                        HStack {
                            Text("\(Int(displayVolume.rounded()))")
                                .font(HyperliquidDrinkSmarterTypography.progressNumber)
                            Text(VolumeFormatting.unitSuffix(volumeUnit))
                                .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
                        }
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(quickAmounts, id: \.self) { amount in
                                Button("\(Int(amount)) \(VolumeFormatting.unitSuffix(volumeUnit))") {
                                    displayVolume = amount
                                }
                                .buttonStyle(HyperliquidDrinkSmarterQuickPillButtonStyle())
                            }
                        }
                    }
                }

                Section {
                    let volumeMl = VolumeFormatting.displayToMl(displayVolume, unit: volumeUnit)
                    let factor = selectedType.defaultHydrationFactor
                    let net = volumeMl * factor
                    Text("Hydration factor: \(String(format: "%.2f", factor)) → ~\(VolumeFormatting.formatVolume(ml: net, unit: volumeUnit)) net contribution")
                        .font(HyperliquidDrinkSmarterTypography.footnote)
                        .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
                }
            }
            .navigationTitle("Add Drink")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let ml = VolumeFormatting.displayToMl(displayVolume, unit: volumeUnit)
                        onAdd(selectedType, ml)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .onAppear {
                displayVolume = isOz ? 8 : 250
            }
            .onChange(of: volumeUnit) { _, _ in
                displayVolume = isOz ? 8 : 250
            }
        }
        .presentationDetents([.medium])
    }
}

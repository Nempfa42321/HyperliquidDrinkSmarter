import SwiftUI
import SwiftData

struct LogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var scheme

    @State private var intakeRepo: IntakeRepository?
    @State private var entries: [IntakeEntry] = []
    @State private var selectedDate: Date = .now
    @State private var showAddDrink = false
    @State private var showAddMeal = false
    @State private var editingEntry: IntakeEntry? = nil

    private var grouped: [String: [IntakeEntry]] {
        Dictionary(grouping: entries) { entry in
            timeOfDay(for: entry.timestamp)
        }
    }

    private let timeOrder = ["Morning", "Afternoon", "Evening", "Night"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { changeDay(by: -1) } label: { Image(systemName: "chevron.left") }
                Spacer()
                Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                    .font(HyperliquidDrinkSmarterTypography.headline)
                Spacer()
                Button { changeDay(by: 1) } label: { Image(systemName: "chevron.right") }
                if !Calendar.current.isDateInToday(selectedDate) {
                    Button("Today") { selectedDate = .now }
                        .font(HyperliquidDrinkSmarterTypography.caption)
                        .padding(.leading, 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            if entries.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(timeOrder, id: \.self) { period in
                        if let items = grouped[period], !items.isEmpty {
                            Section(period) {
                                ForEach(items, id: \.id) { entry in
                                    IntakeRow(entry: entry)
                                        .swipeActions(edge: .leading) {
                                            Button {
                                                editingEntry = entry
                                            } label: { Label("Edit", systemImage: "pencil") }
                                                .tint(HyperliquidDrinkSmarterColors.accentPrimary(for: scheme))
                                        }
                                        .swipeActions {
                                            Button(role: .destructive) {
                                                delete(entry)
                                            } label: { Label("Delete", systemImage: "trash") }
                                        }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .background(HyperliquidDrinkSmarterColors.background(for: scheme).ignoresSafeArea())
        .navigationTitle("Log")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Add Drink") { showAddDrink = true }
                    Button("Add Meal") { showAddMeal = true }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(HyperliquidDrinkSmarterColors.accentPrimary(for: scheme))
                }
            }
        }
        .onAppear(perform: reload)
        .onChange(of: selectedDate) { _, _ in reload() }
        .sheet(isPresented: $showAddDrink) {
            AddDrinkSheet { type, volume in
                addDrink(type: type, volume: volume)
                showAddDrink = false
            }
        }
        .sheet(isPresented: $showAddMeal) {
            AddMealSheet { desc, cal, p, c, f, src in
                addMeal(desc: desc, cal: cal, p: p, c: c, f: f, source: src)
                showAddMeal = false
            }
        }
        .sheet(item: $editingEntry) { entry in
            EditIntakeSheet(entry: entry) { updated in
                intakeRepo?.update(updated)
                reload()
                editingEntry = nil
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "drop")
                .font(.system(size: 48))
                .foregroundStyle(HyperliquidDrinkSmarterColors.accentInfo(for: scheme).opacity(0.6))
            Text("Nothing logged yet for this day")
                .font(HyperliquidDrinkSmarterTypography.headline)
            Text("Use the + button or the floating action to add your first drink or meal.")
                .font(HyperliquidDrinkSmarterTypography.body)
                .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted(for: scheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func timeOfDay(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<12: return "Morning"
        case 12..<17: return "Afternoon"
        case 17..<22: return "Evening"
        default: return "Night"
        }
    }

    private func changeDay(by days: Int) {
        if let new = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            selectedDate = new
        }
    }

    private func reload() {
        let repo = IntakeRepository(modelContext: modelContext)
        intakeRepo = repo
        entries = repo.fetchEntries(for: selectedDate)
    }

    private func addDrink(type: BeverageType, volume: Double) {
        guard let repo = intakeRepo else { return }
        LogIntakeUseCase(repository: repo).logDrink(type: type, volumeMl: volume)
        reload()
    }

    private func addMeal(desc: String, cal: Int?, p: Double?, c: Double?, f: Double?, source: EstimateSource?) {
        guard let repo = intakeRepo else { return }
        LogIntakeUseCase(repository: repo).logMeal(description: desc, calories: cal, protein: p, carbs: c, fat: f, source: source)
        reload()
    }

    private func delete(_ entry: IntakeEntry) {
        intakeRepo?.delete(entry)
        reload()
    }
}

private struct EditIntakeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    @AppStorage(HyperliquidDrinkSmarterSettingsKeys.volumeUnit) private var volumeUnit = "ml"

    let entry: IntakeEntry
    var onSave: (IntakeEntry) -> Void

    @State private var displayVolume: Double
    @State private var calories: Int
    @State private var protein: Double
    @State private var carbs: Double
    @State private var fat: Double
    @State private var mealDesc: String

    init(entry: IntakeEntry, onSave: @escaping (IntakeEntry) -> Void) {
        self.entry = entry
        self.onSave = onSave
        let ml = entry.volumeMl ?? 250
        _displayVolume = State(initialValue: VolumeFormatting.mlToDisplay(ml, unit: UserDefaults.standard.string(forKey: HyperliquidDrinkSmarterSettingsKeys.volumeUnit) ?? "ml"))
        _calories = State(initialValue: entry.estimatedCalories ?? 0)
        _protein = State(initialValue: entry.proteinG ?? 0)
        _carbs = State(initialValue: entry.carbsG ?? 0)
        _fat = State(initialValue: entry.fatG ?? 0)
        _mealDesc = State(initialValue: entry.mealDescription ?? "")
    }

    private var isOz: Bool { VolumeFormatting.isOz(volumeUnit) }

    var body: some View {
        NavigationStack {
            Form {
                if entry.kind == .drink {
                    Section("Drink volume") {
                        Stepper(value: $displayVolume, in: isOz ? 2...50 : 50...2000, step: isOz ? 1 : 50) {
                            Text(VolumeFormatting.formatVolume(
                                ml: VolumeFormatting.displayToMl(displayVolume, unit: volumeUnit),
                                unit: volumeUnit
                            ))
                        }
                    }
                } else {
                    Section("Meal description") {
                        TextField("Description", text: $mealDesc, axis: .vertical)
                            .lineLimit(2...4)
                    }
                    Section("Nutrition") {
                        Stepper("Calories: \(calories)", value: $calories, in: 0...3000, step: 10)
                        Stepper("Protein: \(Int(protein)) g", value: $protein, in: 0...200, step: 1)
                        Stepper("Carbs: \(Int(carbs)) g", value: $carbs, in: 0...300, step: 1)
                        Stepper("Fat: \(Int(fat)) g", value: $fat, in: 0...150, step: 1)
                    }
                }
            }
            .navigationTitle("Edit \(entry.kind == .drink ? "Drink" : "Meal")")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if entry.kind == .drink {
                            entry.volumeMl = VolumeFormatting.displayToMl(displayVolume, unit: volumeUnit)
                        } else {
                            entry.mealDescription = mealDesc.isEmpty ? nil : mealDesc
                            entry.estimatedCalories = calories
                            entry.proteinG = protein
                            entry.carbsG = carbs
                            entry.fatG = fat
                            if entry.estimateSource == .ai { entry.estimateSource = .manual }
                        }
                        onSave(entry)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

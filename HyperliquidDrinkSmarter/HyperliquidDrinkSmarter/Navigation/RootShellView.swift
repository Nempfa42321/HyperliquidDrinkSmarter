import SwiftUI
import SwiftData

struct HyperliquidDrinkSmarterShellView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var scheme

    @State private var selectedTab: HyperliquidDrinkSmarterTab = .today
    @State private var showAddSheet = false         
    @State private var showAddDrink = false
    @State private var showAddMeal = false
    @State private var showSettings = false

    @State private var contentRefreshToken = 0

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Group {
                    switch selectedTab {
                    case .today:
                        TodayView()
                    case .log:
                        LogView()
                    case .coach:
                        CoachView()
                    case .trends:
                        TrendsView()
                    }
                }
                .id(contentRefreshToken)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedTab)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    Color.clear
                        .frame(height: HyperliquidDrinkSmarterLayout.floatingTabBarClearance)
                        .accessibilityHidden(true)
                }

                FloatingCapsuleTabBar(
                    selected: $selectedTab,
                    onAddTapped: { showAddSheet = true }
                )
                .padding(.bottom, 16)
            }
            .background(HyperliquidDrinkSmarterColors.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        HStack(spacing: 8) {
                            HyperliquidDrinkSmarterMarkView(cornerRadius: 7)
                                .frame(width: 26, height: 26)

                            HStack(spacing: 4) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Settings")
                                    .font(HyperliquidDrinkSmarterTypography.label)
                            }
                            .foregroundStyle(HyperliquidDrinkSmarterColors.accentPrimary(for: scheme))
                        }
                    }
                    .accessibilityLabel("Settings")
                    .accessibilityHint("Opens app settings")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddActionSheet(
                onDrink: {
                    showAddSheet = false
                    showAddDrink = true
                },
                onMeal: {
                    showAddSheet = false
                    showAddMeal = true
                }
            )
        }
        .sheet(isPresented: $showAddDrink) {
            AddDrinkSheet { type, volume in
                logDrink(type: type, volumeMl: volume)
                showAddDrink = false
            }
        }
        .sheet(isPresented: $showAddMeal) {
            AddMealSheet { desc, cal, p, c, f, src in
                logMeal(description: desc, calories: cal, protein: p, carbs: c, fat: f, source: src)
                showAddMeal = false
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .tint(HyperliquidDrinkSmarterColors.accentPrimary)
    }


    private func logDrink(type: BeverageType, volumeMl: Double) {
        let useCase = LogIntakeUseCase(repository: IntakeRepository(modelContext: modelContext))
        useCase.logDrink(type: type, volumeMl: volumeMl)
        contentRefreshToken += 1
    }

    private func logMeal(description: String, calories: Int?, protein: Double?, carbs: Double?, fat: Double?, source: EstimateSource?) {
        let useCase = LogIntakeUseCase(repository: IntakeRepository(modelContext: modelContext))
        useCase.logMeal(description: description, calories: calories, protein: protein, carbs: carbs, fat: fat, source: source)
        contentRefreshToken += 1
    }
}

private struct AddActionSheet: View {
    var onDrink: () -> Void
    var onMeal: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Log something")
                    .font(HyperliquidDrinkSmarterTypography.headline)
                    .foregroundStyle(HyperliquidDrinkSmarterColors.textPrimary)

                Button(action: onDrink) {
                    Label("Drink", systemImage: "drop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(HyperliquidDrinkSmarterPrimaryButtonStyle())

                Button(action: onMeal) {
                    Label("Meal", systemImage: "fork.knife")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(HyperliquidDrinkSmarterSecondaryButtonStyle())

                Text("You can also tap + from any screen")
                    .font(HyperliquidDrinkSmarterTypography.caption)
                    .foregroundStyle(HyperliquidDrinkSmarterColors.textMuted)
            }
            .padding(32)
            .navigationTitle("Quick Add")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.height(280)])
    }
}

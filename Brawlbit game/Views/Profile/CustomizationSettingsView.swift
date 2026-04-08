import SwiftUI
import SwiftData

struct CustomizationSettingsView: View {
    let hero: Hero
    @Environment(\.modelContext) private var modelContext

    @State private var confirmPurchase: PurchaseTarget? = nil

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Coin balance banner
                    HStack(spacing: 8) {
                        Text("🪙")
                            .font(.system(size: 18))
                        Text("\(hero.coins) coins")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.82, blue: 0.2))
                        Spacer()
                        Text("Heroes \(Hero.heroCost)🪙  ·  Arenas \(Hero.arenaCost)🪙")
                            .font(.system(size: 11))
                            .foregroundColor(Color(white: 0.35))
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color(white: 0.12))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                    // ── Hero class ───────────────────────────────────────
                    sectionHeader("HERO CLASS")

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(HeroClass.allCases, id: \.self) { cls in
                            let owned = hero.unlockedHeroClasses.contains(cls.rawValue)
                            let selected = hero.heroClass == cls

                            Button {
                                if owned {
                                    hero.heroClass = cls
                                    try? modelContext.save()
                                } else {
                                    confirmPurchase = PurchaseTarget(kind: .hero(cls))
                                }
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    VStack(spacing: 6) {
                                        Image(cls.idleFrames[0])
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 64)
                                            .opacity(owned ? 1.0 : 0.35)
                                        Text(cls.displayName)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(selected ? .orange : (owned ? Color(white: 0.5) : Color(white: 0.3)))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(selected ? Color.orange.opacity(0.12) : Color(white: 1, opacity: 0.05))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selected ? Color.orange : Color.clear, lineWidth: 1.5)
                                    )

                                    if !owned {
                                        HStack(spacing: 2) {
                                            Text("🪙")
                                                .font(.system(size: 9))
                                            Text("\(Hero.heroCost)")
                                                .font(.system(size: 9, weight: .bold))
                                                .foregroundColor(Color(red: 1.0, green: 0.82, blue: 0.2))
                                        }
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 3)
                                        .background(Color(white: 0.08))
                                        .cornerRadius(6)
                                        .padding(5)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                    divider()

                    // ── Arena ────────────────────────────────────────────
                    sectionHeader("ARENA")

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(Battleground.allCases, id: \.self) { arena in
                            let owned = hero.unlockedBattlegrounds.contains(arena.rawValue)
                            let selected = hero.battleground == arena

                            Button {
                                if owned {
                                    hero.battleground = arena
                                    try? modelContext.save()
                                } else {
                                    confirmPurchase = PurchaseTarget(kind: .arena(arena))
                                }
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    ZStack(alignment: .bottomLeading) {
                                        Image(arena.assetName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 80)
                                            .clipped()
                                            .opacity(owned ? 1.0 : 0.4)
                                        Text(arena.displayName)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(owned ? .white : Color(white: 0.5))
                                            .padding(6)
                                    }
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selected ? Color.orange : Color.clear, lineWidth: 2)
                                    )

                                    if !owned {
                                        HStack(spacing: 2) {
                                            Text("🪙")
                                                .font(.system(size: 9))
                                            Text("\(Hero.arenaCost)")
                                                .font(.system(size: 9, weight: .bold))
                                                .foregroundColor(Color(red: 1.0, green: 0.82, blue: 0.2))
                                        }
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 3)
                                        .background(Color(white: 0.08, opacity: 0.9))
                                        .cornerRadius(6)
                                        .padding(6)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Customization")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            // Migrate heroes created before the unlock system existed
            if hero.unlockedHeroClasses.isEmpty {
                hero.unlockedHeroClasses = [hero.heroClass.rawValue]
                try? modelContext.save()
            }
            if hero.unlockedBattlegrounds.isEmpty {
                hero.unlockedBattlegrounds = [hero.battleground.rawValue]
                try? modelContext.save()
            }
        }
        .confirmationDialog(purchaseDialogTitle, isPresented: .init(
            get: { confirmPurchase != nil },
            set: { if !$0 { confirmPurchase = nil } }
        ), titleVisibility: .visible) {
            if let target = confirmPurchase {
                let cost = target.cost
                if hero.coins >= cost {
                    Button("Buy for \(cost) 🪙") {
                        executePurchase(target)
                    }
                } else {
                    Button("Not enough coins (\(hero.coins)/\(cost))", role: .cancel) { }
                }
                Button("Cancel", role: .cancel) { confirmPurchase = nil }
            }
        } message: {
            if let target = confirmPurchase {
                Text(purchaseMessage(for: target))
            }
        }
    }

    // MARK: - Purchase logic

    private var purchaseDialogTitle: String {
        guard let target = confirmPurchase else { return "" }
        switch target.kind {
        case .hero(let cls):   return "Unlock \(cls.displayName)?"
        case .arena(let arena): return "Unlock \(arena.displayName) Arena?"
        }
    }

    private func purchaseMessage(for target: PurchaseTarget) -> String {
        if hero.coins >= target.cost {
            return "This will cost \(target.cost) 🪙. You have \(hero.coins)."
        } else {
            return "You need \(target.cost) 🪙 but only have \(hero.coins). Keep battling to earn more coins!"
        }
    }

    private func executePurchase(_ target: PurchaseTarget) {
        hero.coins -= target.cost
        switch target.kind {
        case .hero(let cls):
            if !hero.unlockedHeroClasses.contains(cls.rawValue) {
                hero.unlockedHeroClasses.append(cls.rawValue)
            }
            hero.heroClass = cls
        case .arena(let arena):
            if !hero.unlockedBattlegrounds.contains(arena.rawValue) {
                hero.unlockedBattlegrounds.append(arena.rawValue)
            }
            hero.battleground = arena
        }
        try? modelContext.save()
        confirmPurchase = nil
    }

    // MARK: - Helpers

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.orange)
            .tracking(1)
            .padding(.horizontal, 24)
            .padding(.bottom, 14)
    }

    @ViewBuilder
    private func divider() -> some View {
        Rectangle()
            .fill(Color(white: 1, opacity: 0.07))
            .frame(height: 1)
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
    }
}

// MARK: - Purchase target

private struct PurchaseTarget: Identifiable {
    enum Kind {
        case hero(HeroClass)
        case arena(Battleground)
    }
    let id = UUID()
    let kind: Kind

    var cost: Int {
        switch kind {
        case .hero:  return Hero.heroCost
        case .arena: return Hero.arenaCost
        }
    }
}

import SwiftUI

struct ContentView: View {
    @StateObject private var game = GameState()

    @State private var selectedDrugToBuy: Drug?
    @State private var selectedDrugToSell: Drug?

    @State private var buyQuantity: Int = 1
    @State private var sellQuantity: Int = 1

    var body: some View {
        NavigationStack {
            VStack {
                header

                List {
                    Section("Market in \(game.currentCity.name)") {
                        ForEach(game.drugs) { drug in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(drug.name)
                                        .font(.headline)
                                    if let price = game.prices[drug] {
                                        Text("$\(price)")
                                            .font(.subheadline)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("You own: \(game.inventory[drug, default: 0])")
                                        .font(.subheadline)
                                    HStack {
                                        Button("Buy") {
                                            selectedDrugToBuy = drug
                                            buyQuantity = 1
                                        }
                                        .buttonStyle(.bordered)

                                        Button("Sell") {
                                            selectedDrugToSell = drug
                                            sellQuantity = 1
                                        }
                                        .buttonStyle(.bordered)
                                    }
                                }
                            }
                        }
                    }

                    Section("Travel") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(game.cities) { city in
                                    Button(city.name) {
                                        game.travel(to: city)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(city == game.currentCity ? nil : .gray)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                footer
            }
            .navigationTitle("Dope Trader")
            .sheet(item: $selectedDrugToBuy) { drug in
                quantitySheet(
                    title: "Buy \(drug.name)",
                    price: game.prices[drug] ?? 0,
                    quantity: $buyQuantity
                ) {
                    game.buy(drug, quantity: buyQuantity)
                }
            }
            .sheet(item: $selectedDrugToSell) { drug in
                quantitySheet(
                    title: "Sell \(drug.name)",
                    price: game.prices[drug] ?? 0,
                    quantity: $sellQuantity
                ) {
                    game.sell(drug, quantity: sellQuantity)
                }
            }
            .alert("Game Over", isPresented: .constant(game.isGameOver)) {
                Button("Restart") {
                    game.resetGame()
                }
            } message: {
                Text("You survived \(game.maxDays) days.\nFinal cash: $\(game.cash)\nDebt: $\(game.debt)")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Day \(game.day)/\(game.maxDays)")
                Spacer()
                Text("Days left: \(game.daysLeft)")
            }
            HStack {
                Text("Cash: $\(game.cash)")
                Spacer()
                Text("Debt: $\(game.debt)")
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var footer: some View {
        HStack {
            Button("Next Day") {
                game.nextDay()
            }
            .buttonStyle(.borderedProminent)
            .disabled(game.isGameOver)
        }
        .padding()
    }

    // Reusable quantity sheet
    @ViewBuilder
    private func quantitySheet(
        title: String,
        price: Int,
        quantity: Binding<Int>,
        onConfirm: @escaping () -> Void
    ) -> some View {
        NavigationStack {
            Form {
                Section {
                    Stepper("Quantity: \(quantity.wrappedValue)", value: quantity, in: 1...999)
                    Text("Price each: $\(price)")
                    Text("Total: $\(price * quantity.wrappedValue)")
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") {
                        onConfirm()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // sheet dismisses automatically via binding
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

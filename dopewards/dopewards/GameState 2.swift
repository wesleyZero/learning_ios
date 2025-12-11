import Foundation

struct Drug: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let minPrice: Int
    let maxPrice: Int
}

struct City: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

final class GameState: ObservableObject {
    @Published var day: Int = 1
    @Published var maxDays: Int = 30

    @Published var cash: Int = 2000
    @Published var debt: Int = 5500

    @Published var currentCity: City
    @Published var prices: [Drug: Int] = [:]
    @Published var inventory: [Drug: Int] = [:]

    let cities: [City]
    let drugs: [Drug]

    init() {
        self.cities = [
            City(name: "Bronx"),
            City(name: "Brooklyn"),
            City(name: "Manhattan"),
            City(name: "Queens"),
            City(name: "Staten Island")
        ]

        self.drugs = [
            Drug(name: "Weed",     minPrice: 100,  maxPrice: 800),
            Drug(name: "Coke",     minPrice: 500,  maxPrice: 5000),
            Drug(name: "Heroin",   minPrice: 1000, maxPrice: 8000),
            Drug(name: "Acid",     minPrice: 150,  maxPrice: 1200),
            Drug(name: "Speed",    minPrice: 80,   maxPrice: 900)
        ]

        self.currentCity = cities.first!

        for d in drugs {
            inventory[d] = 0
        }

        rollPrices()
    }

    var daysLeft: Int {
        maxDays - day + 1
    }

    func rollPrices() {
        var newPrices: [Drug: Int] = [:]
        for d in drugs {
            let price = Int.random(in: d.minPrice...d.maxPrice)
            newPrices[d] = price
        }
        prices = newPrices
    }

    func buy(_ drug: Drug, quantity: Int) {
        guard quantity > 0 else { return }
        guard let price = prices[drug] else { return }

        let totalCost = price * quantity
        guard totalCost <= cash else { return }

        cash -= totalCost
        inventory[drug, default: 0] += quantity
    }

    func sell(_ drug: Drug, quantity: Int) {
        guard quantity > 0 else { return }
        let owned = inventory[drug, default: 0]
        guard quantity <= owned else { return }
        guard let price = prices[drug] else { return }

        let revenue = price * quantity
        cash += revenue
        inventory[drug] = owned - quantity
    }

    func travel(to city: City) {
        currentCity = city
        rollPrices()
    }

    func nextDay() {
        guard day < maxDays else { return }
        day += 1
        rollPrices()
    }

    var isGameOver: Bool {
        day >= maxDays
    }

    func resetGame() {
        day = 1
        cash = 2000
        debt = 5500
        currentCity = cities.first!
        for d in drugs {
            inventory[d] = 0
        }
        rollPrices()
    }
}

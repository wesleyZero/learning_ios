//
//  ContentView.swift
//  BetterRest2
//
//  Created by Wesley Johanson on 12/10/25.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = Date.now
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1

    var body: some View {
        NavigationStack {
            VStack {
                Text("When do you want to wake up?")
                    .font(.headline)

                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute).labelsHidden()

                Text("Desired amount of sleep").font(.headline)

                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)

                Stepper("How much coffee do you take / day?", value: $coffeeAmount, in: 1...20, step: 1)

            }
            .navigationTitle("Better Rest")
            .toolbar {
                Button("Calc", action: calculatedBedtime)
            }
        }
    }

    func calculatedBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            // TODO: Use the model with inputs to compute bedtime and present it to the user.
        } catch {
            // Handle model loading errors appropriately.
            print("Failed to load SleepCalculator: \(error)")
        }
    }
}

#Preview {
    ContentView()
}

//
//  ContentView.swift
//  hws_prj1_day2
//
//  Created by Wesley Johanson on 12/9/25.
//

import SwiftUI

struct ContentView: View {
    @State private var checkAmount = 0.0
    @State private var numOfPpl = 0
    @State private var tipPercentage = 20
    private let MIN_NUM_PPL: Int = 2
    @State private var people: [String] = Array(repeating: "", count: 100)

    private var checkWithTip: Double {
        checkAmount * (1 + Double(tipPercentage) / 100.0)
    }
    
    private var checkWithTipPerPerson: Double {
        checkWithTip / Double(numOfPpl + MIN_NUM_PPL)
    }
    
    private func sumOfExceptions(for personIndex: Int) -> Double {
        exceptions.filter { $0.personIndex == personIndex }.reduce(0) { $0 + $1.amount }
    }
    
    private func totalForPerson(index: Int) -> Double {
        checkWithTipPerPerson + sumOfExceptions(for: index)
    }
    
    @FocusState private var amountIsFocused: Bool
    @FocusState private var pplIsFocused: Bool
    
    var tipPercentages = [10, 15, 20, 25, 30, 0]
    
//    @State private var exceptions: [String] = []
    @State private var exceptions: [Exception] = []
    @State private var isPresentingNewException: Bool = false
    @State private var newExceptionLabel: String = ""
    @State private var newExceptionAmount: Double = 0.0
    @State private var selectedPersonIndexForException: Int? = nil

    struct Exception: Identifiable, Hashable {
        let id = UUID()
        var personIndex: Int
        var label: String
        var amount: Double
    }
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(
                        "Amount",
                        value: $checkAmount,
                        format: .currency(code: Locale.current.currency?.identifier ?? "USD"),
                        prompt: Text("Amount")
                        //
                    )
                    .keyboardType(.decimalPad)
                    .focused($amountIsFocused)
                    
                    Picker("Number of People", selection: $numOfPpl) {
                        ForEach(MIN_NUM_PPL..<100) {
                            Text("\($0)")
                        }
                    }
                }
                
                Section("Names of People") {
                    Stepper("\(numOfPpl + MIN_NUM_PPL) people", value: $numOfPpl, in: 0...numOfPpl + MIN_NUM_PPL)
                    
                    ForEach(0..<numOfPpl + MIN_NUM_PPL, id: \.self) { index in
                        TextField("Person \(index + 1)", text: self.$people[index])
                            .focused($pplIsFocused)
                    }
                }
                
                Section ("How much do you want to tip?") {
                    Picker("Tip Percentage", selection: $tipPercentage) {
                        ForEach(tipPercentages, id: \.self) {
                            Text("\($0)%")
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Total Check with Tip") {
                    Text(checkWithTip, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                }
                
                Section("Check with Tip / Person (before exceptions)"){
                    Text(checkWithTipPerPerson, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                }
                
                
          
                ForEach(0..<numOfPpl + MIN_NUM_PPL, id: \.self) { index in
                        let name = people[index].isEmpty
                            ? "Person \(index + 1)"
                            : people[index]

                    Section("Check with Tip For \(name)"){
                        Text(totalForPerson(index: index), format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        Button {
                            selectedPersonIndexForException = index
                            newExceptionLabel = ""
                            newExceptionAmount = 0.0
                            isPresentingNewException = true
                        } label: {
                            Label("Add exception", systemImage: "plus.circle.fill")
                                .foregroundStyle(.blue)
                        }
                        ForEach(exceptions.filter { $0.personIndex == index }) { exception in
                            HStack {
                                Text(exception.label)
                                Spacer()
                                Text(exception.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                    .foregroundStyle(.secondary)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    if let idx = exceptions.firstIndex(where: { $0.id == exception.id }) {
                                        exceptions.remove(at: idx)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    }
    
            }
            .navigationTitle("WeSplit")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        amountIsFocused = false
                        pplIsFocused = false
                    }
                    Button("Print Tip %") {
                        print("tip percentage is \(tipPercentage)")
                    }
                    
                }
            }
            
            
            // Sheet for adding a new exception
            .sheet(isPresented: $isPresentingNewException) {
                NavigationStack {
                    Form {
                        Section("New exception") {
                            TextField("Label", text: $newExceptionLabel)
                            
                            TextField(
                                "Amount",
                                value: $newExceptionAmount,
                                format: .number
                            )
                            .keyboardType(.decimalPad)
                        }
                    }
                    .navigationTitle("Add exception")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingNewException = false
                                selectedPersonIndexForException = nil
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                guard let personIndex = selectedPersonIndexForException else {
                                    isPresentingNewException = false
                                    return
                                }
                                let newException = Exception(
                                    personIndex: personIndex,
                                    label: newExceptionLabel,
                                    amount: newExceptionAmount
                                )
                                exceptions.append(newException)
                                isPresentingNewException = false
                                selectedPersonIndexForException = nil
                            }
                        }
                    }
                }
            }

            
        }
        
        
    }
}

#Preview {
    ContentView()
}

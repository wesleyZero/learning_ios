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
        checkWithTip / Double(numOfPpl)
    }
    
    @FocusState private var amountIsFocused: Bool
    @FocusState private var pplIsFocused: Bool
    
    var tipPercentages = [10, 15, 20, 25, 30, 0]
    
//    @State private var exceptions: [String] = []
    @State private var exceptions: [Exception] = []
    @State private var isPresentingNewException: Bool = false
    @State private var newExceptionLabel: String = ""
    @State private var newExceptionAmount: Double = 0.0
    struct Exception: Identifiable, Hashable {
        let id = UUID()
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
                
                Section("Check with Tip") {
                    Text(checkWithTip, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                }
                
                Section("Check with Tip / Person"){
                    Text(checkWithTipPerPerson, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                }
                
                Section("Check with Tip For person A"){
//                    TextField()
                    Text(checkWithTipPerPerson, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    Button {
                        let newLabel = "Exception \(exceptions.count + 1)"
                        
                        isPresentingNewException = true
                        
                        
                        
//                        excepuse
//                        tions.append(Exception(label: newLabel, amount: 0))
//                        print(exceptions)
                    } label: {
                        Label("Add exception", systemImage: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                   
                    
                    
                    
                    ForEach(exceptions) { exception in
                        HStack {
                            Text(exception.label)
                            Spacer()
                            Text("2nd col").foregroundStyle(.secondary)
                            Spacer()
                            Text(exception.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                .foregroundStyle(.secondary)
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
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                let newException = Exception(
                                    label: newExceptionLabel,
                                    amount: newExceptionAmount
                                )
                                exceptions.append(newException)
                                isPresentingNewException = false
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


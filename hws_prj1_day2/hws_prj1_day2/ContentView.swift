//
//  ContentView.swift
//  hws_prj1_day2
//
//  Created by Wesley Johanson on 12/9/25.
//

import SwiftUI

struct ContentView: View {
    @State private var checkAmount = 0.0
    @State private var numOfPpl = 2
    @State private var tipPercentage = 20
    private let MIN_NUM_PPL: Int = 2

    private var checkWithTip: Double {
        checkAmount * (1 + Double(tipPercentage) / 100.0)
    }
    private var checkWithTipPerPerson: Double {
        checkWithTip / Double(numOfPpl)
    }
    
    @FocusState private var amountIsFocused: Bool
    
    var tipPercentages = [10, 15, 20, 25, 30, 0]
    
    @State private var exceptions: [String] = []
    
    
    
    var body: some View {
        NavigationStack {
            Form {
                //FORM 1
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
                    
//                    Text("How much would you like to tip?")
//                    Picker("Tip Percentage", selection: $tipPercentage) {
//                        ForEach(tipPercentages, id: \.self) {
//                            Text("\($0)%")
//                        }
//                    }
//                    .pickerStyle(.segmented)
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
                        exceptions.append(newLabel)
                        print(exceptions)
                    } label: {
                        Label("Add exception", systemImage: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
                
                
                
            }
            .navigationTitle("WeSplit")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        amountIsFocused = false
                    }
                    Button("Print Tip %") {
                        print("tip percentage is \(tipPercentage)")
                    }
                    
                }
            }
        }
        
        
    }
}

#Preview {
    ContentView()
}

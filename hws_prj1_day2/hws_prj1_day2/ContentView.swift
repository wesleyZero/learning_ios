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
    @State private var tipPercentage = 20.0
    
    @FocusState private var amountIsFocused: Bool
    
    var tipPercentages = [10, 15, 20, 25, 30, 0]
    
    
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
                        ForEach(2..<100) {
                            Text("\($0)")
                        }
                    }
                    
                    
                    

                }
                Section {
                    Text(checkAmount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                }
            }
            .navigationTitle("WeSplit")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        amountIsFocused.toggle()
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

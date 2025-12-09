//
//  ContentView.swift
//  WeSplit
//
//  Created by Wesley Johanson on 11/27/25.
//

import SwiftUI

struct ContentView: View {
    @State private var checkAmount: Double = 0
    @State private var tipPercentage: Int = 15
    @State private var maxPeople = 30
    @State private var numPpl: Int = 25

    var body: some View {
        Form {
            Section{
                TextField("Amount", value: $checkAmount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .keyboardType(.decimalPad)
            }
            Section{
                Text(checkAmount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
            }
            
            Picker("Number of people", selection: $numPpl){
                ForEach(1...numPpl, id: \.self){
                    Text("\($0) people")
                }
                
            }.pickerStyle(.navigationLink)
            }
        }
        
            
        
        
        
 
}

#Preview {
    ContentView()
}


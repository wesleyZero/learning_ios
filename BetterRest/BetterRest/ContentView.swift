//
//  ContentView.swift
//  BetterRest
//
//  Created by Wesley Johanson on 12/10/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var sleepAmount = 8.0
    @State private var wakeUp = Date()
    
    
    
    var body: some View {
        Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
            Text("\(sleepAmount, specifier: "%.2f") Hrs").bold()
        }

        DatePicker("Select your date", selection: $wakeUp, in: Date.now... )

        Text(Date.now, format: .dateTime.hour().minute()).bold()

        Text(Date.now.formatted(date: .long, time: .shortened)) 
    }
    
//    private func exampleDates() {
//        let tomorrow = Date.now.addingTimeInterval(86400)
//        let _ = Date.now...tomorrow
//    }

    func exampleDates() {
//        var components = DateComponents()
//        components.hour = 8
//        components.minute = 0
//        let date = Calendar.current.date(from: components) ?? .now

        let components = Calendar.current.dateComponents([.hour, .minute], from: .now)
        let hour = components.hour ?? 0
        let min = components.minute ?? 0




    }



}

#Preview {
    ContentView()
}

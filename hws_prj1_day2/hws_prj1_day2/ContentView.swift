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
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

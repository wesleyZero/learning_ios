//
//  ContentView.swift
//  WeSplit
//
//  Created by Wesley Johanson on 11/27/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedStudent = "x"
    let students = ["Harry", "Ron", "Luna", "Draco"]
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Select your student", selection: $selectedStudent) {
                    ForEach(students, id: \.self) {
                        Text ($0)
                    }
                }
            }
            .navigationTitle("Select a student")
        }
    }
    
    
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, new career")
//        }
//        .padding()
//    }
    
//    var body: some View {
//        NavigationStack{
//            Form {
//                Section {
//                    Text("Hello career that actually makes me happy")
//                    Text("Engineering makes me happy")
//                }
//                Section {
//                    Text("This new section of text is helping me learn")
//                }
//            }
//        .navigationTitle(" ")
//        .navigationBarTitleDisplayMode(.inline)
//        }
//    }
  
//    @State private var tapCount: Int = 0
//    
//    
//    var body: some View {
//        Button("Tap Count \(tapCount)") {
//            tapCount += 1
//        }
//        
//    }
    
    
//    @State private var name = ""
//    var body: some View {
//        Form {
//            TextField("Enter your name: ", text: $name)
//            Text("Hello, \(name)")
//        }
//    }
    
}

#Preview {
    ContentView()
}

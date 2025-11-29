//
//  ContentView.swift
//  WeSplit
//
//  Created by Wesley Johanson on 11/27/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedStudentName = "x"
    @State private var selectedStudentId = 0
    let students = ["Harry", "Ron", "Luna", "Draco"]
    struct Student: Identifiable {
        let id: Int
        let name: String
        init(_ id: Int,_ name: String) {
            self.id = id
            self.name = name
        }
    }
    @State private var testedTheButton: Int = 0
    @State private var isFavorite: Bool = false
    
    let students2 = [Student(0,"Harry"),
                     Student(1, "Ron"), Student(2,"Luna"),
                     Student(3, "Draco")]
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Select your student A", selection: $selectedStudentName) {
                    ForEach(students, id: \.self) { name in
                        Text(name)
                    }
                }
//                Picker("Select your student B", selection: $selectedStudentId) {
//                    ForEach(students2, id: \.self) {
//                        Text($0)
//                    }
//                }
                Button("Test button, tested \(testedTheButton) times") {
                    testedTheButton += 1
                }
                Button(isFavorite ? "★" : "☆") {
                    isFavorite.toggle()
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


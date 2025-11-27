import UIKit

let greet = { print("Hello, world!")}

let greet2 = { (name: String) in
    print("Hello \(name)")
}

greet()

greet2("John")

let team = ["Gloria", "stavros", "John"]

let onlyT = team.filter( { (name: String) in name.hasPrefix("J") })


let movie = """
This is a long quote
that can go onto multiple lines
"""
    
print(movie)

movie.count

movie.hasPrefix("This")
movie.hasPrefix("nope")

var score = 5
score += 1

let id = score.isMultiple(of: 4)
let rand = Int.random(in: 1...105)

let scor2 = 4.938939

var dogsAreGood = true

dogsAreGood.toggle()

var colors = [ "Blue", "Red", "Orange" ]

colors.append("SuperBlue")

colors.remove(at: 2)

colors.contains("Blue")

var employee = [
    "Name" : "John",
    "Age" : "29"
]

employee["Name", default: "Def value"]


employee["Turd", default: "nope"]

















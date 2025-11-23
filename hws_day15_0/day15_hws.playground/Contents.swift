import UIKit

let actor = "Tom Cruise 🚢"

let quote = "He tapped a sign that said \"believe\""

print(quote)

print(quote.hasPrefix("He"))


var counter = 5

for _ in 1...5 {
    print(counter)
    
    counter += 1
}

print(counter.isMultiple(of: 5))

let id = Int.random(in: 1...1000)

print(id)


let score = 3.1
let score2 = 3.10

var weWon = true

weWon.toggle()


let name = "tayor swift"
let age = 34
let message = "Hi, my name is \(name) and I am \(age) years old."
print(message)

var colors = ["red" , "blue", "green"]

print(colors[1])

colors.append("poop")


let employee = [ "steve" : 45,
                 "tim": 22]

let nums1 = Set([1,5,2,78 ,21,311])

nums1.contains(21)



let player: Int = 2
let luckyGuy: String = "not wesley"
let pi: Double = 2.340108929

let albums: Array<String> = ["1989", "21", "Enema of the State", "Lover"]

let books: Dictionary<String, String> = ["1984" : "George Orwell" ]

let teams: [String] = ["red sox"]

let otherTeam = String()

enum UIStyle {
    case light, dark, system
}

var style: UIStyle = .light

var yourstyle: UIStyle = .dark



if age > 15 {
    print("you can't vote yet ")
}else{
    print("you can vote")

}

enum Weather {
    case sun, rain, wind
}

let forecast = Weather.sun

switch forecast{
case .sun:
    print("it's a sunny day")
default:
    print("Idk man ")
}

 let ageX = 19
let canVote = ageX >= 18 ? "Yes" : "No"






























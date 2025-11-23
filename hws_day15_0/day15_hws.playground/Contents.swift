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

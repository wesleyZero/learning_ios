import UIKit

struct Game {
    var score = 0 {
        didSet {
            print("The score is now \(score)!")
        }
    }
}


var game = Game()

game.score = 10

game.score = 100 


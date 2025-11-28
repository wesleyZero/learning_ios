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


struct User {
    let id: Int
    let name: String
    let age: Int
}


func parseUser(from raw: [[String: Any]]) -> [User] {

    
    var ret = [] as [User]
    
    for data in raw {
        if let id = data["id"] as? Int,
           let name = data["name"] as? String,
           let age = data["age"] as? Int{
            var usr = User(id: id, name: name, age: age)
            ret.append(usr)
        }
        
    }
    return ret
}

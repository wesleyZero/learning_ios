import UIKit

struct Album {
    let title: String
    let artist: String
    var isReleased = false
    var vactaionDays: Int = 14
    var vacationDaysUsed: Int = 4
//    var vacationDaysLeft: Int {
//        vactaionDays - vacationDaysUsed
//    }
  
    var  vacationRemaining: Int {
        get {
            vactaionDays -  vacationDaysUsed
        }
        
        set {
            vacationRemaining = newValue
        }
    }
    
    
    func printSummary() {
        print("\(title) by \(artist). \(isReleased ? "Released" : "Not released yet." )")
    }
    
    mutating func markAsReleased() {
        isReleased = true
    }
}

var myAlbum = Album(title: "Highway to Hell", artist: "AC/DC")

myAlbum.printSummary()

myAlbum.markAsReleased()

myAlbum.printSummary()

myAlbum.vacationDaysLeft



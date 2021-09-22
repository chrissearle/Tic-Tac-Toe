import SwiftUI

struct AlertItem : Identifiable {
    let id = UUID()
    
    var title: Text
    var message : Text
    var buttonTitle : Text
}

struct AlertContext {
    static let humanWin = AlertItem(title: Text("You Win!"),
                                    message: Text("Well Done"),
                                    buttonTitle: Text("Yay!"))
    static let computerWin = AlertItem(title: Text("You Lost!"),
                                       message: Text("Oh Dear"),
                                       buttonTitle: Text("Try again!"))
    static let draw = AlertItem(title: Text("It's a draw!"),
                                message: Text(" - "),
                                buttonTitle: Text("Rematch!"))
}

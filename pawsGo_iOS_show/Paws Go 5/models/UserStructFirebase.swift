//
//  UserStructFirebase.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-06.
//

import Foundation
import FirebaseFirestoreSwift

struct UserStructFirebase : Codable {
    
    var userID : String
    var userName : String
    var userEmail : String
    var lostDogs : [String : DogStructFirebase]
    var dogs : [String : DogStructFirebase]
    var dateCreated : String
    var messagesReceived : [String : MessageStructFirebase]
    var messagesSent : [String : MessageStructFirebase]
}

//
//  MessageStructFirebase.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-06.
//

import Foundation
import FirebaseFirestoreSwift

struct MessageStructFirebase : Codable {
    
    var messageID : String
    var senderEmail : String
    var senderName : String
    var targetEmail : String
    var targetName : String
    var messageContent : String
    var date : String
}

//
//  DogStructFirebase.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-06.
//

import Foundation
import FirebaseFirestoreSwift

struct DogStructFirebase : Codable {
    
    var dogID : String? = ""
    var dogName : String?
    var animalType : String?
    var dogBreed : String?
    var dogGender : Int
    var dogAge : Int?
    var placeLastSeen : String
    var dateLastSeen : String
    var hour : Int?
    var minute : Int?
    var notes : String?
    var ownerID : String
    var ownerName : String
    var ownerEmail : String
    var dogImages : [String : String] = [:]
    var lost : Bool?
    var found : Bool?
    var locationLatLng : [String : Double] = [:]
    var locationAddress : String?
}

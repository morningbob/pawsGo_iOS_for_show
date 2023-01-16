//
//  DataController.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-15.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "LostPets")
    
    init() {
        container.loadPersistentStores{ description, error in
            if let error = error {
                print("failed to load Core Data")
            }
        }
    }
}

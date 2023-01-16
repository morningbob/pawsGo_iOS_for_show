//
//  DatabaseManager.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-16.
//

import Foundation
import SwiftUI
import CoreData

// we fetch in this manager, I treat it as a view model
// to persist the user object, and later the dog objects and message objects
class DatabaseManager : ObservableObject {
    
    //@FetchRequest(sortDescriptors: []) var usersCore : FetchedResults<UserCore>
    @Published var currentUserCore : FetchedResults<UserCore>?
    
    func createUserCore(moc: NSManagedObjectContext, id: String, name: String, email: String) {
        let user = UserCore(context: moc)
        user.userID = id
        user.userName = name
        user.userEmail = email
        user.dogs = [:]
        user.lostDogs = [:]
        user.messagesReceived = [:]
        user.messagesSent = [:]
    }
    
    func fetchUser(id: String) -> FetchedResults<UserCore> {
        let predicate = NSPredicate(format: "userID == %@", id)
        
        @FetchRequest(
            sortDescriptors: [SortDescriptor(\.userID)],
            predicate: predicate
        ) var userCoreResult: FetchedResults<UserCore>
        
        //if userCore.first != nil {
        //    print("got back user in database")
        //}
        
        //return userCore.first
        return userCoreResult
    }
    
    /*
    var moc : NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.moc = viewContext
    }
    */
    
}

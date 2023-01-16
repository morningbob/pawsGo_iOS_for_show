//
//  UserViewModel.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-16.
//

import Foundation
import CoreData
/*
 class UserViewModel : NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
 
 //let userController : NSFetchedResultsController<UserCore>
 
 //init(context: NSManagedObjectContext) {
 /*
  let request = NSFetchRequest<UserCore>(entityName: "UserCore")
  request.sortDescriptors = [
  NSSortDescriptor(keyPath: \UserCore.userID, ascending: true)
  ]
  
  userController = NSFetchedResultsController(
  fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil
  )
  
  super.init()
  userController.delegate = self
  
  do {
  try userController.performFetch()
  } catch {
  print("error initializing fetch results controller \(error)")
  }
  */
 //}
 
 // here, we will know if the user is updated and therefore update the interface
 func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
 
 }
 
 func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
 
 }
 }
 */

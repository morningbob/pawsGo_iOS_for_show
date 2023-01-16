//
//  FilteredPetsList.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-30.
//

import SwiftUI
import CoreData

struct FilteredPetsList: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var isLandscape : Bool { verticalSizeClass == .compact }
    
    @FetchRequest var petsCore: FetchedResults<DogCore>
    @EnvironmentObject var firebaseClient : FirebaseClient
    @FetchRequest(sortDescriptors: [SortDescriptor(\.dogID)],
                    predicate: NSPredicate(format: "NOT dogID == ''")) var foundPets :FetchedResults<DogCore>
    
    init(filter: String, lostOrFound: Bool) {
        
        let reportTypePredicate = NSPredicate(format: "isLost == %@", NSNumber(value: lostOrFound))
        var animalTypePredicate = NSPredicate(format: "NOT dogID == ''")
        
        if filter == "Dog" || filter == "Cat" || filter == "Bird" {
            animalTypePredicate = NSPredicate(format: "animalType == %@", filter)
        } else if filter == "Other" {
            animalTypePredicate = NSPredicate(format: "NOT animalType IN %@", ["Dog", "Cat", "Bird"])
        } else {
            // leave predicate empty
            // that implies, show everything
            // the case of All type
        }
        
        _petsCore = FetchRequest<DogCore>(sortDescriptors: [NSSortDescriptor(key: "dateLastSeen", ascending: false)], predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [reportTypePredicate, animalTypePredicate]))
    }
    
    var body: some View {
        
        List(self.petsCore, id: \.dogID) { pet in
            NavigationLink {
                PetDetail(pet: pet)
                    .environmentObject(firebaseClient)
            } label: {
                PetRow(pet: pet)
            }
            .listRowBackground(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND)
            .border(.blue)
            .padding([.leading, .trailing], self.isLandscape ? 50 : 0)
        }
        .background(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND).ignoresSafeArea()
        .onAppear() {
            print("petsCore size \(petsCore.count)")
        }
    }
}

struct FilteredPetsList_Previews: PreviewProvider {
    
    static var filter = ""
    
    static var previews: some View {
        FilteredPetsList(filter: filter, lostOrFound: true)
    }
}

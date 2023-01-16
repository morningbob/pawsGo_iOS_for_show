//
//  ChooseReport.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2023-01-02.
//

import SwiftUI
import CoreData

// instead of getting the lost dogs list from the user object from firebase
// I retrieve the dogs whose owner email is the user
// are the user's dogs reports.
struct ChooseReport: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var isLandscape : Bool { verticalSizeClass == .compact }
     
    @EnvironmentObject var firebaseClient : FirebaseClient

    //@State var dogsCore : [DogCore]
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "NOT ownerEmail == %@", "xx")) var ppCore : FetchedResults<DogCore>
    
    init(email: String) {
        _ppCore = fetchPetsList(email: email)
    }
    
    var body: some View {
            VStack {
                List(ppCore, id:\.dogID) { pet in
                    NavigationLink {
                        EditReport(pet: pet)
                            .environmentObject(firebaseClient)
                    } label: {
                        PetRow(pet: pet)
                    }
                    .listRowBackground(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND)
                    .border(.blue)
                    .padding([.leading, .trailing], self.isLandscape ? 50 : 0)
                }
                .background(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND)
            }
            .padding(.top, 60)
            
        .navigationBarTitle("Pets Reports")
        .background(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND)
        .ignoresSafeArea()
        .onAppear {
            UITableView.appearance().backgroundColor = UIColor(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND)
        }
    }
    
    private func fetchPetsList(email: String) -> FetchRequest<DogCore> {
        print("ownerEmail \(email)")
        let fetchRequest = NSFetchRequest<DogCore>(entityName: "DogCore")
        
        let sortDescriptor = NSSortDescriptor(key: "dogName", ascending: true)
        
        let predicate = NSPredicate(format: "ownerEmail == %@", email)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        return FetchRequest<DogCore>(fetchRequest: fetchRequest)
    }
}


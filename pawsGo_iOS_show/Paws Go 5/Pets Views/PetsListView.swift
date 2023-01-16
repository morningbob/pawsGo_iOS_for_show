//
//  PetsListView.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-18.
//

import SwiftUI
import GoogleMaps
import CoreData

// here we allow the user to choose lost or found pets too
struct PetsListView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var isLandscape : Bool { verticalSizeClass == .compact }
    
    @EnvironmentObject var firebaseClient : FirebaseClient
    @Environment(\.managedObjectContext) var moc
    
    @State var lostOrFound : Bool
    @State var animalType = "All"
    @State var reportChoice = ["Lost Reports", "Found Reports"]
    @State var reportChosen = "Lost Reports"
    
    var body: some View {
        VStack {
            if !isLandscape {
                VStack {
                    HStack {
                        Picker("Lost", selection: self.$reportChosen) {
                            ForEach(self.reportChoice, id:\.self) {
                                Text($0)
                            }
                        }
                        .padding(.top, 90)
                        .accentColor(colorScheme == .dark ? Color.yellow : Color.blue)
                    }
                    
                    HStack {
                        Button("Dogs") {
                            self.animalType = "Dog"
                        }
                        .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                        .font(.system(size: CONTENT_FONT_SIZE))
                        Button("Cats") {
                            self.animalType = "Cat"
                        }
                        .padding(.leading, 15)
                        .font(.system(size: CONTENT_FONT_SIZE))
                        .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                        Button("Birds") {
                            self.animalType = "Bird"
                        }
                        .padding(.leading, 15)
                        .font(.system(size: CONTENT_FONT_SIZE))
                        .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                        Button("Others") {
                            self.animalType = "Other"
                        }
                        .padding(.leading, 15)
                        .font(.system(size: CONTENT_FONT_SIZE))
                        .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                        Button("All") {
                            self.animalType = "All"
                        }
                        .padding(.leading, 15)
                        .font(.system(size: CONTENT_FONT_SIZE))
                        .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                    }
                    FilteredPetsList(filter: self.animalType, lostOrFound: self.lostOrFound)
                }
            } else {
                // landscape
                VStack {
                    HStack {
                        Picker("Lost", selection: self.$reportChosen) {
                            ForEach(self.reportChoice, id:\.self) {
                                Text($0)
                            }
                        }
                        .accentColor(colorScheme == .dark ? Color.yellow : Color.blue)
                    }
                    .padding(.top, 40)
                    
                    HStack {
                        Button("Dogs") {
                            self.animalType = "Dog"
                        }
                        .font(.system(size: CONTENT_FONT_SIZE))
                        .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                        Button("Cats") {
                            self.animalType = "Cat"
                        }
                        .padding(.leading, 50)
                        .font(.system(size: CONTENT_FONT_SIZE))
                        .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                        Button("Birds") {
                            self.animalType = "Bird"
                        }
                        .padding(.leading, 50)
                        .font(.system(size: CONTENT_FONT_SIZE))
                        .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                        Button("Others") {
                            self.animalType = "Other"
                        }
                        .padding(.leading, 50)
                        .font(.system(size: CONTENT_FONT_SIZE))
                        .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                        Button("All") {
                            self.animalType = "All"
                        }
                        .padding(.leading, 50)
                        .font(.system(size: CONTENT_FONT_SIZE))
                        .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                    }
                    //.padding(.top, 10)
                    FilteredPetsList(filter: self.animalType, lostOrFound: self.lostOrFound)
                }
            }// end of if clause
        } // end of VStack
        .navigationBarTitle("Pets List")
        // here, this line gives the background color
        .background(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND).ignoresSafeArea()
        .onAppear {
            UITableView.appearance().backgroundColor = UIColor(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND)
        }
        .onChange(of: self.reportChosen) { report in
            if report == "Lost Reports" {
                self.lostOrFound = true
                print("report set to Lost")
            } else {
                self.lostOrFound = false
                print("report set to Found")
            }
        }
    }
    
}

struct PetsListView_Previews: PreviewProvider {
    static var type = "All"
    
    static var previews: some View {
        PetsListView(lostOrFound: true)
    }
}


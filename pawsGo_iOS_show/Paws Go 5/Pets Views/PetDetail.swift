//
//  PetDetail.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-18.
//

import SwiftUI
import GoogleMaps
import CoreLocation
import Photos

struct PetDetail: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var isLandscape : Bool { verticalSizeClass == .compact }
    
    @EnvironmentObject var firebaseClient : FirebaseClient
    @State var pet : DogCore
    @State  var userLocation : LocationStruct = LocationStruct(name: "Here", coordinate: CLLocationCoordinate2D(latitude: 43.8828, longitude: 79.4403))
    @State private var shouldNavigateShowLocation = false
    @State  var latGot: Double?
    @State  var lngGot: Double?
    @State  var myLocationTapped = false
    @State  var shouldUpdateCamera = true
    @State  var marker : GMSMarker?
    @State var shouldReportLocation = 0
    @State var shouldNavigateSendMessage = false
    
    var body: some View {
        ScrollView {
            if !isLandscape {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        AsyncImage(url: URL(string: (pet.dogImages?.first?.value) ?? ""),
                                   content: { image in
                            image
                                .resizable()
                                .frame(width: 200, height: 200)
                                .padding(.top, 50)
                                .scaledToFit()
                        }, placeholder: { Image(uiImage: UIImage(named: "placeholder.png")!)
                                .resizable()
                                .frame(width: 150, height: 150)
                                .padding(.top, 50)
                                .scaledToFit()
                        })
                        Spacer()
                    }
                    .padding(.top, 60)
                    
                    VStack {
                        
                        if pet.dogName != nil {
                            Text("Name:  " + pet.dogName!)
                                .padding(.top, 50)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        }
                            
                        if pet.animalType != nil && pet.animalType != "" {
                            Text("Type:  " + pet.animalType!)
                                .padding(.top, 5)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        }
                        
                        Text("Owner Name:  " + pet.ownerName!)
                            .padding(.top, 5)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        
                        if pet.dogBreed != "" {
                            Text("Breed:  " + pet.dogBreed!)
                                .padding(.top, 5)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        }

                        
                        if pet.dogGender == 1  {
                            //if pet.dogGender == true {
                            Text("Gender:  Male")
                                .padding(.top, 5)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        } else if pet.dogGender == 2 {
                            Text("Gender:  Female")
                                .padding(.top, 5)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        }
                        
                        if pet.dogAge != 0 {
                            Text("Age:  " + String(pet.dogAge))
                                .padding(.top, 5)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        }
                        //}
                    }
                }
                
                VStack {
                    Text("Lost Location:  " + pet.placeLastSeen!)
                        .padding(.top, 5)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    
                    Button("Show Location in Map")
                    {
                        
                        if pet.lat != nil && pet.lat != 0 {
                            self.userLocation = LocationStruct(name: "Lost Location", coordinate: CLLocationCoordinate2D(latitude: pet.lat, longitude: pet.lng))
                            self.shouldNavigateShowLocation = true
                        } else {
                            // alert user no location available
                            self.locationNotSetAlert()
                        }
                    }
                    .padding(.top, 5)
                    .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                    
                    Text("Date Last Seen:  " + pet.dateLastSeen!)
                        .padding(.top, 5)
                        .font(.system(size: CONTENT_FONT_SIZE))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    
                    if pet.hour != nil && pet.minute != nil {
                        Text("Time Last Seen:  " + String(pet.hour) + " : " + String(pet.minute))
                            .padding(.top, 5)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                    
                    if pet.notes != nil {
                        Text("Notes:  " + pet.notes!)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                    
                    Button("Send Message") {
                        self.shouldNavigateSendMessage = true
                    }
                    .padding(.top, 20)
                    .font(.system(size: CONTENT_FONT_SIZE))
                    .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                    
                    Spacer()
                }
            } else {
                HStack {
                    Spacer()
                    VStack {
                        AsyncImage(url: URL(string: (pet.dogImages?.first?.value) ?? ""),
                                   content: { image in
                            image
                                .resizable()
                                .frame(width: 200, height: 200)
                                .padding(.top, 50)
                                .scaledToFit()
                        }, placeholder: { Image(uiImage: UIImage(named: "placeholder.png")!)
                                .resizable()
                                .frame(width: 150, height: 150)
                                .padding(.top, 50)
                                .scaledToFit()
                        })
                        if pet.dogName != nil {
                            Text("Name:  " + pet.dogName!)
                                .padding(.top, 20)
                                .font(.system(size: TITLE_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        }
                        if pet.animalType != nil && pet.animalType != "" {
                            Text("Type:  " + pet.animalType!)
                                .padding(.top, 2)
                                .font(.system(size: TITLE_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        }
                        
                    } // end of section 1
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(maxWidth: 200)
                    .padding(.leading, 60)
                    VStack {
                        VStack {
                            Text("Owner Name:  " + pet.ownerName!)
                                .padding(.top, 30)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            
                            if pet.dogBreed != "" {
                                Text("Breed:  " + pet.dogBreed!)
                                    .padding(.top, 5)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            }
                            
                            if pet.dogGender == 1  {
                                Text("Gender:  Male")
                                    .padding(.top, 5)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            } else if pet.dogGender == 2 {
                                Text("Gender:  Female")
                                    .padding(.top, 5)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            }
                            
                            if pet.dogAge != 0 {
                                Text("Age:  " + String(pet.dogAge))
                                    .padding(.top, 5)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            }
                        }
                        VStack {
                            Text("Lost Location:  " + pet.placeLastSeen!)
                                .padding(.top, 5)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            
                            Button("Show Location in Map")
                            {
                                
                                if pet.lat != nil && pet.lat != 0 {
                                    self.userLocation = LocationStruct(name: "Lost Location", coordinate: CLLocationCoordinate2D(latitude: pet.lat, longitude: pet.lng))
                                    self.shouldNavigateShowLocation = true
                                } else {
                                    // alert user no location available
                                    self.locationNotSetAlert()
                                }
                            }
                            .padding(.top, 5)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                            
                            Text("Date Last Seen:  " + pet.dateLastSeen!)
                                .padding(.top, 5)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            
                            if pet.hour != nil && pet.minute != nil {
                                Text("Time Last Seen:  " + String(pet.hour) + " : " + String(pet.minute))
                                    .padding(.top, 5)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            }
                            
                            if pet.notes != nil {
                                Text("Notes:  " + pet.notes!)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            }

                            Button("Send Message") {
                                self.shouldNavigateSendMessage = true
                            }
                            .padding(.top, 20)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                        }
                    } // end of section 2
                    .padding(.leading, 80)
                    Spacer()
                } // end of HStack
            }// end of if clause
             
        } // end of ScrollView
        .background(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND).ignoresSafeArea()
        .navigationDestination(isPresented: self.$shouldNavigateShowLocation) {
            LostLocationView(userLocationStruct: LocationStruct(name: "Lost Location", coordinate: CLLocationCoordinate2D(latitude: pet.lat, longitude: pet.lng)), latitudeGot: self.$latGot, longitudeGot: self.$lngGot, marker: self.$marker, shouldReportLocation: self.$shouldReportLocation, reportOrShow: false)
        }
        .navigationDestination(isPresented: self.$shouldNavigateSendMessage) {
            SendMessageView(originalPet: self.pet, userName: self.pet.ownerName!)
                .environmentObject(firebaseClient)
        }
        .onChange(of: self.latGot) { lat in
            print("detail, latGot: \(lat)")
        }
    }
    
    private func locationNotSetAlert() {
            
        guard let window = UIApplication.shared.keyWindow else {
            return }
        
        let locationAlert = UIAlertController(
            title: "Lost Location",
            message: "The owner didn't set the location on the map.", preferredStyle: .alert)
        
        locationAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            //print("confirmed")
        })
        
        window.rootViewController?.present(locationAlert, animated: true)
    }
}

struct PetDetail_Previews: PreviewProvider {
    //static var pet = DogStructFirebase(dogName: "AA", placeLastSeen: "xx", dateLastSeen: "yy", ownerID: "aa", ownerName: "aa", ownerEmail: "aa")
    static var pet1 : DogCore = DogCore()
    static var location : LocationStruct = LocationStruct(name: "xx", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    
    static var previews: some View {
        PetDetail(pet: pet1, userLocation: location)
    }
}

/*
Text(pet.dogID!)
    .padding(.top, 20)
if pet.dogName != nil {
    Text(pet.dogName!)
        .padding(.top, 20)
}
*/

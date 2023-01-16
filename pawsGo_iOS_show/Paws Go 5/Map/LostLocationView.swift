//
//  LostLocationView.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-08.
//

import SwiftUI
import GoogleMaps
import CoreLocationUI

struct LostLocationView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var isLandscape : Bool { verticalSizeClass == .compact }
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var locationManager = LocationManager()
    @State var userLocationStruct : LocationStruct// = LocationStruct(name: "Here", coordinate: CLLocationCoordinate2D(latitude: 43.8828, longitude: 79.4403))
    @Binding var latitudeGot : Double?
    @Binding var longitudeGot : Double?
    @Binding var marker : GMSMarker? //= GMSMarker(position: CLLocationCoordinate2D(latitude: 43.8828, longitude: 79.4403))
    @State var address = ""
    @State var pickedLocation : LocationStruct = LocationStruct(name: "Picked", coordinate: CLLocationCoordinate2D(latitude: 43.8828, longitude: 79.4403))
    @State var shouldPresentPlacePicker = false
    @State var shouldUpdateCamera = true
    @State var myLocationTapped = false
    @Binding var shouldReportLocation : Int
    @State var shouldShowCurrentLocation = 0
    // this variable is used to store the location received from location manager
    // I need to store it here.  So, whenever the user request current location,
    // I can present it immediately instead of waiting for the location manager to
    // retrieve it again.  to achieve faster response time.
    @State var userCurrentLocation : LocationStruct?
    // this variable is use to distinguish between what components to show depends on
    // which view is calling
    // for reporting pets, reportOrShow = true
    // for showing location, reportOrShow = false
    // the view change layout to adapt to the caller
    @State var reportOrShow = true

    var body: some View {
        VStack {
            if !isLandscape {
                VStack {
                    GeometryReader { geometry in
                        ZStack(alignment: .top) {
                            // Map
                            GoogleMapsView(userLocation: $userLocationStruct, latitudeGot: $latitudeGot, longitudeGot: $longitudeGot, myLocationTapped: $myLocationTapped, marker: $marker, shouldUpdateCamera: $shouldUpdateCamera)
                        }
                    }
                }
                VStack {
                    HStack {
                        if self.reportOrShow {
                            Button("Report Location") {
                                // when the user clicked report location,
                                // we know for sure he made a decision on the location
                                // we dismiss the view, and send a request to Google
                                // Geocoding API to get the location's address
                                // check marker before processing
                                if marker != nil {
                                    shouldReportLocation = 1
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                            .padding(.top, 20)
                            .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                            .font(.system(size: 18))
                            
                            Button("Search a place") {
                                shouldPresentPlacePicker = true
                            }
                            .padding(.top, 20)
                            .padding(.leading, 30)
                            .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                            .font(.system(size: 18))
                        }
                    }
                   
                    if self.reportOrShow {
                        Button("Current Location") {
                            self.shouldShowCurrentLocation = 1
                            locationManager.requestLocation()
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 50)
                        .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                        .font(.system(size: 18))
                    }
                   
                }
            } else {
                // landscape
                HStack {
                    VStack {
                        GeometryReader { geometry in
                            ZStack(alignment: .top) {
                                // Map
                                GoogleMapsView(userLocation: $userLocationStruct, latitudeGot: $latitudeGot, longitudeGot: $longitudeGot, myLocationTapped: $myLocationTapped, marker: $marker,
                                               shouldUpdateCamera: $shouldUpdateCamera)
                                //.edgesIgnoringSafeArea(.all)
                            }
                        }
                    } // session 1
                    VStack {
                        //HStack {
                            if self.reportOrShow {
                                Button("Report Location") {
                                    // when the user clicked report location,
                                    // we know for sure he made a decision on the location
                                    // we dismiss the view, and send a request to Google
                                    // Geocoding API to get the location's address
                                    // check marker before processing
                                    if marker != nil {
                                        shouldReportLocation = 1
                                        self.presentationMode.wrappedValue.dismiss()
                                    }
                                }
                                .padding(.top, 20)
                                .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                                .font(.system(size: 18))
                                
                                Button("Search a place") {
                                    shouldPresentPlacePicker = true
                                }
                                .padding(.top, 20)
                                .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                                .font(.system(size: 18))
                                //.padding(.leading, 30)
                                Button("Current Location") {
                                    self.shouldShowCurrentLocation = 1
                                    locationManager.requestLocation()
                                }
                                .padding(.top, 20)
                                .padding(.bottom, 50)
                                .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                                .font(.system(size: 18))
                            }                       
                        //Text("Location: \(userLocationStruct.coordinate.latitude), \(userLocationStruct.coordinate.longitude)")
                         //   .padding(.top, 20)
                        
                    } // session 2
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(maxWidth: 200)
                    
                } // end of HStack
            }// end of if clause
            
        } // end of VStack
        // show autocomplete search page
        .sheet(isPresented: $shouldPresentPlacePicker, content: {
            PlacePicker(address: $address, pickedLocation: $pickedLocation)
        })
        .navigationBarTitle(self.reportOrShow ? "Choose Location" : "Lost Location")
        // when user click current location
        .onReceive(locationManager.$locationStruct) { location in
            print("received current location from location manager")
            if location != nil {
                print("updated user current location")
                // whenever location manager gives a location
                // we'll change view to that location
                shouldUpdateCamera = true
                // reset
                //self.shouldShowCurrentLocation = false
                self.userCurrentLocation = location!
            }
        }
        .onChange(of: self.latitudeGot, perform: { lat in
            print("got back lat lng clicked: \(lat), \(self.longitudeGot)")
            // we shouldn't update camera in this case
            guard let latResult = lat else {
                return
            }
            userLocationStruct = LocationStruct(name:"Clicked Location", coordinate: CLLocationCoordinate2D(latitude: lat!, longitude: longitudeGot!))
        })
        // navigate to picked place
        .onChange(of: pickedLocation, perform: { picked in
            shouldUpdateCamera = true
            userLocationStruct = picked
        })
        // it takes too long time
        
        .onChange(of: userCurrentLocation) { currentLocation in
            if self.shouldShowCurrentLocation == 1 && currentLocation != nil {
                self.userLocationStruct = currentLocation!
                self.shouldShowCurrentLocation = 0
            }
        }
         /*
        .onChange(of: self.shouldShowCurrentLocation) { show in
            if show == 1 && self.userCurrentLocation != nil {
                self.userLocationStruct = self.userCurrentLocation!
                self.shouldShowCurrentLocation = 0
            }
        }
          */
        .background(colorScheme == .dark ? Color.white : COLOR_LIGHT_MODE_BACKGROUND)
    }
    
}

struct LostLocationView_Previews: PreviewProvider {
    @State static var lat : Double? = 10.0
    @State static var log : Double? = 10.0
    @State static var m : GMSMarker? = GMSMarker(position: CLLocationCoordinate2D(latitude: 43.8828, longitude: 79.4403))
    @State static var should = 0
    @State static var userLocationStruct : LocationStruct = LocationStruct(name: "Here", coordinate: CLLocationCoordinate2D(latitude: 43.8828, longitude: 79.4403))
    
    static var previews: some View {
        LostLocationView(userLocationStruct: userLocationStruct, latitudeGot: $lat, longitudeGot: $log, marker: $m, shouldReportLocation: $should)
    }
}


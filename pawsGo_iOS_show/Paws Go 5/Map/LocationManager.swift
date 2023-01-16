//
//  LocationManager.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-06.
//

import CoreLocation
import Foundation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, MKLocalSearchCompleterDelegate {
    let manager = CLLocationManager()

    @Published var location: CLLocationCoordinate2D?
    @Published var locationStruct : LocationStruct?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.requestWhenInUseAuthorization()
        //manager.startUpdatingLocation()
    }

    func requestLocation() {
        print("request location called")
        manager.requestLocation()
    }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.first != nil {
            print("setting location in location manager")
            print("lat \(locations.first!.coordinate.latitude) lng \(locations.first!.coordinate.longitude)")
            locationStruct = LocationStruct(name: "Current Location", coordinate: locations.first!.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("There is error accessing user's location: \(error.localizedDescription)")
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location manager, change authorization status \(status)")
    }
}
/*
 extension LocationManager:  MKLocalSearchCompleterDelegate {
 
 func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
 //guard let location = location.last
 }
 
 
 func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
 
 }
 
 
 }
 */
/*
func searchPlace(text: String) {
    let searchRequest = MKLocalSearch.Request()
    searchRequest.naturalLanguageQuery = text
    
    let search = MKLocalSearch(request: searchRequest)
    search.start { response, error in
        guard let response = response else {
            print("error: \(error?.localizedDescription)")
            return
        }
        
        self.searchResults = response.mapItems.map({ mapItem in
            PlaceStruct(mapItem: mapItem)
        })
    }
}
 */

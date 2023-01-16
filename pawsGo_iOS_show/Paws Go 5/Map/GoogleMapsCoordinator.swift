//
//  GoogleMapsCoordinator.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-08.
//

import GoogleMaps
import SwiftUI

class GoogleMapsCoordinator : NSObject, GMSMapViewDelegate, ObservableObject {
    
    @Binding var latitude : Double?
    @Binding var longitude : Double?
    @Binding var myLocationTapped : Bool
    
    let owner: GoogleMapsView       // access to owner view members,

    init(owner: GoogleMapsView, latitude: Binding<Double?>, longitude: Binding<Double?>,
         myLocationTapped: Binding<Bool>) {
        self.owner = owner
        _latitude = latitude
        _longitude = longitude
        _myLocationTapped = myLocationTapped
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        print("tapped my location")
        myLocationTapped = true
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("tapped map \(coordinate.latitude), \(coordinate.longitude)")
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }
}

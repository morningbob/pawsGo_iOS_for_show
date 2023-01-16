//
//  GoogleMapsView.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-08.
//
import UIKit
import SwiftUI
import GoogleMaps


struct GoogleMapsView: UIViewRepresentable {
    
    @Binding var userLocation : LocationStruct
    @Binding var latitudeGot : Double?
    @Binding var longitudeGot : Double?
    @Binding var myLocationTapped : Bool
    @Binding var marker : GMSMarker?
    @Binding var shouldUpdateCamera : Bool
     
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.london
        let mapView = GMSMapView(frame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        //mapView.settings.myLocationButton = true
        mapView.setMinZoom(10, maxZoom: 20)
        mapView.delegate = context.coordinator
        return mapView
    }
     
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        
        DispatchQueue.main.async {
            if self.shouldUpdateCamera {
                print("google map view: user location \(userLocation.coordinate.latitude) \(userLocation.coordinate.longitude)")
                mapView.camera = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: 17)
                self.shouldUpdateCamera = false
            }
                
            marker?.map = nil

            marker = GMSMarker(position: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude))
           
            marker!.title = userLocation.name
            marker!.map = mapView
        }
    }
    
    func makeCoordinator() -> GoogleMapsCoordinator {
        return GoogleMapsCoordinator(owner: self, latitude: $latitudeGot, longitude: $longitudeGot, myLocationTapped: $myLocationTapped)
    }
    

 }

extension GMSCameraPosition  {
    static var london = GMSCameraPosition.camera(withLatitude: 43.8828, longitude: 79.4403, zoom: 17)
 }

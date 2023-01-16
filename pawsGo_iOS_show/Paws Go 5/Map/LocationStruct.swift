//
//  LocationStruct.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-06.
//

import MapKit

struct LocationStruct: Identifiable, Equatable {
    static func == (lhs: LocationStruct, rhs: LocationStruct) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

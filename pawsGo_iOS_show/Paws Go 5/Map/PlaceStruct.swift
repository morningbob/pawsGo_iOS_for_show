//
//  PlaceStruct.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-07.
//
import Foundation
import MapKit

struct PlaceStruct : Identifiable, Hashable{
    let id = UUID()
    var mapItem : MKMapItem
}

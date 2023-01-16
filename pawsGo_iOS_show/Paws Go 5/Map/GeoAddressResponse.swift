//
//  GeoAddressResponse.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-09.
//

struct GeoAddressResponse : Codable {
    
    var results : [AddressResponseBody]
    var status : String
}

struct AddressResponseBody : Codable {
    //var address_components : [AddressComponent]
    var formatted_address : String
    //var geometry : Geometry
    //var place_id : String
    //var plus_code : Plus_Code
    //var types : [String]
}

struct AddressComponent : Codable {
    var long_name : String
    var short_name : String
    var types : [String]
}

struct Geometry : Codable {
    var location : LatLng
    var location_type : String
    var viewport : Viewport
}

struct Plus_Code : Codable {
    var compound_code : String
    var global_code : String
}

struct Viewport : Codable {
    var northeast : LatLng
    var southwest : LatLng
}

struct LatLng : Codable {
    var lat : Double
    var lng : Double
}



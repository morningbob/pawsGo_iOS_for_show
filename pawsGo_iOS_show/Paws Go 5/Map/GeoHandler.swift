//
//  LocationViewModel.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-09.
//

import Foundation

class GeoHandler  {
    
    
    class func taskForAddressRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            
            do {
                //print("data: \(data)")
                let parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                //print("parsedData \(parsedData)")
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    //let errorResponse = try decoder.decode(TMDBResponse.self, from: data) as Error
                    let errorResponse = try decoder.decode(ResponseType.self, from: data)
                    let error = errorResponse as! any Error
                    
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }.resume()
        return task
    }
    
    class func requestAddress(lat: Double, lng: Double, completion: @escaping (GeoAddressResponse?, Error?) -> Void) {
        let GEO_BASE_URL = "https://maps.googleapis.com/maps/api/geocode/json?"
        let GEO_API_KEY = "AIzaSyBYUeTxZ-WGN_cj-A3E09cUI2WT3UMOMe4"
        //let GEO_API_KEY = "AIzaSyAZiadazIsBMbJnajmlUd9GhiwWBRyhV04"
        
        let url = URL(string: "\(GEO_BASE_URL)latlng=\(lat),\(lng)&key=\(GEO_API_KEY)")
        
        if url != nil {
            taskForAddressRequest(url: url!, responseType: GeoAddressResponse.self, completion: { response, error in
                
                if let response = response {
                    // print the address
                    completion(response, nil)
                } else {
                    print("error getting address: \(error?.localizedDescription)")
                }
            })
        }
    }
    /*
    func request(lat: Double, lng: Double) {
        
        let url = URL(string: "\(GEO_BASE_URL)latlng=\(lat),\(lng)&key=\(GEO_API_KEY)")
        let data = try! Data(contentsOf: url!)
        let json = convertToJSON(data: data)
        if json != nil {
            
        }
        
    }
    
    func convertToJSON(data: Data) -> String? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! String//[String: Any]
                return json
        } catch {
            print("error converting data to JSON")
        }
        return nil
    }
     func requestPlaceAddress(lat: Double, lng: Double) {
         let url = URL(string: "\(GEO_BASE_URL)latlng=\(lat),\(lng)&key=\(GEO_API_KEY)")
         let data = try! Data(contentsOf: url!)
         let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
         if let result = json["results"] as? [[String: Any]] {
             if let address = result[0]["formatted_address"] as? String {
                 print("got location address \(address)")
             }
         }
     }
     */
}

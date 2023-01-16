//
//  ContentView.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-06.
//

import SwiftUI
import CoreData
import FirebaseCore
import GoogleMaps
import MapKit
import GooglePlaces

struct ContentView: View {
    
    @StateObject var firebaseClient = FirebaseClient()
    @Environment(\.managedObjectContext) var moc
    @StateObject var databaseManager = DatabaseManager()
    
    // register app delegate for Firebase setup
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @State private var shouldNavigateMain = false
    @State private var shouldNavigateLogin = false
    @State private var email = ""
    @State private var pass = ""
    @State private var locationOfInterest : LocationStruct? = LocationStruct(name: "TTT", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275))
    @State private var regionOfInterest : MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        GMSServices.provideAPIKey(GOOGLE_API_KEY)
        GMSPlacesClient.provideAPIKey(GOOGLE_API_KEY)
    }
    
    var body: some View {
       
            NavigationStack {
                VStack {
                    LoginView()
                        .environmentObject(firebaseClient)
                        .environmentObject(databaseManager)
                    
                } // end of VStack
                 
            } // end of Navigation Stack
            .onReceive(firebaseClient.$authState, perform: { state in
                
                if state == AuthState.LOGGED_IN {
                    print("should Navigate to Main before: \(shouldNavigateMain)")
                    shouldNavigateMain = true
                    print("app state logged in detected, trigger main")
                    print("should Navigate to Main: \(shouldNavigateMain)")
                    
                    
                } else if state == AuthState.LOGGED_OUT {
                    shouldNavigateLogin = true
                    print("app state, logged out detected, trigger login")
                    print("should Navigate to Login: \(shouldNavigateLogin)")
                }
            })
            .onAppear() {
                if FirebaseApp.app() == nil {
                    FirebaseApp.configure()
                }
                firebaseClient.observeUserState()
            }
            .background(Color(red: 0.7725, green: 0.9412, blue: 0.8157))
        
        //} // end of HStack
        
        
    } // end of body view
    
    private func observeAuthState() {
        firebaseClient.observeUserState()
    }
    
    private func prepareNavigation() {
        if firebaseClient.authState == AuthState.LOGGED_IN {
            shouldNavigateMain = true
        } else if firebaseClient.authState == AuthState.LOGGED_OUT {
            shouldNavigateLogin = true
        }
    }
}
/*
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()

    return true
  }
}
*/
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {


    return true
  }
}

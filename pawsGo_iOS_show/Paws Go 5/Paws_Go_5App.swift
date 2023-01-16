//
//  Paws_Go_5App.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-06.
//

import SwiftUI

@main
struct Paws_Go_5App: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    //@StateObject private var dataController = DataController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        // when the app moves to the background
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}

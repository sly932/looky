//
//  lookyApp.swift
//  looky
//
//  Created by 沈力源 on 2025/7/28.
//

import SwiftUI
import CoreData

@main
struct lookyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

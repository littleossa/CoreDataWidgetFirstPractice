//
//  CoreDataWidgetFirstPracticeApp.swift
//  CoreDataWidgetFirstPractice
//
//

import SwiftUI

@main
struct CoreDataWidgetFirstPracticeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

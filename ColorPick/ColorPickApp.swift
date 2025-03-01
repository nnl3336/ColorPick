//
//  ColorPickApp.swift
//  ColorPick
//
//  Created by Yuki Sasaki on 2025/03/01.
//

import SwiftUI

@main
struct ColorPickApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(viewContext: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

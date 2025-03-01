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
    private var ep_slideview: ColorSelectionViewModel {
        ColorSelectionViewModel(viewContext: persistenceController.container.viewContext)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(ep_slideview)
        }
    }
}

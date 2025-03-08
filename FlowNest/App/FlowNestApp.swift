//
//  FlowNestApp.swift
//  FlowNest
//
//  Created by Vishnu Hari on 3/4/25.
//

import SwiftUI

@main
struct FlowNestApp: App {
    @StateObject private var themeManager = ThemeManager()
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(themeManager)
        }
    }
}





//
//  ContentView.swift
//  FlowNest
//
//  Created by Vishnu Hari on 3/4/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        TaskListView()
            .environmentObject(themeManager)
    }
}

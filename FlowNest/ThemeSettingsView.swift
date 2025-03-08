//
//  ThemeSettingsView.swift
//  FlowNest
//
//  Created by Vishnu Hari on 3/5/25.
//

import Foundation
import SwiftUI

struct ThemeSettingsView: View {
    @ObservedObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    // Initialize with ThemeManager instance
    init(themeManager: ThemeManager) {
        self.themeManager = themeManager
    }
    
    private let accentColorOptions: [Color] = [
        .blue, .purple, .pink, .red, .orange,
        .yellow, .green, .mint, .teal, .cyan
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $themeManager.isDarkMode)
                }
                
                Section("Accent Color") {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 44))
                    ], spacing: 8) {
                        ForEach(accentColorOptions, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: 2)
                                        .opacity(themeManager.accentColor == color ? 1 : 0)
                                )
                                .onTapGesture {
                                    themeManager.accentColor = color
                                }
                        }
                    }
                    .padding(.vertical)
                }
                
                Section {
                    Button("Reset to Defaults") {
                        themeManager.resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Theme Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

//
//  ThemeManager.swift
//  FlowNest
//
//  Created by Vishnu Hari on 3/5/25.
//

import Foundation
import SwiftUI

class ThemeManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var currentTheme: Theme
    @Published var accentColor: Color {
        didSet {
            updateThemeWithAccent(accentColor)
            saveAccentColor()
        }
    }
    @Published var isDarkMode: Bool {
        didSet {
            updateThemeMode()
            saveDarkModePreference()
        }
    }
    
    // MARK: - UserDefaults Keys
    private enum UserDefaultsKeys {
        static let accentColor = "userAccentColor"
        static let isDarkMode = "isDarkMode"
    }
    
    // MARK: - Initialization
    init() {
        // Load saved preferences
        let savedIsDarkMode = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isDarkMode)
        self.isDarkMode = savedIsDarkMode
        
        // Load saved accent color or use default
        if let colorData = UserDefaults.standard.data(forKey: UserDefaultsKeys.accentColor),
           let color = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor {
            self.accentColor = Color(uiColor: color)
        } else {
            self.accentColor = .blue
        }
        
        // Initialize with appropriate theme
        self.currentTheme = savedIsDarkMode ? .dark : .light
        updateThemeWithAccent(accentColor)
    }
    
    // MARK: - Theme Update Methods
    private func updateThemeMode() {
        var newTheme = isDarkMode ? Theme.dark : Theme.light
        newTheme.accent = accentColor
        currentTheme = newTheme
    }
    
    private func updateThemeWithAccent(_ color: Color) {
        var newTheme = currentTheme
        newTheme.accent = color
        currentTheme = newTheme
    }
    
    // MARK: - Preference Saving
    private func saveAccentColor() {
        let uiColor = UIColor(accentColor)
        if let colorData = try? NSKeyedArchiver.archivedData(
            withRootObject: uiColor,
            requiringSecureCoding: false
        ) {
            UserDefaults.standard.set(colorData, forKey: UserDefaultsKeys.accentColor)
        }
    }
    
    private func saveDarkModePreference() {
        UserDefaults.standard.set(isDarkMode, forKey: UserDefaultsKeys.isDarkMode)
    }
    
    // MARK: - Public Methods
    func resetToDefaults() {
        accentColor = .blue
        isDarkMode = false
    }
}

// MARK: - Environment Key
private struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager()
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}

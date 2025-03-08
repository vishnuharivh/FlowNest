//
//  CircularProgressView.swift
//  FlowNest
//
//  Created by Vishnu Hari on 3/5/25.
//

import Foundation
import SwiftUI

struct CircularProgressView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    let progress: Double
    let lineWidth: CGFloat
    let showPercentage: Bool
    
    @State private var animatedProgress: Double = 0
    
    init(progress: Double, lineWidth: CGFloat = 10, showPercentage: Bool = true) {
        self.progress = min(max(progress, 0), 1)
        self.lineWidth = lineWidth
        self.showPercentage = showPercentage
    }
    
    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(
                    themeManager.currentTheme.textSecondary.opacity(0.2),
                    lineWidth: lineWidth
                )
            
            // Progress Circle
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    themeManager.currentTheme.accent,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1), value: animatedProgress)
            
            // Percentage Text
            if showPercentage {
                Text("\(Int(animatedProgress * 100))%")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.currentTheme.text)
                    .accessibilityLabel("Progress")
                    .accessibilityValue("\(Int(animatedProgress * 100)) percent")
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { newValue in
            withAnimation {
                animatedProgress = newValue
            }
        }
    }
}

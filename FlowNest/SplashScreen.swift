//
//  SplashScreen.swift
//  FlowNest
//
//  Created by Vishnu Hari on 3/6/25.
//

import Foundation
import SwiftUI
struct SplashScreen: View {
    @State private var isActive = false
    @State private var flowOffset: CGFloat = -200
    @State private var nestOffset: CGFloat = 200
    @State private var opacity = 0.0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        if isActive {
            TaskListView()
                .transition(.scaleAndFade)
        } else {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Text("Flow")
                        .font(.system(size: 60))
                        .fontWeight(.black)
                        .foregroundColor(.black)
                        .offset(x: flowOffset)
                    
                    Text("Nest")
                        .font(.system(size: 60))
                        .fontWeight(.black)
                        .foregroundColor(.black)
                        .offset(x: nestOffset)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                        flowOffset = 0
                        nestOffset = 0
                        opacity = 1
                    }
                    // Subtle pulsing animation
                    withAnimation(.easeInOut(duration: 3.5).repeatForever()) {
                        scale = 1.15
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.interactiveSpring(duration: 0.7)) {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

extension AnyTransition {
    static var scaleAndFade: AnyTransition {
        .asymmetric(
            insertion: .opacity
                .combined(with: .scale(scale: 1.2))
                .animation(.easeOut(duration: 0.3)),
            removal: .opacity
                .combined(with: .scale(scale: 0.8))
                .animation(.easeIn(duration: 0.3))
        )
    }
}


// Preview
struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ThemeManager())
    }
}

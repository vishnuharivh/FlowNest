//
//  TaskRowView.swift
//  FlowNest
//
//  Created by Vishnu Hari on 3/7/25.
//

import Foundation
import SwiftUI

// MARK: - Task Row View
struct TaskRow: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var task: FlowNestTask
    
    @State private var animateCompletion = false
    
    var body: some View {
        if task.isFault || task.isDeleted { // Check if task is deleted or invalid
            EmptyView()
        } else {
            HStack() {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? themeManager.currentTheme.success : themeManager.currentTheme.textSecondary)
                    .scaleEffect(animateCompletion ? 1.2 : 1.0)
                    .animation(.spring(response: 0.2), value: animateCompletion)
                    .onTapGesture {
                        withAnimation {
                            animateCompletion = true
                            toggleCompletion()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                animateCompletion = false
                            }
                        }
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? themeManager.currentTheme.textSecondary : themeManager.currentTheme.text)
                        .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
                    
                    if let dueDate = task.dueDate as Date? { // Safely unwrap dueDate
                        Text(dueDate, style: .date)
                            .font(.caption)
                            .foregroundColor(themeManager.currentTheme.textSecondary)
                    }
                }
                
                Spacer()
                
                priorityIndicator
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.currentTheme.surface)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
            .transition(.moveAndFade)
            .accessibilityElement(children: .combine)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: task.isCompleted)
            .accessibilityLabel("\(task.title), \(task.isCompleted ? "completed" : "pending")")
            .accessibilityHint("Swipe left to delete, swipe right to toggle completion")
        }
    }
    
    private func toggleCompletion() {
        withAnimation {
            task.isCompleted.toggle()
            try? viewContext.save()
        }
    }
    
    private var priorityIndicator: some View {
        Circle()
            .fill(priorityColor)
            .frame(width: 8, height: 8)
            .accessibilityLabel("Priority: \(task.priority.rawValue)")
    }
    
    private var priorityColor: Color {
        print("Task Priority: \(task.priority.rawValue)")
        
        switch task.priority {
        case .low:
            return themeManager.currentTheme.priorityLow
        case .medium:
            return themeManager.currentTheme.priorityMedium
        case .high:
            return themeManager.currentTheme.priorityHigh
        @unknown default:
            return themeManager.currentTheme.priorityMedium
        }
    }
}


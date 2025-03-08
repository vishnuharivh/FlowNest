//
//  TaskFormView.swift
//  FlowNest
//
//  Created by Vishnu Hari on 3/5/25.
//

import Foundation
import SwiftUI

struct TaskFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    
    // For editing existing task
    var taskToEdit: FlowNestTask?
    
    @State private var title = ""
    @State private var taskDescription = ""
    @State private var dueDate = Date()
    @State private var selectedPriority = TaskPriority.medium
    @State private var showsValidationAlert = false
    
    init(taskToEdit: FlowNestTask? = nil) {
        self.taskToEdit = taskToEdit
        _title = State(initialValue: taskToEdit?.title ?? "")
        _taskDescription = State(initialValue: taskToEdit?.taskDescription ?? "")
        _dueDate = State(initialValue: taskToEdit?.dueDate ?? Date())
        _selectedPriority = State(initialValue: taskToEdit?.priority ?? .medium)
    }
    
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Task Title", text: $title)
                        .foregroundColor(themeManager.currentTheme.text)
                    
                    TextField("Description (Optional)", text: $taskDescription, axis: .vertical)
                        .foregroundColor(themeManager.currentTheme.text)
                        .lineLimit(3...6)
                }
                
                Section {
                    DatePicker("Due Date", selection: $dueDate, in: Date()...)
                        .foregroundColor(themeManager.currentTheme.text)
                    
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                }
            }
            .navigationTitle(taskToEdit == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.currentTheme.accent)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .foregroundColor(themeManager.currentTheme.accent)
                }
            }
        }
        .onAppear {
            if let task = taskToEdit {
                // Load existing task data
                title = task.title
                taskDescription = task.taskDescription ?? ""
                dueDate = task.dueDate
                selectedPriority = task.priority
            }
        }
        .alert("Invalid Input", isPresented: $showsValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter a task title")
        }
    }
    
    
    private func saveTask() {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showsValidationAlert = true
            return
        }
        let task = taskToEdit ?? FlowNestTask(context: viewContext)
        
        task.title = title
        task.taskDescription = taskDescription
        task.dueDate = dueDate
        task.priority = selectedPriority  // This should now work correctly
        
        if taskToEdit == nil {
            task.createdAt = Date()
            task.isCompleted = false
        }
        
        try? viewContext.save()
        dismiss()
    }
}

// MARK: - Previews
struct TaskFormView_Previews: PreviewProvider {
    static var previews: some View {
        TaskFormView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ThemeManager())
    }
}

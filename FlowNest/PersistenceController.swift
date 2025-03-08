//
//  PersistenceController.swift
//  FlowNest
//
//  Created by Vishnu Hari on 3/5/25.
//

import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    // For Preview purposes
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Add sample data for previews
        for i in 0..<5 {
            let newTask = FlowNestTask(context: viewContext)
            newTask.title = "Sample Task \(i + 1)"
            newTask.taskDescription = "This is a sample task description"
            newTask.createdAt = Date()
            newTask.dueDate = Date().addingTimeInterval(Double(i) * 86400) // Add i days
            newTask.isCompleted = i % 2 == 0
            newTask.priority = [.low, .medium, .high][i % 3]
            newTask.sortOrder = Int32(i)
        }
        
        try? viewContext.save()
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FlowNest") 
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

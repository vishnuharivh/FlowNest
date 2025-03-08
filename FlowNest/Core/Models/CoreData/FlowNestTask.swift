//
//  FlowNestTask.swift
//  FlowNest
//
//  Created by Vishnu Hari on 3/4/25.
//

import Foundation
import CoreData

// MARK: - Task Entity
@objc(FlowNestTask)
public class FlowNestTask: NSManagedObject {
    // Default initializer
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FlowNestTask> {
        return NSFetchRequest<FlowNestTask>(entityName: "FlowNestTask")
    }
}

// MARK: - Properties
extension FlowNestTask {
    @NSManaged public var title: String
    @NSManaged public var taskDescription: String?
    @NSManaged private var rawPriorityValue: String
    @NSManaged public var dueDate: Date
    @NSManaged public var isCompleted: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var sortOrder: Int32
}

// MARK: - Priority Enum
public enum TaskPriority: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
}

// MARK: - Priority Handling
extension FlowNestTask {
    @objc var priorityValue: String {
        get {
            willAccessValue(forKey: "priorityValue")
            let value = primitiveValue(forKey: "priorityValue") as? String ?? TaskPriority.medium.rawValue
            didAccessValue(forKey: "priorityValue")
            return value
        }
        set {
            willChangeValue(forKey: "priorityValue")
            setPrimitiveValue(newValue, forKey: "priorityValue")
            didChangeValue(forKey: "priorityValue")
        }
    }
    
    var priority: TaskPriority {
        get {
            return TaskPriority(rawValue: priorityValue) ?? .medium
        }
        set {
            priorityValue = newValue.rawValue
        }
    }
}

// MARK: - Validation
extension FlowNestTask {
    public override func validateForInsert() throws {
        try super.validateForInsert()
        try validateTitle()
    }
    
    public override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateTitle()
    }
    
    private func validateTitle() throws {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError.emptyTitle
        }
    }
}

// MARK: - Validation Error
enum ValidationError: LocalizedError {
    case emptyTitle
    
    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Task title cannot be empty"
        }
    }
}

// MARK: - Default Values
extension FlowNestTask {
    /// Configures default values for a new task
    func configureDefaults() {
        createdAt = Date()
        isCompleted = false
        priority = .medium
        sortOrder = 0
    }
}

// MARK: - Identifiable
extension FlowNestTask: Identifiable {
    public var id: NSManagedObjectID {
        objectID
    }
}

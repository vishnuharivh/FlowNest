//
//  TaskListView.swift
//  FlowNest
//
//  Created by Vishnu Hari on 3/5/25.
//

import Foundation
import SwiftUI
import CoreData

struct TaskListView: View {
    // MARK: - Environment & State
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var themeManager: ThemeManager
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FlowNestTask.createdAt, ascending: false)],
        animation: .default)

    private var tasks: FetchedResults<FlowNestTask>
    @State private var sortOption: SortOption = .date
    @State private var filterOption: FilterOption = .all
    @State private var searchText = ""
    @State private var showingTaskForm = false
    @State private var showingThemeSettings = false
    
    @State private var showingNewTaskForm = false
    @State private var showingEditTask: FlowNestTask? = nil

    
    // MARK: - Enums
    enum SortOption {
        case date, priority, alphabetical
    }
    
    enum FilterOption {
        case all, pending, completed
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.white
                    .ignoresSafeArea()
                
                if filteredTasks.isEmpty {
                    // Empty State
                    emptyStateView
                } else {
                    // Task List
                    taskListView
                }
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showingNewTaskForm = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(themeManager.currentTheme.accent)
                                .clipShape(Circle())
                                .shadow(radius: 4, x: 0, y: 2)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                toolbarItems
            }
            .searchable(text: $searchText, prompt: "Search tasks")
        }
        .sheet(isPresented: $showingNewTaskForm) {
            TaskFormView()
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(item: $showingEditTask) { task in
            TaskFormView(taskToEdit: task)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showingThemeSettings) {
            ThemeSettingsView(themeManager: themeManager)
        }
        .tint(themeManager.currentTheme.accent)
    }
    
    // MARK: - Computed Properties
    private var filteredTasks: [FlowNestTask] {
        var result = Array(tasks)
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Apply status filter
        switch filterOption {
        case .pending:
            result = result.filter { !$0.isCompleted }
        case .completed:
            result = result.filter { $0.isCompleted }
        case .all:
            break
        }
        
        // Apply sorting
        switch sortOption {
        case .date:
            result.sort { $0.createdAt > $1.createdAt }
        case .priority:
            result.sort { $0.priority.rawValue > $1.priority.rawValue }
        case .alphabetical:
            result.sort { $0.title < $1.title }
        }
        
        return result
    }
    
    // MARK: - Subviews
    private var emptyStateView: some View {
        VStack(spacing: 25) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 70))
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .symbolEffect(.pulse, options: .repeating)
            
            Text("Commader, we have no tasks!")
                .font(.title2)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .shadow(color: .gray.opacity(0.2), radius: 1, x: 0, y: 1)
            
            Text("Launch some new tasks into orbit 🚀")
                .font(.body)
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var taskListView: some View {
        List {
            ForEach(filteredTasks) { task in
                TaskRow(task: task)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showingEditTask = task
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteTask(task)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            toggleTaskCompletion(task)
                        } label: {
                            if task.isCompleted {
                                Label("Undo", systemImage: "arrow.uturn.left")
                                    .tint(.orange) // Different color for undo
                            } else {
                                Label("Complete", systemImage: "checkmark")
                                    .tint(themeManager.currentTheme.success)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: filterOption)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: sortOption)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: searchText)
            }
            
            .listStyle(PlainListStyle())
            .background(Color.clear)
            .sheet(isPresented: $showingNewTaskForm) {
                TaskFormView()
            }
            .sheet(item: $showingEditTask) { task in
                TaskFormView(taskToEdit: task)
            }
            .sheet(isPresented: $showingThemeSettings) {
                ThemeSettingsView(themeManager: themeManager)
            }
        }
    }
    
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    // Sort options
                    Picker("Sort by", selection: $sortOption) {
                        Label("Date", systemImage: "calendar").tag(SortOption.date)
                        Label("Priority", systemImage: "exclamationmark.circle").tag(SortOption.priority)
                        Label("Name", systemImage: "textformat.abc").tag(SortOption.alphabetical)
                    }
                    .onChange(of: sortOption) { _ in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        }
                    }
                    
                    // Filter options
                    Picker("Filter", selection: $filterOption) {
                        Label("All", systemImage: "list.bullet").tag(FilterOption.all)
                        Label("Pending", systemImage: "clock").tag(FilterOption.pending)
                        Label("Completed", systemImage: "checkmark.circle").tag(FilterOption.completed)
                    }
                    .onChange(of: filterOption) { _ in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        }
                    }
                    
                    Divider()
                    
                    // Theme settings
                    Button {
                        showingThemeSettings = true
                    } label: {
                        Label("Theme Settings", systemImage: "paintbrush")
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
            
        }
    }
    
    // MARK: - Helper Methods
    private func deleteTask(_ task: FlowNestTask) {
        viewContext.delete(task)
        try? viewContext.save()
    }
    
    private func toggleTaskCompletion(_ task: FlowNestTask) {
        task.isCompleted.toggle()
        try? viewContext.save()
    }
    
    private func moveTask(from source: IndexSet, to destination: Int) {
        var revisedTasks = filteredTasks
        revisedTasks.move(fromOffsets: source, toOffset: destination)
        
        // Update sort order
        for (index, task) in revisedTasks.enumerated() {
            task.sortOrder = Int32(index)
        }
        
        try? viewContext.save()
    }
}



// MARK: - Previews
struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ThemeManager())
    }
}


extension AnyTransition {
    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.9)
                .combined(with: .opacity)
                .combined(with: .move(edge: .bottom)),
            removal: .scale(scale: 0.8)
                .combined(with: .opacity)
                .combined(with: .move(edge: .bottom))
        )
    }
}

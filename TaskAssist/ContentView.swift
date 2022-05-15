//
//  ContentView.swift
//  TaskAssist
//
//  Created by Viraj Lakshitha Bandara on 2022-05-15.
//

import SwiftUI

enum Priority: String, Identifiable, CaseIterable {
    var id: UUID {
        return UUID()
    }
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

extension Priority {
    var title: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var title: String = ""
    @State var domain: String = ""
    @State var priority: Priority = .low
    
    // Alert
    @State var isAlertVisible = false
    @State var alertMessage = ""
    
    @FetchRequest(entity: Task.entity(), sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: true)]) var allTasks : FetchedResults<Task>
    
    private func saveTask() {
        do {
            let newTask = Task(context: viewContext)
            newTask.title = title
            newTask.priority = priority.rawValue
            newTask.domain = domain
            newTask.createdAt = Date()
            
            // Save
            try viewContext.save()
        } catch {
            print("Unable to add new task \(error.localizedDescription)")
            alertMessage = "Unable to add new task \(error.localizedDescription)"
            isAlertVisible = true
        }
    }
    
    private func deleteTask(at offsets: IndexSet) {
        offsets.forEach { index in
            let task = allTasks[index]
            viewContext.delete(task)
            
            do {
                try viewContext.save()
            } catch {
                print("Unable to delete the task \(error.localizedDescription)")
                alertMessage = "Unable to delete the task \(error.localizedDescription)"
                isAlertVisible = true
            }
        }
    }
    
    private func undoChanges() {
        title = ""
        domain = ""
        priority = .low
    }
    
    private func styleForPriority(_ value: String) -> Color {
        let priority = Priority(rawValue: value)
        switch priority {
        case .low:
            return Color.green
        case .medium:
            return Color.orange
        case .high:
            return Color.red
        default:
            return Color.black
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter Title", text: $title)
                    .textFieldStyle(.roundedBorder)
                TextField("Enter Domain", text: $domain)
                    .textFieldStyle(.roundedBorder)
                Picker("Priority", selection: $priority) {
                    ForEach(Priority.allCases) {
                        priority in Text(priority.title).tag(priority)
                    }
                }.pickerStyle(.segmented)
                
                Button("Save") {
                    if title != "" && domain != "" {
                        saveTask()
                        undoChanges()
                    } else {
                        alertMessage = "Please fill empty fields"
                        isAlertVisible = true
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                
                // Display all tasks
                List {
                    ForEach(allTasks) { currTask in
                        HStack {
                            Circle()
                                .frame(width: 15)
                                .foregroundColor(styleForPriority(currTask.priority!))
                            
                            Spacer().frame(width: 28)
                            
                            Text(currTask.title ?? "---")
                                .font(.headline)
                                .foregroundColor(Color.black)
                            
                            Spacer()
                            
                            Text(currTask.domain ?? "---")
                                .font(.caption)
                                .foregroundColor(Color.gray)
                        }
                    }
                    .onDelete(perform: deleteTask)
                }
                .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                
                Spacer()
            }
            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            .navigationTitle("Task Assist")
        }
        
        .alert(isPresented: $isAlertVisible, content: {
            Alert(
                title: Text("Warning"),
                message: Text(alertMessage)
            )
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistenceContainer
        ContentView().environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}

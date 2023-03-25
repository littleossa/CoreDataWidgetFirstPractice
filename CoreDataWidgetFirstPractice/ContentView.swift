//
//  ContentView.swift
//  CoreDataWidgetFirstPractice
//
//

import SwiftUI
import CoreData
import WidgetKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State private var selectedItemForPresenting: Item?

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
        .onOpenURL { url in
            let uuid = getItemId(from: url)
            if let uuid,
               let item = fetchItem(id: uuid) {
                selectedItemForPresenting = item
            }
        }
        .sheet(item: $selectedItemForPresenting) { item in
            Text("Item at \(item.timestamp!, formatter: itemFormatter)")
        }
    }
    
    private func getItemId(from url: URL) -> UUID? {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
              urlComponents.scheme == "example",
              urlComponents.host == "widgetlink",
              urlComponents.queryItems?.first?.name == "item_id",
              let uuidString = urlComponents.queryItems?.first?.value else {
            return nil
        }
        return UUID(uuidString: uuidString)
    }
    
    private func fetchItem(id uuid: UUID) -> Item? {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)

        do {
            let items = try viewContext.fetch(fetchRequest)
            guard let item = items.first
            else { return nil }
            return item
            
        } catch let error as NSError {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.id = UUID()
            newItem.timestamp = Date()

            do {
                try viewContext.save()
                WidgetCenter.shared.reloadAllTimelines()
                
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
                WidgetCenter.shared.reloadAllTimelines()

            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

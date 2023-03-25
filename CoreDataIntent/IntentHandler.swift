//
//  IntentHandler.swift
//  CoreDataIntent
//
//

import Intents
import CoreData

class IntentHandler: INExtension, ConfigurationIntentHandling {
    
    private let context = PersistenceController.shared.container.viewContext
    
    func provideParameterOptionsCollection(for intent: ConfigurationIntent) async throws -> INObjectCollection<IntentItem> {
        
        let request = NSFetchRequest<Item>(entityName: "Item")
        var items: [IntentItem] = []
        
        let result = try context.fetch(request)
        
        result.forEach {
            items.append($0.intentItem)
        }
                
        return INObjectCollection(items: items)
    }
    
    override func handler(for intent: INIntent) -> Any {
        return self
    }
}

private extension Item {
    
    var intentItem: IntentItem {
        return IntentItem(identifier: self.id?.uuidString,
                          display: self.timestamp?.formatted() ?? "")
    }
}

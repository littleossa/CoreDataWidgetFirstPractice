//
//  CoreDataWidget.swift
//  CoreDataWidget
//
//

import WidgetKit
import SwiftUI

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),
                    configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(),
                                configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate,
                                    configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct CoreDataWidgetEntryView : View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    let entry: Provider.Entry
    
    var body: some View {
        
        if let intentItem = entry.configuration.parameter {
            
            VStack {
                Text("選択中")
                Text(intentItem.displayString)
                    .widgetURL(URL(string: "example://widgetlink?item_id=\(intentItem.identifier ?? "")"))
            }
            
        } else {
            VStack {
                Rectangle()
                    .fill(.blue.gradient)
                    .frame(height: 32)
                Divider()
                
                Spacer()
                
                ForEach(items) { item in
                    Text(item.timestamp ?? Date(), style: .time)
                }
                            
                Spacer()
            }
        }
    }
}

struct CoreDataWidget: Widget {
    let persistenceController = PersistenceController.shared
    let kind: String = "CoreDataWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: ConfigurationIntent.self,
                            provider: Provider()) { entry in
            CoreDataWidgetEntryView(entry: entry)
                .environment(\.managedObjectContext,
                              persistenceController.container.viewContext)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct CoreDataWidget_Previews: PreviewProvider {
    static var previews: some View {
        CoreDataWidgetEntryView(entry: SimpleEntry(date: Date(),
                                                   configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

//
//  widget.swift
//  widget
//
//  Created by Changyeol Seo on 4/23/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), image: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), image : nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, image: AppGroup.savedImage)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let image : UIImage?
}

struct widgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Image(uiImage: entry.image ?? .init(named: "placeHolder") ?? .init(systemName: "photo")!)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                    }
                    .shadow(radius: 10)
            }
            HStack {
                VStack {
                    Text(entry.date.formatted(date: .numeric, time: .omitted))
                        .font(.caption2)
                        .padding(5)
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.teal)
                        }
                        .shadow(radius: 10)
                        .padding(.top, 5)
                    Spacer()
                }
                Spacer()
            }
                
        }
        
    }
}

struct widget: Widget {
    let kind: String = "widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                widgetEntryView(entry: entry)
                    .containerBackground(.widgetBackground, for: .widget)
            } else {
                widgetEntryView(entry: entry)
                    .padding()
                    .background(.widgetBackground)
            }
        }
        .configurationDisplayName("widget display name")
        .description("widget description")
        
    }
}

@available(iOS 17.0, *)
#Preview(as: .systemSmall) {
    widget()
} timeline: {
    SimpleEntry(date: .now, image: nil)
    SimpleEntry(date: .now, image: .init(systemName: "person"))
}

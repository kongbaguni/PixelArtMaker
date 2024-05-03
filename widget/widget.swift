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
        SimpleEntry(date: Date(), image: nil, imageData: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), image : nil, imageData: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, image: AppGroup.savedImage, imageData: AppGroup.imageData)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let image : UIImage?
    let imageData : AppGroup.ImageData?
}

struct widgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        GeometryReader { geomentry in
            var isLarge:Bool {
                geomentry.size.width > 200
            }
            ZStack(alignment: .center) {
                if isLarge {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(entry.imageData?.backgroundColor.color ?? .clear)
                        .blur(radius: 5)
                        .opacity(0.5)
                }
                Image(uiImage: entry.image ?? .init(named: "placeHolder") ?? .init(systemName: "photo")!)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                    }
                    .shadow(radius: 10)
                    .frame(maxWidth: 250)
                if isLarge {
                    HStack {
                        VStack(alignment:.leading) {
                            Group {
                                if let data = entry.imageData {
                                    
                                    Text(
                                        String( format:
                                                    NSLocalizedString("image size %@", comment: "image data print widget"),
                                                "\(data.size)"
                                              )
                                    )
                                        
                                    
                                }
                            }
                            .font(.caption2)
                            .foregroundColor(.black)
                            .padding(5)
                            .background {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.white)
                            }
                            .shadow(radius: 10)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                
            }
            .frame(
                width: geomentry.size.width,
                height: geomentry.size.height
            )
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
    SimpleEntry(
        date: .now,
        image: nil,
        imageData: .init(
            size: .init(width: 300, height: 300),
            backgroundColor: .init(value: .init(red: 1.0, green: 0, blue: 0))
        )
    )
    SimpleEntry(
        date: .now,
        image: .init(systemName: "person"),
        imageData:.init(
            size: .init(width: 50, height: 50),
            backgroundColor: .init(value: .init(red: 0.0, green: 1.0, blue: 1.0))
        )
    )
}

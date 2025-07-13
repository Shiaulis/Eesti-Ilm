//
//  EstonianWeatherWidgetLiveActivity.swift
//  EstonianWeatherWidget
//
//  Created by Andrius Shiaulis on 13.07.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct EstonianWeatherWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct EstonianWeatherWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: EstonianWeatherWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension EstonianWeatherWidgetAttributes {
    fileprivate static var preview: EstonianWeatherWidgetAttributes {
        EstonianWeatherWidgetAttributes(name: "World")
    }
}

extension EstonianWeatherWidgetAttributes.ContentState {
    fileprivate static var smiley: EstonianWeatherWidgetAttributes.ContentState {
        EstonianWeatherWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: EstonianWeatherWidgetAttributes.ContentState {
         EstonianWeatherWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: EstonianWeatherWidgetAttributes.preview) {
   EstonianWeatherWidgetLiveActivity()
} contentStates: {
    EstonianWeatherWidgetAttributes.ContentState.smiley
    EstonianWeatherWidgetAttributes.ContentState.starEyes
}

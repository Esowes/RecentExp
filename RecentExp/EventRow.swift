//
//  EventRow.swift
//  RecentExp
//
//  Created by Serge Ostrowsky on 15/05/2020.
//  Copyright © 2020 Serge Ostrowsky. All rights reserved.
//

import SwiftUI
import CoreData

struct EventRow: View {
    
    @ObservedObject var event: Events
    @EnvironmentObject var appState: AppState
    
    var dateFormatter: DateFormatter {
     let formatter = DateFormatter()
    // formatter.dateStyle = .long
     formatter.dateFormat = "dd MMM yy"
     return formatter
     }
    
    struct textLayout: ViewModifier {
      func body(content: Content) -> some View {
        return content
            .lineLimit(1)
            .allowsTightening(true)
            .minimumScaleFactor(0.5)
        }
    }
    
    var body: some View {
        HStack (alignment: .center)
        {
            if event.isSimulator
            {
             Image(systemName: "s.circle")
                .font(.callout)
                .foregroundColor(Color(UIColor.systemRed))
            } else
            {
             Image(systemName: "airplane")
                .font(.callout)
                .foregroundColor(Color(UIColor.systemBlue))
             }
            Spacer(minLength: 0)
        if UserDefaults.standard.bool(forKey: kairportNameDisplayed) && UserDefaults.standard.bool(forKey: kflightNumberDisplayed) {
            VStack {
                Text(event.airportName ?? "")
                    .font(.headline)
                    .modifier(textLayout())
                Spacer()
                Text(event.flightNumber ?? "")
                    .font(.body)
                    .modifier(textLayout())
                    }
            .padding(EdgeInsets(top: 0, leading: -10, bottom: 0, trailing: 0))

        } else if UserDefaults.standard.bool(forKey: kairportNameDisplayed) {
                Text(event.airportName ?? "")
                .font(.headline)
                .modifier(textLayout())
                .padding(EdgeInsets(top: 0, leading: -10, bottom: 0, trailing: 0))

            } else if UserDefaults.standard.bool(forKey: kflightNumberDisplayed) {
                Text(event.flightNumber ?? "")
                .font(.body)
                .modifier(textLayout())
                .padding(EdgeInsets(top: 0, leading: -10, bottom: 0, trailing: 0))
            }
            Spacer(minLength: 0)
            if UserDefaults.standard.bool(forKey: kbiQualif) {
                VStack {
                    Text(self.dateFormatter.string(from: event.eventDate ?? Date()) )
                    .font(.body)
                    .modifier(textLayout())
                    Spacer()
                    if event.aircraftType == 1 { //330 ou 777
                        if UserDefaults.standard.integer(forKey: kdualTypeSelection) == 0
                        { Text("330").font(.footnote).modifier(textLayout()) }
                            else if UserDefaults.standard.integer(forKey: kdualTypeSelection) == 1
                        { Text("777").font(.footnote).modifier(textLayout()) }
                                               }
                    else if event.aircraftType == 2 { //350 ou 787
                        if UserDefaults.standard.integer(forKey: kdualTypeSelection) == 0
                        { Text("350").font(.footnote).modifier(textLayout()) }
                            else if UserDefaults.standard.integer(forKey: kdualTypeSelection) == 1
                        {Text("787").font(.footnote).modifier(textLayout()) }
                            }
                } // end of Vstack
                .padding(EdgeInsets(top: 0, leading: -10, bottom: 0, trailing: 0))
            } else // NOT biQualif
            {
                Text(self.dateFormatter.string(from: event.eventDate ?? Date()) )
                .font(.body)
                .modifier(textLayout())
                .padding(EdgeInsets(top: 0, leading: -10, bottom: 0, trailing: 0))
            }
        } // END of HStack
        .padding(EdgeInsets(top: 0, leading: -10, bottom: 0, trailing: -10))

 
    } // END of body
}

struct EventRow_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
                let newEvent = Events(context: context)
                newEvent.eventDate = Date()
                newEvent.aircraftType = 1
                newEvent.airportName = "JFK"
                newEvent.flightNumber = "AF 888"
                newEvent.id = UUID()
                newEvent.isLanding = true
                newEvent.isSimulator = false
        
        let newEvent2 = Events(context: context)
        newEvent2.eventDate = Date()
        newEvent2.aircraftType = 2
        newEvent2.airportName = "CDG"
        newEvent2.flightNumber = "AF 1234"
        newEvent2.id = UUID()
        newEvent2.isLanding = true
        newEvent2.isSimulator = true
        
        return Group {
            EventRow(event: newEvent).environment(\.managedObjectContext, context)
            .environmentObject(AppState())
        .previewLayout(.fixed(width: 300, height: 60))
            EventRow(event: newEvent2).environment(\.managedObjectContext, context)
                .environmentObject(AppState())
            .previewLayout(.fixed(width: 300, height: 60))
        }
        
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
////Test data
//        let newEvent = Events(context: context)
//        newEvent.eventDate = Date()
//        newEvent.aircraftType = 1
//        newEvent.airportName = "LDG tst"
//        newEvent.id = UUID()
//        newEvent.isLanding = true
//        newEvent.isSimulator = true
//
//        let newTakeoff = Events(context: context)
//        newTakeoff.eventDate = Date()
//        newTakeoff.aircraftType = 1
//        newTakeoff.airportName = "TOFF tst"
//        newTakeoff.id = UUID()
//        newTakeoff.isLanding = false
//        newTakeoff.isSimulator = true
//
//        return ContentView().environment(\.managedObjectContext, context)
//    }
//}

//
//  ContentView.swift
//  RecentExp
//
//  Created by Serge Ostrowsky on 24/04/2020.
//  Copyright © 2020 Serge Ostrowsky. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Takeoffs.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Takeoffs.eventDate, ascending: false)]) var fetchedTakeoffs: FetchedResults<Takeoffs>
    
    var body: some View {
        
        List {
            ForEach (fetchedTakeoffs, id: \.self) { item in
                Text(item.airportName)
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return ContentView().environment(\.managedObjectContext, context)
    }
}

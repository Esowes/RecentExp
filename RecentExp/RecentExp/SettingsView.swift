//
//  SettingsView.swift
//  RecentExp
//
//  Created by Serge Ostrowsky on 07/04/2020.
//  Copyright © 2020 Serge Ostrowsky. All rights reserved.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode // in order to dismiss the Sheet
    
    
    var body: some View {
        NavigationView {
            Form {
                Text("Settings View")
            }
            .navigationBarItems(
                leading:
                Button("Done") {
                      self.presentationMode.wrappedValue.dismiss() // This dismisses the view
                }
                
            )
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return SettingsView().environment(\.managedObjectContext, context)
    }
}

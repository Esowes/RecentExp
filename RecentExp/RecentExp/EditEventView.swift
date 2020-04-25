//
//  EditEventView.swift
//  RecentExp
//
//  Created by Serge Ostrowsky on 24/04/2020.
//  Copyright © 2020 Serge Ostrowsky. All rights reserved.
//

import SwiftUI
import CoreData

struct EditEventView: View {
    
    @Environment(\.presentationMode) var presentationMode // in order to dismiss the Sheet
        
        
        var body: some View {
            NavigationView {
                Form {
                    Text("Edit Event View")
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


struct EditEventView_Previews: PreviewProvider {
    static var previews: some View {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return EditEventView().environment(\.managedObjectContext, context)
    }
}

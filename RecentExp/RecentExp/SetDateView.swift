//
//  SetDateView.swift
//  RecentExp
//
//  Created by Serge Ostrowsky on 20/04/2020.
//  Copyright © 2020 Serge Ostrowsky. All rights reserved.
//

import SwiftUI
import CoreData

struct SetDateView: View {
    
    @Environment(\.presentationMode) var presentationMode // in order to dismiss the Sheet
        
    let defaults = UserDefaults.standard
    
    var dateFormatter: DateFormatter {
     let formatter = DateFormatter()
    // formatter.dateStyle = .long
     formatter.dateFormat = "dd MMM yy"
     return formatter
     }
    
    @State var selectedDate = Date()
    
    init() { // This sets "selectedDate" to the UserDefaults value
        _selectedDate = State(initialValue:  UserDefaults.standard.object(forKey: kactiveDate) as! Date) // The underscore is used here
    }
    
    var body: some View {
        
        VStack {
            Text("Romaneto")
            Spacer()
            
            Button(action: {
                self.selectedDate = Date()
            }) {
                Text("Today")
            }
            
            Divider()
            
            DatePicker("",selection: $selectedDate, in: Date()..., displayedComponents: .date)
                .padding(30)
                .labelsHidden()
                //.onReceive([self.selectedDate].publisher.first()) { (value) in self.saveDate() } // This allows for things to be triggered whenever the picker value is changed, but we don't need it anymore.
                
                Spacer()
                
                Button(action: {
                    withAnimation() {
                        self.saveDefaults()
                    }
                }) {
                    Text("Save")
                }
                .padding(.bottom)
            }

        }
    
    private func saveDefaults(){
        // We save the UserDefaults :
        UserDefaults.standard.set(selectedDate, forKey: kactiveDate)
        UserDefaults.standard.set("MainView", forKey: kactiveView)
        
        // Then, we dismiss the view :
        self.presentationMode.wrappedValue.dismiss()
        
        // keeping track :
        print("Saving the date to User Defaults : \(dateFormatter.string(from: selectedDate))")
    }
    
    
}
// Preview modified. You can add other device names in the array fed to the ForEach iteration.
struct SetDateView_Previews: PreviewProvider {
    static var previews: some View {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return SetDateView().environment(\.managedObjectContext, context)
        
    }
}

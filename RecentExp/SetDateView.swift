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
    
    @EnvironmentObject var appState: AppState
        
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
            NavigationView {
            VStack {
                Text("\(dateFormatter.string(from: selectedDate))")
                    .font(.title)
                    .padding(.all)
                Divider()
                VStack { // The Picker Stack
                Button(action: {
                    self.selectedDate = Date()
                }) {
                    Text("Today")
                }
                .padding([.top, .leading, .trailing])
                
                DatePicker("",selection: $selectedDate, displayedComponents: .date) // If add " in: Date()..." will only allow selection of future dates
                    .labelsHidden()
                    .padding([.leading, .bottom, .trailing])
                } // End of Picker stack
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(UIColor.systemBlue), lineWidth: 1))
                .padding(.all)
                    //.onReceive([self.selectedDate].publisher.first()) { (value) in self.saveDate() } // This allows for things to be triggered whenever the picker value is changed, but we don't need it anymore.
                    
                    Spacer()
            } // End of VStack
                .navigationBarItems(
                    leading:
                    Button("Done") {
                            self.saveDefaults()
                    }
                )
                .navigationBarTitle("Set Reference date :")
        } // End of NavigationView
    } // End of var body: some View
    
    private func saveDefaults(){
        // We save the UserDefaults :
            
        UserDefaults.standard.set(selectedDate, forKey: kactiveDate)
        
        // We save the AppState :
        self.appState.updateValues() // This is a func written in the AppState class
        
        // Then, we dismiss the view :
        self.presentationMode.wrappedValue.dismiss()
        
        // keeping track :
      //  print("Saving the date to User Defaults : \(dateFormatter.string(from: selectedDate))")
    }
    
    
}
// Preview modified. You can add other device names in the array fed to the ForEach iteration.
struct SetDateView_Previews: PreviewProvider {
    static var previews: some View {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return SetDateView().environmentObject(AppState())
            .environment(\.managedObjectContext, context)
                            
        
    }
}

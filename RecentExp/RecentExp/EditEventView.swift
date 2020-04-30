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
    
    let defaults = UserDefaults.standard
    
    var dateFormatter: DateFormatter {
     let formatter = DateFormatter()
    // formatter.dateStyle = .long
     formatter.dateFormat = "dd MMM yy"
     return formatter
     }
    
        
    @Environment(\.managedObjectContext) var managedObjectContext
    
    // We get the event to be edited through its UUID :
    @FetchRequest(entity: Takeoffs.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Takeoffs.eventDate, ascending: false)],
                  predicate: NSPredicate(format: "identNumber == %@", UUID(uuidString: UserDefaults.standard.string(forKey: kactiveEventUUID)!)! as CVarArg)) var fetchedEvent: FetchedResults<Takeoffs>
        // UserDefaults.standard.object(forKey: kactiveEventUUID) as! CVarArg)
    
    @State var selectedDate = Date()
    
    init() { // This sets "selectedDate" to the event's value for the date picker
        _selectedDate = State(initialValue:  fetchedEvent.first?.eventDate ?? Date()) // The underscore is used here
    }
    
    @State private var airportNameTextfield = ""
    @State private var typeSelectorIndex = 0
    @State private var types: [String] = [UserDefaults.standard.string(forKey: ktype1)!, UserDefaults.standard.string(forKey: ktype2)!]
    private var isBiqualif: Bool = UserDefaults.standard.bool(forKey: kbiQualif)
    
        var body: some View {
            NavigationView {
                Form {
                    HStack {
                        Text("Airport : ")
                        TextField(String(fetchedEvent.first?.airportName ?? ""), text: $airportNameTextfield)
                        .disabled(airportNameTextfield.count > 2) // To limit the textField to 3 chars (IATA code)
                        Button(action: {
                            self.airportNameTextfield = ""
                        }) {
                            Image(systemName: "clear")
                            }
                    } // END of Hstack
                    Picker("", selection: $typeSelectorIndex) {
                          ForEach(0 ..< types.count) { index in
                              Text(self.types[index]).tag(index)
                          }
                      }
                      .pickerStyle(SegmentedPickerStyle())
                    
                      // 3.
                    //  Text("Selected type is: \(types[typeSelectorIndex])")
                    
                    VStack {
                        Button(action: {
                            self.selectedDate = Date()
                        }) {
                            Text("Today")
                        }
                        DatePicker("",selection: $selectedDate, displayedComponents: .date)
                            .padding(30)
                            .labelsHidden()
                    }
                    
                    
                } // END of Form
                .navigationBarItems(
                    leading:
                    Button("Done") {
                        
                        self.saveEdits()
                        self.presentationMode.wrappedValue.dismiss() // This dismisses the view
                    } // END of Button "Done"
                    
                )
                .navigationBarTitle("Event edition")
            } // END of Navigation View
            
        } // END of some View
    func saveEdits() {
        // The event's Airport :
        if self.airportNameTextfield == "" {
        }
        else {
            self.fetchedEvent.first?.airportName = self.airportNameTextfield
        }
        // The event's type :
        self.fetchedEvent.first?.aircraftType = Int16(typeSelectorIndex + 1)  // +1 because 0 is no type : no dual type rating
        
        // The event's Date :
        self.fetchedEvent.first?.eventDate = selectedDate
        
        // Save event:
        do {
         try self.managedObjectContext.save()
         print("managedObjectContext saved from EditEvent view")
        } catch {
         print(error.localizedDescription)
         }
    } // End of
}


struct EditEventView_Previews: PreviewProvider {
    static var previews: some View {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return EditEventView().environment(\.managedObjectContext, context)
    }
}

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
    @FetchRequest(entity: Events.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Events.eventDate, ascending: false)],
                  predicate: NSPredicate(format: "id == %@", UUID(uuidString: UserDefaults.standard.string(forKey: kactiveEventUUID)!)! as CVarArg)) var fetchedEvent: FetchedResults<Events>
        // UserDefaults.standard.object(forKey: kactiveEventUUID) as! CVarArg)
    
    @State var selectedDate = Date()

    
    @State private var airportNameTextfield = ""
    @State private var flightNumberTextfield = ""
    @State private var typeSelectorIndex = 0
    @State private var simulatorSelectorIndex = 0
  //  @State private var types: [String] = ["A330", "A340"]
    private var isBiqualif: Bool = UserDefaults.standard.bool(forKey: kbiQualif)
    private var isAirportFieldShown: Bool = UserDefaults.standard.bool(forKey: kairportNameDisplayed)
    private var isFlightNumberFieldShown: Bool = UserDefaults.standard.bool(forKey: kflightNumberDisplayed)
    
    
        var body: some View {
            NavigationView {
                VStack {
                Form {
                    if isAirportFieldShown == true {
                    HStack {
                        Text("Airport : ")
                        TextField("IATA Code", text: $airportNameTextfield)
                        //  .disabled(airportNameTextfield.count > 2) // To limit the textField to 3 chars (IATA code)
                            .autocapitalization(/*@START_MENU_TOKEN@*/.allCharacters/*@END_MENU_TOKEN@*/)
                            .onAppear() {
                                self.airportNameTextfield = String(self.fetchedEvent.first?.airportName ?? "")
                        }
                             // This sets the Textfield's text to the existing IATA code upon launch
                        Button(action: {
                            self.airportNameTextfield = ""
                        }) {
                            Image(systemName: "clear")
                            }
                    } // END of name of airport Hstack
                    } // END of if isAirportFieldShown == true
                    
                    if isFlightNumberFieldShown == true {
                    HStack {
                        Text("Flight # : ")
                        TextField("Flight number", text: $flightNumberTextfield)
                        //  .disabled(airportNameTextfield.count > 2) // To limit the textField to 3 chars (IATA code)
                            .autocapitalization(/*@START_MENU_TOKEN@*/.allCharacters/*@END_MENU_TOKEN@*/)
                            .onAppear() {
                                self.flightNumberTextfield = String(self.fetchedEvent.first?.flightNumber ?? "")
                        } // This sets the Textfield's text to the existing IATA code upon launch
                        Button(action: {
                            self.flightNumberTextfield = ""
                        }) {
                            Image(systemName: "clear")
                            }
                    } // END of flight number Hstack
                    } // END of if isFlightNumberFieldShown == true
                    
                    // The Flight / Sim picker :
                        Picker("", selection: $simulatorSelectorIndex) {
                                Text("Flight").tag(0)
                                Text("Simulator").tag(1)
                          }
                          .pickerStyle(SegmentedPickerStyle())
                        .onAppear() {
                            if self.fetchedEvent.first?.isSimulator ?? false == true { // If it's a simulator, we mark it as such
                                self.simulatorSelectorIndex = 1
                            } else {
                                self.simulatorSelectorIndex = 0
                            }
                        } // This sets the segmented control's selection to the existing value
                    
                    if isBiqualif { // If dual rating is activated in settings
                        if UserDefaults.standard.integer(forKey: kdualTypeSelection) == 0 { // 330/350
                            Picker("", selection: $typeSelectorIndex) {
                                Text("330").tag(0)
                                Text("350").tag(1)
                              }
                              .pickerStyle(SegmentedPickerStyle())
                            .onAppear() {
                                if UserDefaults.standard.bool(forKey: kbiQualif) {
                                    self.typeSelectorIndex = Int(self.fetchedEvent.first!.aircraftType) - 1 // 0 or 1
                                }
                            } // This sets the segmented control's selection to the existing value
                        } // END of if 330/350
                        else if UserDefaults.standard.integer(forKey: kdualTypeSelection) == 1 { // 777/787
                            Picker("", selection: $typeSelectorIndex) {
                                  Text("777").tag(0)
                                  Text("787").tag(1)
                              }
                              .pickerStyle(SegmentedPickerStyle())
                            .onAppear() {
                                if UserDefaults.standard.bool(forKey: kbiQualif) {
                                    self.typeSelectorIndex = Int(self.fetchedEvent.first!.aircraftType) - 1 // 0 or 1
                                }
                            } // This sets the segmented control's selection to the existing value
                        }

                    } //  End of if isBiqualif statement for Type Picker
                    //Text("the F/S picker shows : \(simulatorSelectorIndex)")
                    
                } // END of Form
                    
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
                    
                } // End of VStack
                .navigationBarItems(
                    leading:
                        Button("Cancel") {
                            //self.saveEdits()
                            self.presentationMode.wrappedValue.dismiss() // This dismisses the view
                        }, // END of Button "Cancel"
                    trailing:
                        Button("Done") {
                            print("Done pressed from editView")
                            self.saveEdits()
                            self.presentationMode.wrappedValue.dismiss() // This dismisses the view
                        } // END of Button "Done"
                )
                .navigationBarTitle("Event edition")
                
            } // END of Navigation View
            .onAppear { // assigned fetched event date, here it is available (was not in init())
            self.selectedDate = self.fetchedEvent.first?.eventDate ?? Date()
            }
        
        } // END of some View
    
    
 
    func saveEdits() {
        // The event's Airport :
        if self.airportNameTextfield == "" {
        }
        else {
            self.fetchedEvent.first?.airportName = self.airportNameTextfield
        }
        // The event's flight number :
        if self.flightNumberTextfield == "" {
        }
        else {
            self.fetchedEvent.first?.flightNumber = self.flightNumberTextfield
        }
        
        // The event's type :
        if isBiqualif {
        self.fetchedEvent.first?.aircraftType = Int16(typeSelectorIndex + 1)  // +1 because 0 is no type : no dual type rating ( 1 is 330 or 777 and 2 is 350 or 787)
        }
        
        // The event's Date :
        self.fetchedEvent.first?.eventDate = selectedDate
        
        // The event's status : Flight or Simulator ?
        if self.simulatorSelectorIndex == 0 {
            self.fetchedEvent.first?.isSimulator = false
        } else {
            self.fetchedEvent.first?.isSimulator = true
        }
      //  print("saving edits in EditTakeoff view : the event is a simulator : \(String(describing: self.fetchedEvent.first?.isSimulator))")
        
        // Save event:
        
        if self.managedObjectContext.hasChanges {
            do {
             try self.managedObjectContext.save()
             print("managedObjectContext saved from EditEvent view")
            } catch {
             print(error.localizedDescription)
             }
        } // End of self.managedObjectContext.hasChanges
    } // End of saveEdits
}


struct EditEventView_Previews: PreviewProvider {
    static var previews: some View {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return EditEventView().environment(\.managedObjectContext, context)
    }
}

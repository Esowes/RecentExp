//
//  CreateEventView.swift
//  RecentExp
//
//  Created by Serge Ostrowsky on 01/05/2020.
//  Copyright © 2020 Serge Ostrowsky. All rights reserved.
//

import SwiftUI

struct CreateEventView: View {
    
    @Environment(\.presentationMode) var presentationMode // in order to dismiss the Sheet
    
    let defaults = UserDefaults.standard
    
    var dateFormatter: DateFormatter {
     let formatter = DateFormatter()
    // formatter.dateStyle = .long
     formatter.dateFormat = "dd MMM yy"
     return formatter
     }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var selectedDate = Date()
    @State private var airportNameTextfield = ""
    @State private var flightNumberTextfield = ""
    @State private var typeSelectorIndex = 0
    @State private var simulatorSelectorIndex = 0
    var isBiqualif: Bool = UserDefaults.standard.bool(forKey: kbiQualif)
    var isAirportFieldShown: Bool = UserDefaults.standard.bool(forKey: kairportNameDisplayed)
    var isFlightNumberShown: Bool = UserDefaults.standard.bool(forKey: kflightNumberDisplayed)
    
    
    var viewTitle: String = UserDefaults.standard.string(forKey: kEventCreationTitle) ?? "Event creation"
    
    
    var body: some View {
        NavigationView {
            ScrollView {
            VStack {
                if isAirportFieldShown == true {
                    Text("Enter Airport Code")
                        .padding(.top)
                    HStack {
                TextField("IATA or ICAO Code", text: $airportNameTextfield)
                    .padding(.leading)
                    .frame(height: 40.0)
                    .autocapitalization(/*@START_MENU_TOKEN@*/.allCharacters/*@END_MENU_TOKEN@*/)
                   // .disabled(airportNameTextfield.count > 2) // To limit the textField to 3 chars (IATA code)
                    Button(action: {
                        self.airportNameTextfield = ""
                    }) {
                        Image(systemName: "clear")
                        .font(.system(size: 20))
                    }
                    .padding(.trailing)
                } // End of HStack Airport
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor.systemBlue), lineWidth: 1))
                    .padding(.horizontal)
            } // End of if isAirportFieldShown == true
                
                Divider()
                
                    if isFlightNumberShown == true {
                        Text("Enter Flight number")
                    HStack {
                    TextField("Flight number", text: $flightNumberTextfield)
                        .padding(.leading)
                        .frame(height: 40.0)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.allCharacters/*@END_MENU_TOKEN@*/)
                       // .disabled(airportNameTextfield.count > 2) // To limit the textField to 3 chars (IATA code)
                        Button(action: {
                            self.flightNumberTextfield = ""
                        }) {
                            Image(systemName: "clear")
                            .font(.system(size: 20))
                        }
                        .padding(.trailing)
                    } // End of HStack Airport
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor.systemBlue), lineWidth: 1))
                        .padding(.horizontal)
                } // End of if isAirportFieldShown == true
                
                    Divider()
                
                // The Flight / Sim picker :
                    Picker("", selection: $simulatorSelectorIndex) {
                            Text("Flight").tag(0)
                            Text("Simulator").tag(1)
                    }
                    .padding([.horizontal, .bottom])
                      .pickerStyle(SegmentedPickerStyle())
                
                // The type picker if it's a biqualif
    // *******************************************************
                    if isBiqualif { // If dual rating is activated in settings
                        if UserDefaults.standard.integer(forKey: kdualTypeSelection) == 0 { // 330/350
                            Picker("", selection: $typeSelectorIndex) {
                                Text("330").tag(0)
                                Text("350").tag(1)
                              }
                            .padding(.horizontal)
                            .pickerStyle(SegmentedPickerStyle())
                        } // END of if 330/350
                        else if UserDefaults.standard.integer(forKey: kdualTypeSelection) == 1 { // 777/787
                            Picker("", selection: $typeSelectorIndex) {
                                  Text("777").tag(0)
                                  Text("787").tag(1)
                              }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)
                        }

                    } //  End of if isBiqualif statement for Type Picker
    // *******************************************************
                    Divider()
                
                VStack {
                    Button(action: {
                        self.selectedDate = Date()
                    }) {
                        Text("Today")
                            .font(.system(size: 20))
                    }
                    DatePicker("",selection: $selectedDate, displayedComponents: .date)
                        .padding([.leading, .bottom, .trailing])
                        .labelsHidden()
                }
                
            } // End of main VStack
            .navigationBarItems(
                leading:
                Button("Done") {
                    self.createEvent()
                }, // END of Button "Done"
                trailing:
                Button("Cancel") {
                    //self.saveEdits()
                    self.presentationMode.wrappedValue.dismiss() // This dismisses the view
                } // END of Button "Cancel"
            )
                .navigationBarTitle(viewTitle)
                } // END of ScrollView
        } // END of Navigation View
    } // END of some View
    
    func createEvent() {
        let newEvent = Events(context: self.managedObjectContext)
        newEvent.airportName = self.airportNameTextfield
        newEvent.flightNumber = self.flightNumberTextfield
        if isBiqualif {
            newEvent.aircraftType = Int16(typeSelectorIndex + 1) // 1 is 330, 2 is 340
        } else {
            newEvent.aircraftType = 0 // 0 is "generic" type for single type ratings
        }
        if self.simulatorSelectorIndex == 0 { // Flight
            newEvent.isSimulator = false
        } else {
            newEvent.isSimulator = true
        }
        newEvent.eventDate = self.selectedDate
        newEvent.id = UUID()
        
        if defaults.bool(forKey: kIsEventLanding) { // This was set in the "Add Takeoff" or "Add landing" buttons action
            newEvent.isLanding = true
        } else {
            newEvent.isLanding = false
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
        
        self.dismissView()
    } // End of saveEvent
    
    private func dismissView() {
        self.presentationMode.wrappedValue.dismiss() // This dismisses the view
    }
    
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        //Test data
     let myBool = true
        return CreateEventView(isBiqualif: myBool)
    }
}


//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
////Test data
//        let newEvent = Event.init(context: context)
//        newEvent.timestamp = Date()
//        return DetailView(event: newEvent).environment(\.managedObjectContext, context)
//    }
//}

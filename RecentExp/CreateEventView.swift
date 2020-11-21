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
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = .medium // Nov 14, 2020
     //   formatter.dateFormat = "dd MMM yy"
     return formatter
     }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var isEmptyFieldAlertPresented = false

    
    @State private var selectedDate = Date()
    @State private var airportNameTextfield = ""
    @State private var flightNumberTextfield = ""
    @State private var typeSelectorIndex = 0
    @State private var simulatorSelectorIndex = 0
    @State private var eventTypeSelectorIndex = -1
    var isBiqualif: Bool = UserDefaults.standard.bool(forKey: kbiQualif)
    var isAirportFieldShown: Bool = UserDefaults.standard.bool(forKey: kairportNameDisplayed)
    var isFlightNumberShown: Bool = UserDefaults.standard.bool(forKey: kflightNumberDisplayed)
    
    var body: some View {
        NavigationView {
            ScrollView {
            VStack {
                Group {
                Text("Type of event")
                    .padding(.top)
                    Picker("", selection: $eventTypeSelectorIndex.animation()) { // added the .animation() in order to animate the appearence / dissappearence of the textfield
                        Text("TAKEOFF").tag(0)
                        Text("LANDING").tag(1)
                        Text("BOTH").tag(2)
                }
                .padding([.horizontal, .bottom, .top])
                .pickerStyle(SegmentedPickerStyle())
                    
                    if eventTypeSelectorIndex == 2 {
                        
                        Text("You've chosen to create both a takeoff and a landing.\nPlease note that both these events will have the same Type (Flight or Simulator) as well as Airport and/or Flight number if these settings are enabled.")
                            .font(.footnote)
                            .padding(.horizontal)
                            .animation(.easeInOut)
                    }
                    
                
                Divider()
                }
                
                if isAirportFieldShown == true {
                    Text("Enter Airport Code")
                        .padding(.top)
                    HStack {
                TextField("IATA or ICAO Code", text: $airportNameTextfield)
                    .padding(.leading)
                    .frame(height: 40.0)
                    .autocapitalization(/*@START_MENU_TOKEN@*/.allCharacters/*@END_MENU_TOKEN@*/)
                    .onChange(of: airportNameTextfield,
                              perform: { (value) in
                                if airportNameTextfield.count == 4 {
                                    UIApplication.shared.endEditing() // Call to dismiss keyboard
                                } else if airportNameTextfield.count >= 4 {
                                    airportNameTextfield = String(airportNameTextfield.prefix(4))
                                    UIApplication.shared.endEditing() // Call to dismiss keyboard
                                }
                              }) // This .onChange modifier ensures the text is limited to 4 chars
                    Button(action: {
                        self.airportNameTextfield = ""
                    }) {
                        Image(systemName: "clear")
                        .font(.system(size: 20))
                    }
                    .padding(.trailing)
                } // End of HStack Airport
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor.systemBlue), lineWidth: 1))
                    .padding([.horizontal, .bottom])
                    
                    Divider()
            } // End of if isAirportFieldShown == true
                
               
                
                    if isFlightNumberShown == true {
                        Text("Enter Flight number")
                    HStack {
                    TextField("Flight number", text: $flightNumberTextfield)
                        .padding(.leading)
                        .frame(height: 40.0)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.allCharacters/*@END_MENU_TOKEN@*/)
                        .onChange(of: flightNumberTextfield,
                                  perform: { (value) in
                                    if flightNumberTextfield.count == 7 {
                                        UIApplication.shared.endEditing() // Call to dismiss keyboard
                                    } else if flightNumberTextfield.count >= 7 {
                                        flightNumberTextfield = String(flightNumberTextfield.prefix(7))
                                        UIApplication.shared.endEditing() // Call to dismiss keyboard
                                    }
                                  }) // This .onChange modifier ensures the text is limited to 7 chars
                        Button(action: {
                            self.flightNumberTextfield = ""
                        }) {
                            Image(systemName: "clear")
                            .font(.system(size: 20))
                        }
                        .padding(.trailing)
                    } // End of HStack Airport
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor.systemBlue), lineWidth: 1))
                    .padding([.horizontal, .bottom])
                        Divider()
                } // End of if isAirportFieldShown == true
                
                    
                
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
                
                VStack { // The date picker
                    Text("Choose date")
                        .padding([.horizontal, .bottom])

                    Button(action: {
                        self.selectedDate = Date()
                    }) {
                        Text("Today")
                    }
                    DatePicker("",selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor.systemBlue), lineWidth: 1))
                        .padding([.leading, .bottom, .trailing])
                        .labelsHidden()
                }
                
            } // End of main VStack
            .navigationBarItems(
                leading:
                    Button("Cancel") {
                        //self.saveEdits()
                        self.presentationMode.wrappedValue.dismiss() // This dismisses the view
                    }
                    .foregroundColor(/*@START_MENU_TOKEN@*/.red/*@END_MENU_TOKEN@*/), // END of Button "Cancel"
                trailing:
                    Button("Done") {
                        // Alert in empty fields :
                        if isAirportFieldShown == true && airportNameTextfield.count == 0 // Le champ Airport est affiché et il est encore vide
                        {
                            isEmptyFieldAlertPresented = true
                        } else if isFlightNumberShown == true && flightNumberTextfield.count == 0 // Le champ FltNumber est affiché et il est encore vide
                        {
                            isEmptyFieldAlertPresented = true
                        } else {
                            self.createEvent()
                        }
                        
                    } // END of Button "Done"
                    .alert(isPresented: $isEmptyFieldAlertPresented) { () -> Alert in
                        return Alert(title: Text("❗️WARNING❗️")
                            .foregroundColor(Color(UIColor.systemRed)), message: Text(
                        "Airport name and/or Flight number is empty, event cannot be saved."
                      ), dismissButton: .default(Text("Ooops")))
                    }// End of Alert
            ) // End of navigationBarItems
            .navigationBarTitle("Event creation")
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
        
        if eventTypeSelectorIndex == 0 // choix T-off
        {
            newEvent.isLanding = false
        }
        else if eventTypeSelectorIndex == 1 // choix Ldg
        {
            newEvent.isLanding = true
        }
        else if eventTypeSelectorIndex == 2 // choix both
        {
            newEvent.isLanding = false // we create a takeoff, landing will be created below
            
            /*let newEvent2 = Events(context: self.managedObjectContext)
            newEvent2.airportName = self.airportNameTextfield
            newEvent2.flightNumber = self.flightNumberTextfield
            if isBiqualif {
                newEvent2.aircraftType = Int16(typeSelectorIndex + 1) // 1 is 330, 2 is 340
            } else {
                newEvent2.aircraftType = 0 // 0 is "generic" type for single type ratings
            }
            if self.simulatorSelectorIndex == 0 { // Flight
                newEvent2.isSimulator = false
            } else {
                newEvent2.isSimulator = true
            }
            newEvent2.eventDate = self.selectedDate
            newEvent2.id = UUID()
            newEvent2.isLanding = true*/
            
            // Cloning method :
            let newEvent2 = cloneManagedObject(event: newEvent)
            newEvent2.isLanding = true
            
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
    
    public func cloneManagedObject(event:Events) -> Events {
    //1.create a new ManagedObject :
        let clonedObject = Events(context: self.managedObjectContext)
    //2.set all the attributes of this object
        clonedObject.aircraftType = event.aircraftType
        clonedObject.airportName = event.airportName
        clonedObject.eventDate = event.eventDate
        clonedObject.flightNumber = event.flightNumber
        clonedObject.isLanding = event.isLanding
        clonedObject.isSimulator = event.isSimulator
        clonedObject.id = UUID()

        return clonedObject
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

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
    
    @FetchRequest(entity: Landings.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Landings.eventDate, ascending: false)]) var fetchedLandings: FetchedResults<Landings>
    
    @State var settingsModalIsPresented = false // The "settingsView" modally presented as a sheet
    
    var dateFormatter: DateFormatter {
     let formatter = DateFormatter()
    // formatter.dateStyle = .long
     formatter.dateFormat = "dd MMM yy"
     return formatter
     }
    
   @State private var modalViewCaller = 0
    
    // MARK: View modifiers :
    
    struct DisableModalDismiss: ViewModifier {
        let disabled: Bool
        func body(content: Content) -> some View {
            disableModalDismiss()
            return AnyView(content)
        }

        func disableModalDismiss() {
            guard let visibleController = UIApplication.shared.visibleViewController() else { return }
            visibleController.isModalInPresentation = disabled
        }
    } // End of DisabledModalDismiss
    
    var body: some View {
        
            VStack {
                HStack {
                    VStack { // Takeoffs Vstack
                        Text("Takeoffs")
                        List {
                            
                            ForEach (fetchedTakeoffs, id: \.self) { item in
                                HStack {
                                    Text(item.airportName ?? "")
                                    Text(self.dateFormatter.string(from: item.eventDate!) )
                                }
                                    .contextMenu {
                                        
                                    Button(action: {
                                        self.modalViewCaller = 1 // To tell the sheet which view to display
                                        UserDefaults.standard.set(item.identNumber?.uuidString, forKey: kactiveEventUUID)
                                        self.settingsModalIsPresented = true
                                    })
                                    {   Text("Edit entry")
                                        Image(systemName: "globe")
                                    }
                                        Button(action: {
                                            self.managedObjectContext.delete(item)
                                            self.saveContext()
                                        }) {
                                            Text("Erase entry")
                                                .foregroundColor(Color.red)
                                            Image(systemName: "location.circle")
                                            }
                                } // END of ContextMenu
                            } // For Each end
                            .onDelete { indexSet in
                                for index in indexSet {
                                    self.managedObjectContext.delete(self.fetchedTakeoffs[index])
                                    self.saveContext()
                                }
                            }
                            Button(action: {
                                //guard self.tableNumber != "" else {return}
                                // We create the new Takeoff :
                                let newTakeoff = Takeoffs(context: self.managedObjectContext)
                                                    newTakeoff.aircraftType = 0 // default mono-fleet type
                                                    newTakeoff.airportName = "CDG"
                                                    newTakeoff.eventDate = Date()
                                                    newTakeoff.identNumber = UUID()
                                                    newTakeoff.isSimulator = false
                                // We save it :
                                self.saveContext()
                            } // END of "Add Takeoff" Button action
                            ) {
                                Text("Add Takeoff")
                            }
                        } // END of Takeoffs List
                    } // END of Takeoffs VStack
                    
                    VStack { // Landings Vstack
                        Text("Landings")
                        List {
                            
                            ForEach (fetchedLandings, id: \.self) { item in
                               Text(item.airportName ?? "")
                                .contextMenu {
                                    
                                Button(action: {
                                    self.modalViewCaller = 1 // To tell the sheet which view to display
                                    self.settingsModalIsPresented = true
                                })
                                {   Text("Edit entry")
                                    Image(systemName: "globe")
                                }
                                    Button(action: {
                                        // enable geolocation
                                    }) {
                                        Text("Erase entry")
                                            .foregroundColor(Color.red)
                                        Image(systemName: "location.circle")
                                        }
                                    } // END of ContextMenu
                            } // For Each end
                            
                            Button(action: {
                                //guard self.tableNumber != "" else {return}
                                // We create the new Takeoff :
                                let newLanding = Landings(context: self.managedObjectContext)
                                                    newLanding.aircraftType = 0 // default mono-fleet type
                                                    newLanding.airportName = "CDG"
                                                    newLanding.eventDate = Date()
                                                    newLanding.identNumber = UUID()
                                                    newLanding.isSimulator = false
                                // We save it :
                                do {
                                  try self.managedObjectContext.save()
                                  print("Landing saved")
                                 } catch {
                                  print(error.localizedDescription)
                                  }
                            } // END of "Add Takeoff" Button action
                            ) {
                                Text("Add Landing")
                            }
                        } // END of Landings List
                    } // End of Landings VStack
                } // End of Takeoffs & Landings HStack
                Divider()
                HStack { // Ref date HStack
                    Text("Reference Date :")
                  
                        Button(action: {
                            self.modalViewCaller = 3 // SetDateView
                            self.settingsModalIsPresented = true// Code here to trigger the SetDate modal view
                            
                        }) {
                            if dateFormatter.string(from: UserDefaults.standard.object(forKey: kactiveDate) as! Date) == dateFormatter.string(from: Date())
                            {
                                Text("Today")
                            }
                            else {
                                Text(dateFormatter.string(from: UserDefaults.standard.object(forKey: kactiveDate) as! Date))
                            }
                        }
                    
                    
                } // END of Ref date HStack
                
                Spacer(minLength: 20)
            // settings button :
                Button(action: {
                    self.modalViewCaller = 4 // SettingsView
                    self.settingsModalIsPresented = true
                    
                } // setting this @State variable to true, hence changing its value, is enough to trigger the presentation of the modal view (the Sheet)
                    ) {
                        Image(systemName: "gear")
                        //   .resizable()
                        //   .scaledToFit()
                        //   .frame(width: 30.0,height:30.0)
                             .font(.system(size: 30))
                //     .multilineTextAlignment(.center)
                     }
//                .sheet(isPresented: $settingsModalIsPresented) {
//                                SettingsView()
//                        }
                Spacer(minLength: 20)
            } // END of main VStack
                .sheet(isPresented: $settingsModalIsPresented, content: sheetContent)

    } // END of body
    
    @ViewBuilder func sheetContent() -> some View {
        if modalViewCaller == 1 {
            EditEventView().environment(\.managedObjectContext, self.managedObjectContext) // Due to a bug in SwiftUI, we need to pass the managedObjectContext
            .modifier(DisableModalDismiss(disabled: true)) // This prevents the dismissal of the modal view by swiping down, thanks to the UIApplication extension in AppDelegate
        } else if modalViewCaller == 2 {
            EditEventView().environment(\.managedObjectContext, self.managedObjectContext)
            .modifier(DisableModalDismiss(disabled: true))
        } else if modalViewCaller == 3 {
            SetDateView()
            .modifier(DisableModalDismiss(disabled: true))
        } else if modalViewCaller == 4 {
            SettingsView()
            .modifier(DisableModalDismiss(disabled: true))
        }
    } // END of func sheetContent
    
    private func saveContext() {
        do {
         try self.managedObjectContext.save()
         print("managedObjectContext saved")
        } catch {
         print(error.localizedDescription)
         }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return ContentView().environment(\.managedObjectContext, context)
    }
}

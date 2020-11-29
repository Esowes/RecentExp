//
//  SettingsView.swift
//  RecentExp
//
//  Created by Serge Ostrowsky on 07/04/2020.
//  Copyright © 2020 Serge Ostrowsky. All rights reserved.
//

import SwiftUI
import CoreData
import UIKit
import Combine

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode // in order to dismiss the Sheet
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
   // @StateObject var appState: AppState
    @ObservedObject var appState: AppState // Binding to the appState in main
    //@Binding var modalViewCaller : Int
        
    @FetchRequest(entity: Events.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Events.eventDate, ascending: false)]) var allEvents: FetchedResults<Events> // This fetches all the events
    
    
    @State public var isBiQualif = UserDefaults.standard.bool(forKey: kbiQualif)
    @State private var isInstructor = UserDefaults.standard.bool(forKey: kisInstructor)
    
    @State private var isAirportDisplayed = UserDefaults.standard.bool(forKey: kairportNameDisplayed)
    @State private var isFlightNumberDisplayed = UserDefaults.standard.bool(forKey: kflightNumberDisplayed)
    @State var allowMultipleEventsCreation = UserDefaults.standard.bool(forKey: kAllowMultipleIdenticalEvents)

    
    
    @State private var isEraseAlertVisible = false
    @State private var dualTypeSelection = UserDefaults.standard.integer(forKey: kdualTypeSelection) // 0 is 330/350, 1 is 777/787
    @State private var rulesSelection = UserDefaults.standard.integer(forKey: krulesSelection) // 0 is ICAO, 1 is Air France
   // @State var appLanguage = Locale.preferredLanguages[0]
//    struct textFieldStyle: ViewModifier {
//      func body(content: Content) -> some View {
//        return content
//          .foregroundColor(Color.white)
//          .font(Font.custom("Arial Rounded MT Bold", size: 18))
//      }
//    }
    
//    struct textFieldOptions: ViewModifier {
//      func body(content: Content) -> some View {
//        return content
//            .frame(height: 40.0)
//          .keyboardType(/*@START_MENU_TOKEN@*/.numberPad/*@END_MENU_TOKEN@*/)
//      }
//    }
//    struct languageButtonDraw: ViewModifier {
//      func body(content: Content) -> some View {
//        return content
//            .font(.headline)
//            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
//            .background(Color(UIColor.systemBlue))
//            .cornerRadius(12)
//            .foregroundColor(Color.white)
//        }
//    }
    
    var body: some View {
        
        NavigationView {
            List {
                Group {
                    Section(header: userHeader(), footer: userFooter(myBool: isBiQualif)) {
                        Toggle(isOn: $isBiQualif.animation()) {
                           Text("Dual type 330/350 or 777/787 ?")
                        }
                        .padding(.horizontal)
                        if isBiQualif {
                            Picker("", selection: $dualTypeSelection){
                                Text("330 / 350").tag(0)
                                Text("777 / 787").tag(1)
                            }.pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)
                            .animation(.easeInOut)
                        }
//                    if isBiQualif { // AF Rules has extra requirements for 330/340 dual-type rated Instructors
//                        Toggle(isOn: $isInstructor) {
//                           Text("Are you an Instructor ?")
//                        }
//                        .padding(.horizontal)
//                    }
                    } // End of section "users"
                
                Section(header: CurrencyRulesHeader(), footer: CurrencyRulesFooter(ruleSelect: rulesSelection)) {
                    Picker("", selection: $rulesSelection.animation()){
                        Text("ICAO").tag(0)
                        Text("Air France").tag(1)
                    }.pickerStyle(SegmentedPickerStyle())
                    .onChange(of: rulesSelection,
                              perform: { (value) in
                                print("Picker value was changed : now is \(rulesSelection)")
                                self.saveDefaults()
                                print("The user default rule is : \(UserDefaults.standard.integer(forKey: krulesSelection))")
                                        })
                    .padding(.horizontal)
                    } // End of ICAO currency Section
                } // End og Group 1
                 Group {
                    
                    Section(header: displayHeader(), footer: displayFooter(doesAllowMultipleEvents: allowMultipleEventsCreation)) {
                      //  Text("Choose if you want the following data to be displayed :")
                        Toggle(isOn: $isAirportDisplayed) {
                           Text("Input airport code ?")
                        }
                        .padding(.horizontal)
                        Toggle(isOn: $isFlightNumberDisplayed) {
                           Text("Input flight number ?")
                        }
                        .padding(.horizontal)
                        Toggle(isOn: $allowMultipleEventsCreation.animation()) {
                           Text("Allow multiple identical events creation ?")
                        }
                        .padding(.horizontal)
                    }//.textCase(nil) // to prevent the header from being ALL CAPS !
                    
                Section(header: eraseAllHeader()) {
                    // Erase all :
                    Button(action: {
                        print("Erase all button pressed")
                        self.isEraseAlertVisible = true // We display the ERASE ALL Alert
                        }
                    ){
                        HStack {
                            Text("Erase all entries")
                                .padding(.leading)
                            Spacer()
                            Image(systemName: "trash")
                                .padding(.trailing)
                        }
                        .foregroundColor(Color(UIColor.systemRed))
                    }
                    .alert(isPresented: $isEraseAlertVisible) { () -> Alert in
                        return Alert(title: Text("❗️WARNING❗️")
                            .foregroundColor(Color(UIColor.systemRed)), message: Text(
                        "Are you SURE you want to erase ALL your data ?\nThis will also erase it from iCloud."
                      ), primaryButton: .default(Text("Cancel")) {
                            }, secondaryButton: .destructive(Text("YES, I'm sure")) {
                                self.eraseAllEvents()
                            })
                    }// End of Alert
                } // End of Erase section
            } // End of Group 2
        } // End of List
            .navigationBarItems(
                trailing:
                Button("Done") {
                        self.saveDefaults() // We try to save once more if needed
                    UserDefaults.standard.set(true, forKey: kinitialInstrViewed)
                        self.presentationMode.wrappedValue.dismiss() // This dismisses the view
                 //   self.modalViewCaller = 0
                }
            )
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings \(UIApplication.appVersion ?? "" )", displayMode: .inline) // appVersion is a var created in the AppDelegate in the extension
        } .onDisappear() {
        self.appState.updateValues() // This triggers a re-render of the body by changing the appState @Environment(Observed) object, and allows the UI of the cells of the Lists to be updated if settings were changed // END of Navigation view
            print("\n\n*********** Settings View onDissappear triggered ! ************\n")
        }
    } // END of some View
    
    func eraseAllEvents() {
        for event in self.allEvents {
            self.managedObjectContext.delete(event)
        }
        self.saveContext()
    }
    
    func openSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    
    func saveDefaults() {
        UserDefaults.standard.set(isBiQualif, forKey: kbiQualif)
        UserDefaults.standard.set(isInstructor, forKey: kisInstructor)
        UserDefaults.standard.set(dualTypeSelection, forKey: kdualTypeSelection)
        UserDefaults.standard.set(rulesSelection, forKey: krulesSelection)
        UserDefaults.standard.set(isAirportDisplayed, forKey: kairportNameDisplayed)
        UserDefaults.standard.set(isFlightNumberDisplayed, forKey: kflightNumberDisplayed)
        UserDefaults.standard.set(allowMultipleEventsCreation, forKey: kAllowMultipleIdenticalEvents)

        
        
        self.appState.updateValues() // This is a func from the AppState class
        
    }
    
    private func saveContext() { // If we erased al the entries
        // Save event:
        
        if self.managedObjectContext.hasChanges {
            do {
             try self.managedObjectContext.save()
             print("managedObjectContext saved from ContentView view")
            } catch {
             print(error.localizedDescription)
             }
        } // End of self.managedObjectContext.hasChanges

    } // End of func saveContext()
    
//    private func eraseAllData() {
//        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchedTakeoffs)
//        batchDeleteRequest.resultType = .resultTypeObjectIDs
//    }
}

// MARK: - Headers and Footers Structs for the List
struct userHeader: View {
    var body: some View {
        HStack {
            Image(systemName: "person")
                .font(.headline)
            Text("User profile")
                .font(.headline)
                .textCase(.none)
        }.padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
    }
}
struct userFooter: View {
    var myBool: Bool // This will receive isBiqualif bool value
    
    var body: some View {
        var myString: LocalizedStringKey = ""
        if myBool == true { //is Biqualif
            myString = "Mixed Fleet Flying on these types require a 180 day HUD proficiency."
        } else {
            myString = ""
        }
       return Text(myString).font(/*@START_MENU_TOKEN@*/.body/*@END_MENU_TOKEN@*/)
        .animation(.easeInOut)
    }
    
}

struct CurrencyRulesHeader: View {
    var body: some View {
        HStack {
            Image(systemName: "slider.horizontal.3")
            .font(.headline)
            Text("Currency rules")
                .font(.headline)
                .textCase(.none)
        }.padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
    }
}

struct CurrencyRulesFooter: View {
    var ruleSelect = 0 // This will receive the rule selection
    var body: some View {
        var myString: LocalizedStringKey = "" // Using LocalizedStringKey in order to get a returned localized string
        if ruleSelect == 0 // ICAO
        {
            myString = "All takeoffs & landings can be done in either aircraft or simulator.\n"
        } else  // AF
        {
            myString = "At least one takeoff and one landing has to be done in actual aircraft (either type if Mixed Fleet Flying).\n"
        }
        return Text(myString).font(/*@START_MENU_TOKEN@*/.body/*@END_MENU_TOKEN@*/)
            .animation(.easeInOut)
    }
}

struct displayHeader: View {
    var body: some View {
        HStack {
            Image(systemName: "slider.horizontal.below.rectangle")
                .font(.headline)
            Text("Input options")
                .font(.headline)
                .textCase(.none)
        }
    }
}
struct displayFooter: View {
    var doesAllowMultipleEvents : Bool
    var body: some View {
        VStack {
            if doesAllowMultipleEvents {
                Text("When adding an event, you will be given the option to create 1, 2 or 3 identical events at the same time.\n")
                    .animation(.easeInOut)
            } else {
                Text("\n")
            }
        }.font(.body)
        
    }
}

struct eraseAllHeader: View {
    var body: some View {
        HStack {
            Image(systemName: "trash")
            .font(.headline)
            Text("Destructive action !")
            .font(.headline)
            .textCase(.none)
        }
    }
}

// MARK: Preview struct

struct SettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        return SettingsView(appState: AppState())
    }
}

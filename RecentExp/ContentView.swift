//
//  ContentView.swift
//  RecentExp
//
//  Created by Serge Ostrowsky on 24/04/2020.
//  Copyright © 2020 Serge Ostrowsky. All rights reserved.
//

import SwiftUI
import CoreData
import Combine

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @StateObject var appState: AppState
    
    @FetchRequest(entity: Events.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Events.eventDate, ascending: false)],
                  predicate: NSPredicate(format: "isLanding = %d", false)) var fetchedTakeoffs: FetchedResults<Events>
    @FetchRequest(entity: Events.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Events.eventDate, ascending: false)],
                  predicate: NSPredicate(format: "isLanding = %d", true)) var fetchedLandings: FetchedResults<Events>

    @State var modalIsPresented = false // The "settingsView" modally presented as a sheet
    @State var screenSizeHeight: CGFloat = 0.0 // This is for the GeometryReader
    
    var dateFormatter: DateFormatter {
     let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = .medium // Nov 14, 2020
     //   formatter.dateFormat = "dd MMM yy"
     return formatter
     }
        
   @State var modalViewCaller = 0
    
    // MARK: - View modifiers :
    
    struct DisableModalDismiss: ViewModifier { // This modifier, applied to the views to be displayed, prevents the dismissal of the modal view by swiping down, thanks to the UIApplication extension in AppDelegate
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
    
    struct listsSetup: ViewModifier { // To stylize the Takeoff & landing lists
      func body(content: Content) -> some View {
        return content
            .overlay(RoundedRectangle(cornerRadius:6).stroke(Color(UIColor.systemBlue), lineWidth: 1))
            .padding([.top, .bottom])
        }
    }
    
 // MARK: - Body
    var body: some View {
            
             let stringArray = minimumEventsCheck()
             let recapString = stringArray[0]
        print("\n*************\nBody was redrawn\nrecapString is : \(recapString)**************")
             let mainString = stringArray[1]
             let detailString = stringArray[2]
             let boolString = stringArray[3]
             let isCurrent = boolString == "0" ? false : true
        
        return ZStack {
            GeometryReader { g in
                NavigationView {
                    ScrollView {
                        VStack {
                            HStack {
                                self.TakeoffStackView(inputHeight: g.size.height) // GeometryReader will be updated on rotation of iPad
                                self.LandingStackView(inputHeight: g.size.height)
                                    } // End of Takeoffs & Landings HStack
                                    .frame(maxWidth: 800)
                                    .padding(.top)
                Divider()


  // MARK: - Currency texts :
                Group {
                    Text(recapString)
                        .font(.footnote)
                        .foregroundColor(Color(UIColor.systemBlue))
                        //.padding(.bottom)
                    VStack {
                    Text(mainString)
                        .bold()
                        .lineLimit(nil) // allows unlimited lines
                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .foregroundColor(isCurrent ? Color(UIColor.systemGreen) : Color(UIColor.systemRed))
                        .padding(.bottom)
                    Text(detailString)
                        .lineLimit(nil) // allows unlimited lines
                    } // end of VStack
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(isCurrent ? Color(UIColor.systemGreen) : Color(UIColor.systemRed), lineWidth: 4))
                        .padding()
                        
                    } // End of  3rd Group
            } // END of main VStack
            .onAppear() {
                self.modalViewCaller = 0
                print("\n\n*********** Content View onAppear triggered ! ************\n")
            }
            .navigationBarTitle("Airline Pilot Currency", displayMode: .inline)
            .navigationBarItems(leading: (
                Button(action: {
                    self.modalViewCaller = 5 // SettingsView
                    self.modalIsPresented = true // setting this @State variable to true, hence changing its value, is enough to trigger the presentation of the modal view (the Sheet)
                }
                    ) {
                        Image(systemName: "gear")
                            .imageScale(.large)
                           // .font(.system(size: 30))
                     }
            ))
        } // End of ScrollView
            
        } // END of NavigationView
                .onAppear() {
                    self.appState.updateValues()
                }
            } // End of GeometryReader
        } // End of ZStack
        .sheet(isPresented: $modalIsPresented) {
            sheetContent(modalViewCaller: $modalViewCaller, appState: appState)     // << here !!
                }
        .navigationViewStyle(StackNavigationViewStyle())

    } // END of var body: some View
  // MARK: - TakeoffStackView()
    @ViewBuilder func TakeoffStackView(inputHeight: CGFloat) -> some View {
           VStack { // Takeoffs Vstack
                            VStack {
                            Text("Takeoffs")
                                .font(.system(.headline , design: .rounded))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top)
                                List {
                                    ForEach (fetchedTakeoffs, id: \.self) { item in
                                    EventRow(event: item)
                                        .contextMenu {
                                        Button(action: {
                                            self.modalViewCaller = 1 // To tell the sheet which view to display
                                            UserDefaults.standard.set(item.id?.uuidString, forKey: kactiveEventUUID)
                                            UserDefaults.standard.set(false, forKey:kIsEventLanding)
                                            self.modalIsPresented = true
                                        })
                                        {   Text("Edit entry")
                                            Image(systemName: "square.and.pencil")
                                        }
                                    } // END of ContextMenu
                                    
                                } // For Each end
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        self.managedObjectContext.delete(self.fetchedTakeoffs[index])
                                        self.saveContext()
                                    }
                                }
                                .listRowBackground(LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemGray6), Color(UIColor.systemGray2)]), startPoint: .top, endPoint: .bottom))
                               // .frame(height: rowHeight)
                            } // END of Takeoffs List
                            }
                                .frame(height: inputHeight*0.4)
                                .modifier(listsSetup())
                        
                            Spacer()
                    // Add Takeoff button
                            Button(action: {
                                self.modalViewCaller = 3 // To tell the sheet which view to display
                                UserDefaults.standard.set(false, forKey:kIsEventLanding)
                                UserDefaults.standard.set("Add Takeoff", forKey:kEventCreationTitle)
                                self.modalIsPresented = true
                                
                            } // END of "Add Takeoff" Button action
                            ) {
                                Image("addTakeoff")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 50)
                            }
                        }
    } // end of func TakeoffStackView
    
  // MARK: - LandingStackView()
      @ViewBuilder func LandingStackView(inputHeight: CGFloat) -> some View {
        VStack { // Landings Vstack
                                VStack {
                                Text("Landings")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .font(.system(.headline , design: .rounded))
                                    .padding(.top)
                                List {
                                    
                                    ForEach (fetchedLandings, id: \.self) { item in
        //                               HStack {
        //                                   Text(item.airportName ?? "")
        //                                   Text(self.dateFormatter.string(from: item.eventDate!) )
        //                               }
                                        EventRow(event: item)
                                        .contextMenu {
                                            
                                        Button(action: {
                                            self.modalViewCaller = 2 // To tell the sheet which view to display
                                            UserDefaults.standard.set(item.id?.uuidString, forKey: kactiveEventUUID)
                                            UserDefaults.standard.set(true, forKey:kIsEventLanding)
                                            self.modalIsPresented = true
                                        })
                                        {   Text("Edit entry")
                                            Image(systemName: "square.and.pencil")
                                        }
                                    } // END of ContextMenu
                                } // For Each end
                                    .onDelete { indexSet in
                                        for index in indexSet {
                                            self.managedObjectContext.delete(self.fetchedLandings[index])
                                            self.saveContext()
                                        }
                                    }
                                    .listRowBackground(LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemGray6), Color(UIColor.systemGray2)]), startPoint: .top, endPoint: .bottom))
                                } // END of Landings List
                                }
                                    .frame(height: inputHeight*0.4)
                                    .modifier(listsSetup())
                               // .padding(.trailing)
                                Spacer()
                                Button(action: {
                                    self.modalViewCaller = 4 // To tell the sheet which view to display
                                    UserDefaults.standard.set("Add Landing", forKey:kEventCreationTitle)
                                    UserDefaults.standard.set(true, forKey:kIsEventLanding)

                                    self.modalIsPresented = true
                                })// END of "Add Takeoff" Button action
                                {
                                    Image("addLanding")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 50)
                                }
                            } // End of Landings VStack
    } // end of func LandingStackView
    
  // MARK: - struct sheetContent()
    struct sheetContent: View {
        @Environment(\.managedObjectContext) var managedObjectContext
        @Binding var modalViewCaller: Int // Binding to the @State modalViewCaller variable from ContentView
        @ObservedObject var appState: AppState // Binding to the appState in main
        
        var body: some View {
          if modalViewCaller == 1 {
            EditEventView().environment(\.managedObjectContext, self.managedObjectContext) // Due to a bug in SwiftUI, we need to pass the managedObjectContext
                    .modifier(DisableModalDismiss(disabled: true)) // This prevents the dismissal of the modal view by swiping down, thanks to the UIApplication extension in AppDelegate
                    .navigationViewStyle(StackNavigationViewStyle())
                    .onDisappear { self.modalViewCaller = 0 }
            } else if modalViewCaller == 2 {
                    EditEventView().environment(\.managedObjectContext, self.managedObjectContext)
                    .modifier(DisableModalDismiss(disabled: true))
                    .navigationViewStyle(StackNavigationViewStyle())
                    .onDisappear { self.modalViewCaller = 0 }
            } else if modalViewCaller == 3 {
                CreateEventView().environment(\.managedObjectContext, self.managedObjectContext)
                .modifier(DisableModalDismiss(disabled: true))
                .navigationViewStyle(StackNavigationViewStyle())
                .onDisappear { self.modalViewCaller = 0 }
            } else if modalViewCaller == 4 {
                CreateEventView().environment(\.managedObjectContext, self.managedObjectContext)
                .modifier(DisableModalDismiss(disabled: true))
                .navigationViewStyle(StackNavigationViewStyle())
            } else if modalViewCaller == 5 {
                SettingsView(appState: appState).environment(\.managedObjectContext, self.managedObjectContext)
                .modifier(DisableModalDismiss(disabled: true))
                .navigationViewStyle(StackNavigationViewStyle())
                }
        }
    } // END of func sheetContent
    
  // MARK: - saveContext()
    private func saveContext() {
        
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
    
    // MARK: - minimumEventsCheck()
  func minimumEventsCheck() -> [String] { // minimumNumberOfEventsCheck
        
    //@ObservedObject var appState : AppState // Binding
        var isCurrent = "0"
        let reqNbEvents = 3
        var aString = "" // The currency string
        var bString = "" // The details string
        var recapString = "" // The recap string
        let refDate = Date()
        let date90Prior = refDate.addingTimeInterval(-7776000)
        var myArray = ["","","",""]
    
    
    // Array of Takeoffs in last 90 days from ref date :
    let last90daysToffsArray = fetchedTakeoffs.filter { $0.eventDate! >= date90Prior }
    
    // Array of Landings in last 90 days from ref date :
    let last90daysLandingsArray = fetchedLandings.filter { $0.eventDate! >= date90Prior }
    
        // If user has not launched the settings view, we display an Initial text :
    if UserDefaults.standard.bool(forKey: kinitialInstrViewed) == false
    {
        recapString = "No settings yet"
        aString = "Please visit settings"
        bString = "\nThe app needs to know a little bit about your pilot profile and your display preferences."
        isCurrent = "0"
    }
    else // User HAS visited the settings view
    {
        // We create the recap string :
    if UserDefaults.standard.integer(forKey: krulesSelection) == 0 { // ICAO
        if UserDefaults.standard.bool(forKey: kbiQualif) {
            if UserDefaults.standard.integer(forKey: kdualTypeSelection) == 0
            {
                recapString = "330 / 350    ICAO rules    180d HUD req"
            } else
            {
                recapString = "777 / 787    ICAO rules    180d HUD req"
            }
        } else // Not biQualif
        {
            recapString = "Single type    ICAO rules"
        }
    } else if UserDefaults.standard.integer(forKey: krulesSelection) == 1 { // AF Rules
        if UserDefaults.standard.bool(forKey: kbiQualif) {
            if UserDefaults.standard.integer(forKey: kdualTypeSelection) == 0
            {
                recapString = "330 / 350    AF rules    180d HUD req"
            } else
            {
                recapString = "777 / 787    AF rules    180d HUD req"
            }
        } else // Not biQualif
        {
            recapString = "Single type    AF rules"
        }
    }
        // We display the rest :
        
        if last90daysToffsArray.count < reqNbEvents && last90daysLandingsArray.count < reqNbEvents {
            aString = "NOT CURRENT"
            bString = "You are missing :\n\(reqNbEvents - last90daysToffsArray.count) takeoff(s) and\n\(reqNbEvents - last90daysLandingsArray.count) landing(s) in the last 90 days."
            isCurrent = "0"
        } else
        if last90daysToffsArray.count < reqNbEvents && last90daysLandingsArray.count >= reqNbEvents {
            aString = "NOT CURRENT"
            bString = "Not enough takeoffs to be current.\nMissing \(reqNbEvents - last90daysToffsArray.count) takeoff(s) in the last 90 days."
            isCurrent = "0"
        } else if last90daysToffsArray.count >= reqNbEvents && last90daysLandingsArray.count < reqNbEvents {
            aString = "NOT CURRENT"
            bString = "Not enough landings to be current.\nMissing \(reqNbEvents - last90daysLandingsArray.count) landing(s) in the last 90 days."
                isCurrent = "0"
        }
            else    // We have enough events in both arrays to proceed
            {
                aString = currencyDetermination()[0]
                bString = currencyDetermination()[1]
                isCurrent = currencyDetermination()[2]
        }
    }
    
    myArray = [recapString, aString, bString, isCurrent]
    
            return myArray
    } // End of func currencyText() -> String
    
    // MARK: - func currencyDetermination()
  func currencyDetermination() -> [String] {
        
        var isCurrent = "0"
     //   let reqNbEvents = 3
        var currencyRules = 0 // 0 is ICAO, 1 is ICAO biQualif, 2 is AF mono, 3 is AF biQualif
        var aString = ""
        var bString = ""
        var limitingEventString = ""
        let refDate = Date()
        let date90Prior = refDate.addingTimeInterval(-7776000)
        let date180Prior = refDate.addingTimeInterval(-7776000*2)
        var myArray2 = ["","","",""]
    
    // Array of Takeoffs in last 90 days from ref date :
    let last90daysToffsArray = fetchedTakeoffs.filter { $0.eventDate! >= date90Prior }
    
    // Array of Landings in last 90 days from ref date :
    let last90daysLandingsArray = fetchedLandings.filter { $0.eventDate! >= date90Prior }
        
        // We define the currencyRules :
    if UserDefaults.standard.integer(forKey: krulesSelection) == 0 { // ICAO
        if UserDefaults.standard.bool(forKey: kbiQualif)
        {
            currencyRules = 1
        } else // Not biQualif
        {
            currencyRules = 0
        }
    } else if UserDefaults.standard.integer(forKey: krulesSelection) == 1 { // AF Rules
        if UserDefaults.standard.bool(forKey: kbiQualif)
        {
            currencyRules = 3
        } else // Not biQualif
        {
            currencyRules = 2
        }
    }
    
    let toffScan = scanArray(array: last90daysToffsArray, rule: currencyRules)
  //  print("////////////////////////\n\n Result of Takeoff scan :\nReal events : \(toffScan.0)\nType 1 events : \(toffScan.1)\nType 2 events : \(toffScan.2)\nlimiting date : \(dateFormatter.string(from: toffScan.3))\nlatest type 1 event : \(dateFormatter.string(from: toffScan.4))\nlatest type 2 event : \(dateFormatter.string(from: toffScan.5))\nmeets Requirements : \(toffScan.6)\nnumber of takeoffs in last 90 days : \(toffScan.7)")
    
    let ldgScan = scanArray(array: last90daysLandingsArray, rule: currencyRules)
 //   print("////////////////////////\n\n Result of landing scan :\nReal events : \(ldgScan.0)\nType 1 events : \(ldgScan.1)\nType 2 events : \(ldgScan.2)\nlimiting date : \(dateFormatter.string(from: ldgScan.3))\nlatest type 1 event : \(dateFormatter.string(from: ldgScan.4))\nlatest type 2 event : \(dateFormatter.string(from: ldgScan.5))\nmeets Requirements : \(ldgScan.6)\nnumber of landings in last 90 days : \(ldgScan.7)")
    
    let limitingDate: Date = toffScan.limitingDate >= ldgScan.limitingDate ? ldgScan.limitingDate : toffScan.limitingDate // We grab the oldest of both dates
    
    let currencydate = limitingDate.addingTimeInterval(7776000) // The currency date is the limiting date + 90 days
    
    let daysDiff = Calendar.current.dateComponents([.day], from: refDate, to: currencydate).day ?? 0
                
        if Calendar.current.isDate(toffScan.limitingDate, inSameDayAs: ldgScan.limitingDate) {
            limitingEventString = "either a takeoff or a landing"
        } else if toffScan.limitingDate > ldgScan.limitingDate {
            limitingEventString = "a LANDING"
        } else {
            limitingEventString = "a TAKEOFF"
        }
    
    // MARK: ICAO mono or bi -
    
    if currencyRules == 0 || currencyRules == 1 { // ICAO mono or bi
   
        if Calendar.current.isDate(currencydate, inSameDayAs: refDate) { // The currency date is the same day as the ref date
            aString = "Current until today."
            isCurrent = "1"
        } else if currencydate > refDate { // current until a future date
            
            aString = "Current until \(dateFormatter.string(from: currencydate)) - \(daysDiff == 1 ? "\(daysDiff) day -" : "\(daysDiff) days -")"
                    isCurrent = "1"
            
                } else { // Not current
                    aString = "Not Current since \(dateFormatter.string(from: currencydate)), \(daysDiff == 1 ? "\(daysDiff) day ago." : "\(daysDiff) days ago.")"
                    isCurrent = "0"
                }
        if currencyRules == 1 { // ICAO bi, we have to check for HUD currency
            if self.latestType2Event().1 { // a type 2 event was found
                // We check to see if 180 days have not passed since :
                if date180Prior > latestType2Event().0 {
                    isCurrent = "0"
                    aString = "Not current due to overdue HUD operations."
                    bString = "On the reference date, you will not have used the HUD in over 180 days "
                } else if isCurrent == "1"
                {
                    let hudDaysDiff = Calendar.current.dateComponents([.day], from: refDate, to: latestType2Event().0).day ?? 0
                    bString = "Limiting event was \(limitingEventString), on \(dateFormatter.string(from: limitingDate)).\nLatest HUD use was on \(dateFormatter.string(from: latestType2Event().0)), you have to use it again within the next \(180+hudDaysDiff == 1 ? "1 day." : "\(180+hudDaysDiff) days." )"
                } else
                {
                    bString = "Seems like a sim session is in order."
                }
            }
        } else
        { // ICAO mono
                        if isCurrent == "1" {
            bString = "Limiting event was \(limitingEventString), on \(dateFormatter.string(from: limitingDate))."
            } else
            {
                bString = "Seems like a sim session is in order."
            }
        }
              
    } // End of if currencyRules == 0 || currencyRules == 1
        
    // MARK: - AF mono
        
    else if currencyRules == 2 {// AF Rules mono : we need at least one takeoff and one landing in real aircraft.
        
        if toffScan.metReq && ldgScan.metReq // 3 events with at least one real for both toffs and ldgs
        {
            if Calendar.current.isDate(currencydate, inSameDayAs: refDate) { // The currency date is the same day as the ref date
                aString = "Current until today."
                isCurrent = "1"
            } else if currencydate > refDate { // current until a future date
                aString = "Current until \(dateFormatter.string(from: currencydate)), \(daysDiff == 1 ? "1 day from now." : "\(daysDiff) days from now.")"
                isCurrent = "1"
                    } else // Not current
                    {
                        aString = "Not Current since \(dateFormatter.string(from: currencydate)), \(daysDiff == 1 ? "1 day ago." : "\(daysDiff) days ago.")"
                        isCurrent = "0"
                    }
            
            if isCurrent == "1" {
            bString = "Limiting event was \(limitingEventString), on \(dateFormatter.string(from: limitingDate))."
            } else
            {
                bString = "Seems like a sim session is in order."
            }
            
        }
        else if !toffScan.metReq && !ldgScan.metReq // no real for both toffs and ldgs
        {
            aString = "NOT CURRENT."
            bString = "No real takeoff and landing in the last 90 days.\nA sim session is in order."
            isCurrent = "0"
        }
        else if toffScan.metReq && !ldgScan.metReq // no real landings
        {
            aString = "NOT CURRENT."
            bString = "No real landing in the last 90 days.\nA sim session is in order."
            isCurrent = "0"
        }
        else if !toffScan.metReq && ldgScan.metReq // no real toffs
        {
            aString = "NOT CURRENT."
            bString = "No real takeoff in the last 90 days.\nA sim session is in order."
            isCurrent = "0"
        }

    } // End of if currencyRules == 2
        
   // MARK: - AF biQualif
        
    else if currencyRules == 3 {// AF Rules bi : we need at least one takeoff and one landing in real aircraft AND less than 60 days between takeoff and landing on same type
            
            if toffScan.metReq && ldgScan.metReq // 3 events with at least one real for both toffs and ldgs
            {
                if Calendar.current.isDate(currencydate, inSameDayAs: refDate) { // The currency date is the same day as the ref date
                    aString = "Current until today."
                    isCurrent = "1"
                } else if currencydate > refDate { // current until a future date
                    aString = "Current until \(dateFormatter.string(from: currencydate)), \(daysDiff == 1 ? "in 1 day." : "in \(daysDiff) days.")"
                    isCurrent = "1"
                        }
                else { // Not current
                            aString = "Not Current since \(dateFormatter.string(from: currencydate)), \(daysDiff == 1 ? "\(daysDiff) day ago." : "\(daysDiff) days ago.")"
                            isCurrent = "0"
                        }
    // MARK: 60 days compliance :
                
        if isCurrent == "1"
        {
            
            // needed in case the 60 days limit renders the user not current for both takeoofs AND landings, i.e NOT CURRENT AT ALL :
            var notCurrentTakeoffs = false
            var notCurrentLandings = false
            
            var btString = "" // takeoff part of the bString
            var blString = "" // landing part of the bString
            var limitingEventAlreadyDisplayed60 = false
            
            // MARK: takeoff 60 days checks : -
            
        let t1found = sixtyDaysCheck(type: 1, eventDate: toffScan.lastType1Event).found
        let t2found = sixtyDaysCheck(type: 2, eventDate: toffScan.lastType2Event).found
        let t1delta = sixtyDaysCheck(type: 1, eventDate: toffScan.lastType1Event).deltaToRef
        let t2delta = sixtyDaysCheck(type: 2, eventDate: toffScan.lastType2Event).deltaToRef
        let dualTypeSel = UserDefaults.standard.integer(forKey: kdualTypeSelection)
                    
            if t1found // t1 was found within the last 60 days
            { // We check to see if a type 2 event was found :
                if t2found // both types were within the last 60 days
                {
                    if dualTypeSel == 0 // 330/350
                    {
                        btString = "Limiting event was \(limitingEventString), on \(dateFormatter.string(from: limitingDate)).\nNext takeoff in A330 within \(60 - t1delta == 1 ? "1 day." : "\(60 - t1delta) days.")\nNext takeoff in A350 within \(60 - t2delta == 1 ? "1 day." : "\(60 - t2delta) days.")"
                        limitingEventAlreadyDisplayed60 = true
                    } else if dualTypeSel == 1 // 777/787
                    {
                        btString = "Limiting event was \(limitingEventString), on \(dateFormatter.string(from: limitingDate)).\nNext takeoff in 777 within \(60 - t1delta == 1 ? "1 day." : "\(60 - t1delta) days.")\nNext takeoff in 787 within \(60 - t2delta == 1 ? "1 day." : "\(60 - t2delta) days.")"
                        limitingEventAlreadyDisplayed60 = true
                    }
                } else // t1 was found in last 60 days but not t2
                {
                    if dualTypeSel == 0 // 330/350
                    {
                        btString = "❗️NOT CURRENT takeoff A350❗️You needed an A350 takeoff within the last 60 days.\nYou can still takeoff in an A330 for \(60 - t1delta == 1 ? "1 day." : "\(60 - t1delta) days.")"
                    } else if dualTypeSel == 1 // 777/787
                    {
                        btString = "❗️NOT CURRENT takeoff 787❗️You needed a 787 takeoff within the last 60 days.\nYou can still takeoff in a 777 for \(60 - t1delta == 1 ? "1 day." : "\(60 - t1delta) days.")"
                    }
                }
            } else // t1 was not found within the last 60 days
            { // We check to see if a type 2 event was found :
                if t2found // t1 not found, t2 found
                {
                    if dualTypeSel == 0 // 330/350
                    {
                        btString = "❗️NOT CURRENT takeoff A330❗️You needed an A330 takeoff within the last 60 days.\nYou can still takeoff in an A350 for \(60 - t2delta == 1 ? "1 day." : "\(60 - t2delta) days.")"
                    } else if dualTypeSel == 1 // 777/787
                    {
                        btString = "❗️NOT CURRENT takeoff 777❗️You needed a 777 takeoff within the last 60 days.\nYou can still takeoff in a 787 for \(60 - t2delta == 1 ? "1 day." : "\(60 - t2delta) days.")"
                    }
                } else // t1 and t2 were not found in last 60 days
                    {
                        btString = "❗️ONLY CURRENT for landings❗️You logged no takeoffs on either type within the last 60 days"
                        notCurrentTakeoffs = true
                    }
            } // END of t1 not found
             
        // MARK: landings 60 days checks : -
            
            let t1lfound = sixtyDaysCheck(type: 1, eventDate: ldgScan.lastType1Event).found
            let t2lfound = sixtyDaysCheck(type: 2, eventDate: ldgScan.lastType2Event).found
            let t1ldelta = sixtyDaysCheck(type: 1, eventDate: ldgScan.lastType1Event).deltaToRef
            let t2ldelta = sixtyDaysCheck(type: 2, eventDate: ldgScan.lastType2Event).deltaToRef
                        
                if t1lfound // t1 was found within the last 60 days
                { // We check to see if a type 2 event was found :
                    if t2lfound // both types were within the last 60 days
                    {
                        if dualTypeSel == 0 // 330/350
                        {
                            if limitingEventAlreadyDisplayed60 == true
                            {
                                blString = "\nNext landing in A330 within \(60 - t1ldelta == 1 ? "1 day." : "\(60 - t1ldelta) days.")\nNext landing in A350 within \(60 - t1ldelta == 1 ? "1 day." : "\(60 - t1ldelta) days.")"
                            } else
                            {
                                blString = "Limiting event was \(limitingEventString), on \(dateFormatter.string(from: limitingDate)).\nNext landing in A330 within \(60 - t1ldelta == 1 ? "1 day." : "\(60 - t1ldelta) days.")\nNext landing in A350 within \(60 - t1ldelta == 1 ? "1 day." : "\(60 - t1ldelta) days.")"
                            }
                            
                        } else if dualTypeSel == 1 // 777/787
                        {
                            if limitingEventAlreadyDisplayed60 == true {
                                blString = "\nNext landing in 777 within \(60 - t1ldelta == 1 ? "1 day." : "\(60 - t1ldelta) days.")\nNext landing in 787 within \(60 - t1ldelta == 1 ? "1 day." : "\(60 - t1ldelta) days.")"
                            } else {
                                blString = "Limiting event was \(limitingEventString), on \(dateFormatter.string(from: limitingDate)).\nNext landing in 777 within \(60 - t1ldelta == 1 ? "1 day." : "\(60 - t1ldelta) days.")\nNext landing in 787 within \(60 - t1ldelta == 1 ? "1 day." : "\(60 - t1ldelta) days.")"
                            }
                            
                        }
                    } else // t1 was found in last 60 days but not t2
                    {
                        if dualTypeSel == 0 // 330/350
                        {
                            blString = "❗️NOT CURRENT landing A350❗️You needed an A350 landing within the last 60 days.\nYou can still land an A330 for \(60 - t1ldelta == 1 ? "1 day." : "\(60 - t1ldelta) days.")"
                        } else if dualTypeSel == 1 // 777/787
                        {
                            blString = "❗️NOT CURRENT landing 787❗️You needed a 787 landing within the last 60 days.\nYou can still land a 777 for \(60 - t1ldelta == 1 ? "1 day." : "\(60 - t1ldelta) days.")"
                        }
                    }
                } else // t1 was not found within the last 60 days
                { // We check to see if a type 2 event was found :
                    if t2lfound // t1 not found, t2 found
                    {
                        if dualTypeSel == 0 // 330/350
                        {
                            blString = "❗️NOT CURRENT landing A330❗️You needed an A330 landing within the last 60 days.\nYou can still land an A350 for \(60 - t2ldelta == 1 ? "1 day." : "\(60 - t2ldelta) days.")"
                        } else if dualTypeSel == 1 // 777/787
                        {
                            blString = "❗️NOT CURRENT landing 777❗️You needed a 777 landing within the last 60 days.\nYou can still land a 787 for \(60 - t2ldelta == 1 ? "1 day." : "\(60 - t2ldelta) days.")"
                        }
                    } else // t1 and t2 were not found in last 60 days
                        {
                            blString = "❗️ONLY CURRENT for takeoffs❗️You logged no landings on either type within the last 60 days"
                            notCurrentLandings = true
                        }
                } // END of t1 not found
            
            if notCurrentLandings && notCurrentTakeoffs // The user can't land or takeoff even with the appropriate numbers of events, due to the 60 days limit !
            {
                aString = "NOT CURRENT"
                bString = "No takeoffs and landings in either type in the last 60 days."
                isCurrent = "0"
            } else
            {
                bString = "\(btString)\n\(blString)"
            }
        } // END of if isCurrent
            else
            {
                bString = "Seems like a sim session is in order."
            }

            } // End of if toffScan.metReq && ldgScan.metReq
            else if !toffScan.metReq && !ldgScan.metReq // no real for both toffs and ldgs
            {
                aString = "NOT CURRENT."
                bString = "No real takeoffs and landing in the last 90 days.\nA sim session is in order."
                isCurrent = "0"
            }
            else if toffScan.metReq && !ldgScan.metReq // no real landings
            {
                aString = "NOT CURRENT."
                bString = "No real landings in the last 90 days.\nA sim session is in order."
                isCurrent = "0"
            }
            else if !toffScan.metReq && ldgScan.metReq // no real toffs
            {
                aString = "NOT CURRENT."
                bString = "No real takeoffs in the last 90 days.\nA sim session is in order."
                isCurrent = "0"
            }

        } // End of if currencyRules == 3
  
        myArray2 = [aString, bString, isCurrent]
    
        return myArray2
    }

  // MARK: - func scanArray()
  func scanArray(array: [Events], rule: Int) -> (real: Int,type1: Int,type2: Int, limitingDate: Date, lastType1Event: Date, lastType2Event: Date, metReq: Bool, arrayCount: Int) {
    var r = 0, t1 = 0, t2 = 0, nbOfEvents = 0
    let c = array.count
    var oldestLimitingDate = Date(timeIntervalSince1970: 0) // a distant constant date to be compared to later
    var incrementalDate = Date()
    var earliestType1Event = Date(timeIntervalSince1970: 0) // a distant constant date to be compared to later
    var earliestType2Event = Date(timeIntervalSince1970: 0) // a distant constant date to be compared to later
    var metRequirements = false
        
    for index in 0..<c {
        
        if array[index].isSimulator == false { r += 1}
        if array[index].aircraftType == 1 { t1 += 1}
        if array[index].aircraftType == 2 { t2 += 1}
        
        nbOfEvents += 1
        incrementalDate = array[index].eventDate ?? Date()
        
        switch rule { // Switch 1
        case 0: // ICAO mono
            if nbOfEvents == 3 {oldestLimitingDate = incrementalDate
                metRequirements = true } // After 3 events, we have found our limiting date
        case 1: // ICAO bi (180 days HUB req)
            if nbOfEvents == 3 {oldestLimitingDate = incrementalDate
            metRequirements = true } // After 3 events, we have found our limiting date
            if t1 >= 1 {
                if earliestType1Event == Date(timeIntervalSince1970: 0) { // We have not yet encountered a t1
                    earliestType1Event = incrementalDate}
            }
            if t2 >= 1 {
                if earliestType2Event == Date(timeIntervalSince1970: 0) { // We have not yet encountered a t2
                    earliestType2Event = incrementalDate}
            }
        case 2: // AF rules mono
            if nbOfEvents >= 3 && r >= 1 { // We have at least 3 events, with 1 real
                if oldestLimitingDate == Date(timeIntervalSince1970: 0) {
                    oldestLimitingDate = incrementalDate
                }
                metRequirements = true
            }
        case 3: // AF rules bi (60 days between t1s and t2s)
            if nbOfEvents >= 3 && r >= 1 { // We have at least 3 events, with 1 real
                if oldestLimitingDate == Date(timeIntervalSince1970: 0) {
                    oldestLimitingDate = incrementalDate
                }
                metRequirements = true
            }
            if t1 >= 1 {
                if earliestType1Event == Date(timeIntervalSince1970: 0) { // We have not yet encountered a t1
                    earliestType1Event = incrementalDate}
            }
            if t2 >= 1 {
                if earliestType2Event == Date(timeIntervalSince1970: 0) { // We have not yet encountered a t2
                    earliestType2Event = incrementalDate}
                
            }
        default :
            print("This set of rules is unknown")
        } // End of Switch 1

//        print("**************\nInside scan loop of Landings array :\(array[index].isLanding)\nChecking event # \(index) with rule set # \(rule)\nnbOf events = \(nbOfEvents), real events: \(r), type 1: \(t1), type 2: \(t2)\nOldest limiting date : \(dateFormatter.string(from: oldestLimitingDate))\nmetRequirements: \(metRequirements)\n")
        
    } // End of for loop
    
    return (r, t1, t2, oldestLimitingDate, earliestType1Event, earliestType2Event, metRequirements, c)
} //END of func scanArray

  // MARK: - func latestType2Event()
    func latestType2Event() -> (type2EventDate: Date, dateWasFound: Bool) { // This is only for HUD currency
        
        var t2T = 0, t2L = 0
        let cT = fetchedTakeoffs.count
        let cL = fetchedLandings.count
        
        var wasFound = false
        
        var latestType2ToffDate = Date(timeIntervalSince1970: 0) // a distant constant date to be compared to later
        var latestType2LandingDate = Date(timeIntervalSince1970: 0) // a distant constant date to be compared to later
        var qualifyingType2EventDate = Date(timeIntervalSince1970: 0) // a distant constant date to be compared to later
            
        for index in 0..<cT {
            
            if fetchedTakeoffs[index].aircraftType == 2 {
                t2T += 1
                latestType2ToffDate = fetchedTakeoffs[index].eventDate ?? Date()
                wasFound = true
            }
            if t2T == 1 {
                print("latest type 2 takeoff was on \(dateFormatter.string(from: latestType2ToffDate))")
                break
            }
        } //End of for index in 0..<cT loop
            
            for index in 0..<cL {
                
                if fetchedLandings[index].aircraftType == 2 {
                    t2L += 1
                    latestType2LandingDate = fetchedLandings[index].eventDate ?? Date()
                    wasFound = true
                }
                if t2L == 1 {
                    print("latest type 2 landing was on \(dateFormatter.string(from: latestType2LandingDate))")
                    break
                }
        } // End of for index in 0..<cL loop
    
        if wasFound {
            qualifyingType2EventDate = latestType2ToffDate >= latestType2LandingDate ? latestType2ToffDate : latestType2LandingDate
        }
        
        return (qualifyingType2EventDate, wasFound)
    } // END of func latestType2Event
    
  // MARK: - func sixtyDaysCheck()
    func sixtyDaysCheck(type: Int, eventDate: Date) -> (deltaToRef: Int, found: Bool) {
        
        var wasFound = false
        let refDate = Date()
        
        let delta = Calendar.current.dateComponents([.day], from: eventDate, to: refDate).day ?? 0
        
        if eventDate == Date(timeIntervalSince1970: 0) // the event was never found in the last 90 days)
        {
            wasFound = false
        } else
        {
            wasFound = delta < 60 ? true : false
        }
        return (delta, wasFound)
    } // ENF of func sixtyDaysCheck
    
} // END of struct ContentView

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return ContentView(appState: AppState())
            .environment(\.managedObjectContext, context)
        
    }
}



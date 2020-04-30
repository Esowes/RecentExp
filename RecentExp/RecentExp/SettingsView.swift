//
//  SettingsView.swift
//  RecentExp
//
//  Created by Serge Ostrowsky on 07/04/2020.
//  Copyright © 2020 Serge Ostrowsky. All rights reserved.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode // in order to dismiss the Sheet
    
    @State private var isBiQualif = UserDefaults.standard.bool(forKey: kbiQualif)
    @State private var typeOneName = ""
    @State private var typeTwoName = ""
    
    @State private var isAlertVisible = false
    
//    struct textFieldStyle: ViewModifier {
//      func body(content: Content) -> some View {
//        return content
//          .foregroundColor(Color.white)
//          .font(Font.custom("Arial Rounded MT Bold", size: 18))
//      }
//    }
    
    struct textFieldOptions: ViewModifier {
      func body(content: Content) -> some View {
        return content
          .padding(.horizontal)
          .border(/*@START_MENU_TOKEN@*/Color.blue/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
          .keyboardType(/*@START_MENU_TOKEN@*/.numberPad/*@END_MENU_TOKEN@*/)
      }
    }
    
    var body: some View {
        NavigationView {
            Form { // limited to 10 items
                    Toggle(isOn: $isBiQualif) {
                       Text("Dual type rated ?")
                    }
                    .onReceive([self.isBiQualif].publisher.first()) { (value) in self.saveDefaults() }
                    .padding(.horizontal)
                if isBiQualif {
                    HStack {
                        Text("Type 1 : ")
                        TextField((UserDefaults.standard.string(forKey: ktype1) ?? ""), text: $typeOneName)
                        .modifier(textFieldOptions())
                            .disabled(typeOneName.count > (2)) // this will limit the characters to 3
                        Button(action: {
                            self.typeOneName = ""
                        }) {
                            Image(systemName: "clear")
                            }
                    } // END of Hstack type 1
                }
                if isBiQualif {
                    HStack {
                        Text("Type 2 : ")
                        TextField((UserDefaults.standard.string(forKey: ktype2) ?? ""), text: $typeTwoName)
                            .modifier(textFieldOptions())
                        .disabled(typeTwoName.count > 2)
                        Button(action: {
                            self.typeTwoName = ""
                        }) {
                            Image(systemName: "clear")
                            }
                    } // END of Hstack type 2
                }
                
            } // End of Form
            .navigationBarItems(
                leading:
                Button("Done") {
                    
                    if self.isBiQualif {
                        if self.typeOneName.count == 0 || self.typeTwoName.count == 0 {
                            self.isAlertVisible = true
                        } else {
                            self.presentationMode.wrappedValue.dismiss() // This dismisses the view
                        }
                    } else {
                        self.presentationMode.wrappedValue.dismiss() // This dismisses the view
                    }
                }
                .alert(isPresented: $isAlertVisible) { () -> Alert in
                  return Alert(title: Text("Something is missing"), message: Text(
                    "Please review all fields and make sure you have filled the information"
                  ), dismissButton: .default(Text("Done")) {
                  })
                }
                
            )
        } // END of Navigation view
        .navigationBarTitle("Settings")
        
    } // END of some View
    
    func saveDefaults() {
        UserDefaults.standard.set(isBiQualif, forKey: kbiQualif)
        UserDefaults.standard.set(typeOneName, forKey: ktype1)
        UserDefaults.standard.set(typeTwoName, forKey: ktype2)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return SettingsView().environment(\.managedObjectContext, context)
    }
}

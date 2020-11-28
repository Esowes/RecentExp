//
//  HelpView.swift
//  RecentExp
//
//  Created by Serge Ostrowsky on 26/11/2020.
//  Copyright © 2020 Serge Ostrowsky. All rights reserved.
//

import SwiftUI
import CoreData
import UIKit
import Combine

struct HelpView: View {
    
    @Environment(\.presentationMode) var presentationMode // in order to dismiss the Sheet
    
    var body: some View {
        NavigationView {
            Group {
                ScrollView {
                    VStack {
                        Text("This will be the help page")
                            .padding()
                    }// End of VStack
                } // End of ScrollView
            } // End of Group
            .navigationBarItems(
                trailing:
                Button("Done") {
                        self.presentationMode.wrappedValue.dismiss() // This dismisses the view
                }
            )
            .navigationBarTitle("HOW TO - v. \(UIApplication.appVersion ?? "" )", displayMode: .inline) // appVersion is a var created in the AppDelegate in the extension
        }// End of NavigationView
    } // End of var body: some View
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}

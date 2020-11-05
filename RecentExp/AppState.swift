//
//  AppState.swift
//  RecentExp
//
//  Created by Serge Ostrowsky on 17/05/2020.
//  Copyright © 2020 Serge Ostrowsky. All rights reserved.
//

import Foundation
import SwiftUI

class AppState: ObservableObject {

    @Published var isBiqualif: Bool = UserDefaults.standard.bool(forKey: kbiQualif)
    @Published var dualTypeSelection: Int = UserDefaults.standard.integer(forKey: kdualTypeSelection)
    @Published var rulesSelection: Int = UserDefaults.standard.integer(forKey: krulesSelection)
    @Published var isTRI: Bool = UserDefaults.standard.bool(forKey: kisInstructor)
    @Published var isFltNbDisplayed: Bool = UserDefaults.standard.bool(forKey: kflightNumberDisplayed)
    @Published var isairportDisplayed: Bool = UserDefaults.standard.bool(forKey: kairportNameDisplayed)
    @Published var wasAppStateChanged: Bool = UserDefaults.standard.bool(forKey: kappStateChanged)
    
    
    func updateValues() {

        self.isBiqualif = UserDefaults.standard.bool(forKey: kbiQualif)
        self.dualTypeSelection = UserDefaults.standard.integer(forKey: kdualTypeSelection)
        self.rulesSelection = UserDefaults.standard.integer(forKey: krulesSelection)
        self.isTRI = UserDefaults.standard.bool(forKey: kisInstructor)
        self.isFltNbDisplayed = UserDefaults.standard.bool(forKey: kflightNumberDisplayed)
        self.isairportDisplayed = UserDefaults.standard.bool(forKey: kairportNameDisplayed)
        
        
        UserDefaults.standard.set(true, forKey: kappStateChanged)
        self.wasAppStateChanged = UserDefaults.standard.bool(forKey: kappStateChanged)
        
        NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
    }
    
}

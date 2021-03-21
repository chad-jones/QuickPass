//
//  SettingsStore.swift
//  QuickPass
//
//  Created by Chad Jones on 3/18/21.
//

import Foundation
import Cocoa

class SettingsStore: ObservableObject {
    
    // 
    @Published var persistMatches = UserDefaults.standard.bool(forKey: "persistMatches"){
        didSet {
            UserDefaults.standard.set(self.persistMatches, forKey: "persistMatches")
            self.appDelegate().setPersistMatchesOption(option: self.persistMatches)
        }
    }

    @Published var persistPosition = UserDefaults.standard.bool(forKey: "persistPosition"){
        didSet {
            UserDefaults.standard.set(self.persistPosition, forKey: "persistPosition")
            self.appDelegate().setPersistPositionOption(option: self.persistPosition)
        }
    }
    
    func appDelegate() -> AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
}

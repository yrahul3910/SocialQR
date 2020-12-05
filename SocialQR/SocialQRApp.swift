//
//  SocialQRApp.swift
//  SocialQR
//
//  Created by Rahul Yedida on 11/16/20.
//

import SwiftUI

// From https://stackoverflow.com/a/62067616
class ObservableBool: ObservableObject {
    @Published var value: Bool = true
    
    func setTrue() {
        self.value = true
    }
    
    func setFalse() {
        self.value = false
    }
}

@main
struct SocialQRApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView().environmentObject(ObservableBool())
        }
    }
}

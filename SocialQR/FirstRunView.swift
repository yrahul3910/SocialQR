//
//  FirstRunView.swift
//  SocialQR
//
//  Created by Rahul Yedida on 12/5/20.
//

import SwiftUI

struct FirstRunView: View {
    @EnvironmentObject var firstRun: ObservableBool
    
    var body: some View {
        Button(action: { self.firstRun.setFalse() }) {
            Text("Hello World!")
        }
    }
}

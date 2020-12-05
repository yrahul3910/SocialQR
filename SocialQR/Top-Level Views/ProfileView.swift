//
//  ProfileView.swift
//  SocialQR
//
//  Created by Rahul Yedida on 11/17/20.
//

import SwiftUI

struct ProfileView: View {
    private let settingsManager = SettingsManager()
    
    var body: some View {
        let friendCount: Int = settingsManager.getSettingOrCreate(key: "friendCount", default: 0) as! Int
        
        return VStack {
            ProfileBannerView()
            HStack {
                Spacer()
                Text("\(friendCount) friend\((friendCount > 1 || friendCount == 0) ? "s" : "")")
                    .bold()
                Spacer()
            }
            Spacer()
        }
    }
}

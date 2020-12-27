//
//  ProfileView.swift
//  SocialQR
//
//  Created by Rahul Yedida on 11/17/20.
//

import SwiftUI
import ImagePickerView

struct ProfileView: View {
    private let settingsManager = SettingsManager()
    @State var userInfo: Friend
    @State var showImagePicker = false
    @State var image: UIImage?
    @State var updateProfileFn: (Friend) -> ()
    
    var body: some View {
        var friendCount: Int = 0
        do {
            friendCount = try Int(settingsManager.getSettingOrCreate(key: "friendCount", default: "0"))!
        } catch {
            print("Could not fetch friend count: " + error.localizedDescription)
        }
        
        return VStack {
            VStack {
                Button(action: {self.showImagePicker = true}) {
                    if (self.userInfo.img == nil) {
                        Image(systemName: "person.fill")
                            .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .cornerRadius(50)
                    } else {
                        Image(uiImage: UIImage(data: self.userInfo.img!)!)
                            .resizable()
                            .frame(width: 100, height: 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .cornerRadius(50)
                    }
                }
                Text(self.userInfo.name)
                    .font(.title2)
                    .bold()
            }
            HStack {
                Spacer()
                Text("\(friendCount) friend\((friendCount > 1 || friendCount == 0) ? "s" : "")")
                    .bold()
                Spacer()
            }
            Spacer()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(sourceType: .photoLibrary) { image in
                self.image = image
                self.userInfo.img = image.pngData()
                self.updateProfileFn(self.userInfo)
            }
        }
    }
}

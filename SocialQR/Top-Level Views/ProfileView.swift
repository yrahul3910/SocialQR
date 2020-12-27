//
//  ProfileView.swift
//  SocialQR
//
//  Created by Rahul Yedida on 11/17/20.
//

import SwiftUI
import ImagePickerView
import CoreImage

struct ProfileView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: UserInfo.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \UserInfo.name, ascending: true)
    ])
    var user: FetchedResults<UserInfo>
    
    private let settingsManager = SettingsManager()
    @State var showImagePicker = false
    @State var image: UIImage?
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("Q", forKey: "inputCorrectionLevel")
            
            return UIImage(ciImage: filter.outputImage!)
        }
        
        return nil
    }
    
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
                if (self.user[0].img == nil) {
                    Image(systemName: "person.fill")
                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .cornerRadius(50)
                } else {
                    Image(uiImage: UIImage(data: self.user[0].img!.data(using: .utf8)!)!)
                        .resizable()
                        .frame(width: 100, height: 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .cornerRadius(50)
                }
                }
                    Text(self.user[0].name!)
                    .font(.title2)
                    .bold()
                Image(uiImage: generateQRCode(
                    from: String(data: try! JSONEncoder().encode(getFriendFromUserInfo(user: self.user[0])), encoding: .utf8)!
                )!)
                .frame(width: 200, height: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
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
                print(self.user.count)
                
                self.user[0].setValue(String(data: (image.pngData() ?? "".data(using: .utf8))!, encoding: .utf8), forKey: "img")
                
                do {
                    try self.moc.save()
                } catch {
                    print("[ProfileView] Failed to save context: " + error.localizedDescription)
                }
            }
        }
    }
}

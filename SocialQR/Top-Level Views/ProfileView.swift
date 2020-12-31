//
//  ProfileView.swift
//  SocialQR
//
//  Created by Rahul Yedida on 11/17/20.
//

import SwiftUI
import ImagePickerView
import CoreImage
import CoreImage.CIFilterBuiltins

struct ProfileView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: UserInfo.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \UserInfo.name, ascending: true)
    ])
    var user: FetchedResults<UserInfo>
    
    @ObservedObject var friends: UserFriendList
    @State var showImagePicker = false
    @State var image: UIImage?
    
    func generateQRCode(from data: UserInfo) -> UIImage? {
        var friend = getFriendFromUserInfo(user: data)
        friend.img = nil
        let d = try! JSONEncoder().encode(friend)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(d, forKey: "inputMessage")
            filter.setValue("Q", forKey: "inputCorrectionLevel")
            
            return UIImage(ciImage: filter.outputImage!).resizeImage(targetSize: CGSize.init(width: 200, height: 200))
        }
        
        return nil
    }
    
    var body: some View {
        var friendCount: Int = 0
        let decoder = try! NSKeyedUnarchiver(forReadingFrom: self.user[0].img!)
        
        do {
            friendCount = try JSONDecoder().decode(FriendList.self, from: self.friends.jsonData!.data(using: .utf8)!).friends.count
        } catch {
            print("[ProfileView] Failed to get friend count: " + error.localizedDescription)
        }
        
        return VStack {
            VStack {
                HStack {
                    Button(action: {self.showImagePicker = true}) {
                        if (self.user[0].img == nil) {
                            Image(systemName: "person.fill")
                                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .cornerRadius(50)
                        } else {
                            Image(uiImage: UIImage(coder: decoder)!)
                                .frame(width: 100, height: 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .cornerRadius(50)
                        }
                    }.padding()
                    VStack {
                        Text(self.user[0].name!)
                            .font(.title2)
                            .bold()
                        Text("\(friendCount) friend\((friendCount > 1 || friendCount == 0) ? "s" : "")")
                            .bold()
                    }.padding()
                    Spacer()
                }
                
                if (self.user[0].img != nil) {
                    Image(uiImage: generateQRCode(
                            from: self.user[0])!
                    )
                    .frame(width: 200, height: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(sourceType: .photoLibrary) { image in
                self.image = image
                
                let encoder = NSKeyedArchiver(requiringSecureCoding: false)
                image.resizeImage(targetSize: CGSize.init(width: 100, height: 100)).encode(with: encoder)
                encoder.finishEncoding()
                print(encoder.encodedData)
                
                // TODO: Fix
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

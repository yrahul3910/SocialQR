//
//  FirstRunView.swift
//  SocialQR
//
//  Created by Rahul Yedida on 12/5/20.
//

import SwiftUI
import iPhoneNumberField
import ImagePickerView

struct FirstRunView: View {
    @Environment(\.managedObjectContext) var moc
    
    @State private var name: String = ""
    @State private var phone: String = ""
    @State var showImagePicker: Bool = false
    @State var image: UIImage?
    @State var errorMessage: String = ""
    
    func populateCoreData() {
        // Populate Core Data
        let userInfo = UserInfo(context: self.moc)
        userInfo.name = name
        userInfo.phone = phone
        
        let encoder = NSKeyedArchiver(requiringSecureCoding: false)
        
        if image == nil {
            image = UIImage(systemName: "person.fill")
        }
        image!.resizeImage(targetSize: CGSize.init(width: 100, height: 100)).encode(with: encoder)
        encoder.finishEncoding()
        userInfo.img = encoder.encodedData
        
        
        let newFriends = UserFriendList(context: self.moc)
        do {
            newFriends.jsonData = String(data: try JSONEncoder().encode(FriendList(friends: [])), encoding: .utf8)
            
            try self.moc.save()
        } catch {
            print("[FirstRunView] Could not save data: " + error.localizedDescription)
        }
    }
    
    func processForm() -> Void {
        if (!validate()) {
            self.errorMessage = "Please fill out all the details."
        } else {
            self.errorMessage = ""
            
            let state = SystemState(context: self.moc)
            state.firstRun = false
            populateCoreData()
        }
    }
    
    func validate() -> Bool {
        if ((self.name != "") && (self.phone != "")) {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        VStack {
            Text("Welcome!")
                .font(.title)
                .bold()
                .padding()
            Text("We just need a few quick details to get you started.")
            Text(self.errorMessage)
                .foregroundColor(.red)
            TextField("Name", text: $name)
                .padding()
            iPhoneNumberField("Phone", text: $phone)
                .flagHidden(false)
                .flagSelectable(true)
                .padding()
            HStack {
                if (self.image == nil) {
                    Image(systemName: "person.fill")
                } else {
                    Image(uiImage: self.image!)
                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .cornerRadius(50)
                }
                Button(action: {self.showImagePicker = true;}, label: {
                    Text("Choose a profile picture (optional)")
                        .font(.body)
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        .padding()
                })
            }
            Spacer()
            HStack {
                Spacer()
                Button(action: self.processForm, label: {
                    Text("Continue!")
                })
                Spacer()
            }
        }.padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(sourceType: .photoLibrary) { image in
                self.image = image
            }
        }
    }
}

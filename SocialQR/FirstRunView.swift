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
    var userInfoFn: (Friend) -> ()
    
    @EnvironmentObject var firstRun: ObservableBool
    
    @State private var name: String = ""
    @State private var phone: String = ""
    @State var showImagePicker: Bool = false
    @State var image: UIImage?
    @State var errorMessage: String = ""
    
    func processForm() -> Void {
        if (!validate()) {
            self.errorMessage = "Please fill out all the details."
        } else {
            self.errorMessage = ""
            firstRun.setFalse()
            
            let user: Friend = Friend(name: self.name, phone: self.phone, notes: "", img: self.image?.pngData())
            print(user)
            self.userInfoFn(user)
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

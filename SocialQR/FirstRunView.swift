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
    @EnvironmentObject var firstRun: ObservableBool
    @State private var name: String = ""
    @State private var phone: String = ""
    @State var showImagePicker: Bool = false
    @State var image: UIImage?
    
    var body: some View {
        VStack {
            Text("Welcome!")
                .font(.title)
                .bold()
            Text("We just need a few quick details to get you started.")
            TextField("Name", text: $name)
                .padding()
            iPhoneNumberField("Phone", text: $phone)
                .flagHidden(false)
                .flagSelectable(true)
                .padding()
        }.padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(sourceType: .photoLibrary) { image in
                self.image = image
            }
        }
    }
}

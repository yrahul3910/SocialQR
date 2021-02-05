//
//  FriendView.swift
//  SocialQR
//
//  Created by Rahul Yedida on 11/17/20.
//

import SwiftUI
import Contacts

struct FriendView: View {
    @State var img: UIImage?
    @State var name: String
    @State var phone: String
    @State var chatFn: (Friend) -> ()
    
    func addToContacts() {
        let newContact = CNMutableContact()
        newContact.givenName = String(name.split(separator: " ")[0])
        
        if (name.split(separator: " ").count > 1) {
            newContact.familyName = String(name.split(separator: " ")[1])
        }

        // Save the contact
        let saveRequest = CNSaveRequest()
        saveRequest.add(newContact, toContainerWithIdentifier: nil)

        let store = CNContactStore()
        do {
            try store.execute(saveRequest)
        } catch {
            print("Saving contact failed, error: \(error)")
        }
    }
    
    var body: some View {
        Button(action: {
            self.chatFn(Friend(name: self.name, phone: self.phone, notes: "", img: self.img?.pngData()))
        }) {
            HStack {
                if (self.img != nil) {
                    Image(uiImage: self.img!)
                }
                VStack {
                    Text(self.name)
                        .font(.headline)
                        .bold()
                    Button(action: {
                        let formattedString = "sms:\(self.phone)&body="
                        let url: NSURL = URL(string: formattedString)! as NSURL
                    
                        UIApplication.shared.open(url as URL)
                    }) {
                        Text(verbatim: self.phone)
                            .foregroundColor(.green)
                    }
                }.padding()
                Spacer()
            }.padding()
        }
        Spacer()
        Button(action: self.addToContacts, label: {
            Image(systemName: "person.crop.circle.fill.badge")
        })
    }
}

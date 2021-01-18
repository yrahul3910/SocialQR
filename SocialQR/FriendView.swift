//
//  FriendView.swift
//  SocialQR
//
//  Created by Rahul Yedida on 11/17/20.
//

import SwiftUI

struct FriendView: View {
    @State var img: UIImage?
    @State var name: String
    @State var phone: String
    @State var chatFn: (Friend) -> ()
    
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
    }
}

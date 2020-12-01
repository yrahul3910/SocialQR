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
    
    var body: some View {
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
            }
            Spacer()
        }.padding()
        Spacer()
    }
}

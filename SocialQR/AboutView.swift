//
//  AboutView.swift
//  SocialQR
//
//  Created by Rahul Yedida on 12/31/20.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            HStack {
                Text("About")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }.padding()
            List {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(appVersion)
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("Developer")
                    Spacer()
                    Text("Rahul Yedida")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("Contact")
                    Spacer()
                    Link("r.yedida@pm.me", destination: URL(string: "mailto://r.yedida@pm.me")!)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

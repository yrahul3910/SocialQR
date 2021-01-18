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
                HStack {
                    Text("Report an issue")
                    Spacer()
                    Link("GitHub", destination: URL(string: "https://github.com/yrahul3910/SocialQR/issues")!)
                        .foregroundColor(.blue)
                }
            }
            Spacer()
            Text("NearConnect is free and open-source software, and does not collect any data about you.")
                .font(.footnote)
                .padding()
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

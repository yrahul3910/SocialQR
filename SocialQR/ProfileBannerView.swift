//
//  ContentView.swift
//  SocialQR
//
//  Created by Rahul Yedida on 11/16/20.
//

import SwiftUI

struct ProfileBannerView: View {
    let url = URL(string: "https://ryedida.me/profile.jpg")!
    var body: some View {
        VStack {
            AsyncImage<Text>(
                url: self.url,
                placeholder: {  Text("loading") }
            )
                .aspectRatio(contentMode: .fit)
            Text("Rahul Yedida")
                .bold()
                .font(.title2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileBannerView()
    }
}

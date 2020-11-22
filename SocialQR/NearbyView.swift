//
//  NearbyView.swift
//  SocialQR
//
//  Created by Rahul Yedida on 11/21/20.
//

import SwiftUI

struct NearbyView: View {
    @ObservedObject var peerList: PeerList
    
    var body: some View {
        VStack {
            Text("Nearby")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            ScrollView {
                ForEach(peerList.peers.indices, id: \.self, content: { index in
                    Button(action: {}, label: {
                        HStack {
                            Circle()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.green)
                            Text(verbatim: peerList.peers[index].name)
                            Spacer()
                        }
                    }).padding()
                })
            }
        }
    }
}

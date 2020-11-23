//
//  NearbyView.swift
//  SocialQR
//
//  Created by Rahul Yedida on 11/21/20.
//

import SwiftUI
import MultipeerKit

struct NearbyView: View {
    @ObservedObject var peerList: PeerList
    var popupFunc: (String) -> Void
    var requestFunc: (Peer) -> ()
    
    var body: some View {
        VStack {
            Text("Nearby")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            ScrollView {
                ForEach(peerList.peers.indices, id: \.self, content: { index in
                    HStack {
                        Circle()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.green)
                        Text(verbatim: peerList.peers[index].name)
                        Spacer()
                        Button(action: {
                            self.requestFunc(peerList.peers[index])
                            self.popupFunc("Request sent!")
                            
                        }, label: {
                            Image(systemName: "plus.bubble.fill")
                        })
                    }.padding()
                })
            }
        }
    }
}

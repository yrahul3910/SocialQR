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
    @State var isShowingMessages = false
    @ObservedObject var chatModel: ChatModel
    @State var hasUnread: Bool
    var popupFunc: (String) -> Void
    var requestFunc: (Peer) -> ()
    var broadcastToggleFunc: () -> Void
    var transceiver: MultipeerTransceiver
    
    var body: some View {
        NavigationView {
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
            .navigationBarTitle("Nearby")
            .navigationBarItems(
                trailing: Button(action: {
                    self.isShowingMessages = true
                    self.broadcastToggleFunc()
                    self.hasUnread = false
                }) {
                    Image(systemName: self.hasUnread ? "bubble.right.fill" : "bubble.right")
                        .padding()
                })
            .sheet(isPresented: $isShowingMessages, content: { GlobalMessagesView(model: self.chatModel, transceiver: self.transceiver) })
        }
    }
}

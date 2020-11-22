//
//  TabView.swift
//  SocialQR
//
//  Created by Rahul Yedida on 11/17/20.
//

import SwiftUI
import MultipeerKit

struct CodablePayload: Codable, Hashable {
    let message: String
}

struct Peer {
    let name: String
    let id: String
}

class PeerList: ObservableObject {
    @Published var peers: [Peer]
    
    init() {
        self.peers = []
    }
    
    func addPeer(name peerName: String, id peerId: String) {
        self.peers.append(Peer(name: peerName, id: peerId))
    }
    
    func removePeer(id peerId: String) {
        self.peers.remove(
            at: self.peers.firstIndex(where: { peer in
                peer.id == peerId
            })!
        )
    }
}

struct MainTabView: View {
    private let friends: FriendList
    private let decoder = JSONDecoder()
    private var transceiver = MultipeerTransceiver()
    @State var peers = PeerList()
    
    init() {
        /* Fetch the user friend list from the stored data. If it does
         not exist, then create an empty friend list, and return that
         instead.
         */
        friends = try! decoder.decode(FriendList.self,
                                 from: UserDefaults.standard.data(forKey: "friendList") ?? JSONEncoder().encode(FriendList(friends: [])))
    }
    
    var body: some View {
        TabView {
            NearbyView(peerList: peers)
                .tabItem {
                    Image(systemName: "dot.radiowaves.left.and.right")
                    Text("Near Me")
                }
            
            FriendsView(friends: self.friends)
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Friends")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }.onAppear() {
            transceiver.resume()
            transceiver.peerAdded = { peer in
                self.peers.addPeer(name: peer.name, id: peer.id)
            }
            transceiver.peerRemoved = { peer in
                self.peers.removePeer(id: peer.id)
            }
        }
    }
}

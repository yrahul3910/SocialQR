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

struct MainTabView: View {
    private let friends: FriendList
    private let decoder = JSONDecoder()
    private var transceiver = MultipeerTransceiver()
    
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
            transceiver.availablePeersDidChange = { peer in
                print("\n\nPeer \(peer.description) changed.\n\n")
            }
        }
    }
}

//
//  TabView.swift
//  SocialQR
//
//  Created by Rahul Yedida on 11/17/20.
//

import SwiftUI

struct MainTabView: View {
    private let friends: FriendList
    private let decoder = JSONDecoder()
    
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
        }
    }
}

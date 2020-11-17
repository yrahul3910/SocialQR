//
//  FriendsView.swift
//  SocialQR
//
//  Created by Rahul Yedida on 11/17/20.
//

import SwiftUI

struct FriendList: Codable {
    var friends: Array<Friend>
}

struct FriendsView: View {
    @State var friends: FriendList
    
    var body: some View {
        VStack {
            HStack {
                Text("Friends")
                    .font(.title)
                    .bold()
                Spacer()
                Image(systemName: "plus")
            }
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(1...friends.friends.endIndex, id: \.self) {
                        FriendView(img: UIImage(data: friends.friends[$0].img)!,
                                   name: friends.friends[$0].name,
                                   phone: friends.friends[$0].phone)
                    }
                }
            }
        }
    }
}

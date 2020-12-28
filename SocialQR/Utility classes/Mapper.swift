//
//  Mapper.swift
//  SocialQR
//
//  Created by Rahul Yedida on 12/27/20.
//

import Foundation

func getFriendFromUserInfo(user: UserInfo) -> Friend {
    return Friend(name: user.name!, phone: user.phone!, notes: user.notes, img: user.img)
}

func getFriendListFromEntity(list: UserFriendList) -> FriendList {
    do {
        return try JSONDecoder().decode(FriendList.self, from: list.jsonData!.data(using: .utf8)!)
    } catch {
        print("[Mapper] Could not convert UserFriendList to FriendList: " + error.localizedDescription)
        return FriendList(friends: [])
    }
}

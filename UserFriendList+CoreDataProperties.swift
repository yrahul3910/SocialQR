//
//  UserFriendList+CoreDataProperties.swift
//  SocialQR
//
//  Created by Rahul Yedida on 12/27/20.
//
//

import Foundation
import CoreData


extension UserFriendList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserFriendList> {
        return NSFetchRequest<UserFriendList>(entityName: "UserFriendList")
    }

    @NSManaged public var jsonData: String?

}

extension UserFriendList : Identifiable {

}

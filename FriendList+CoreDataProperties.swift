//
//  FriendList+CoreDataProperties.swift
//  SocialQR
//
//  Created by Rahul Yedida on 12/27/20.
//
//

import Foundation
import CoreData


extension FriendList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FriendList> {
        return NSFetchRequest<FriendList>(entityName: "FriendList")
    }

    @NSManaged public var jsonData: String?

}

extension FriendList : Identifiable {

}

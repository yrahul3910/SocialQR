//
//  UserInfo+CoreDataProperties.swift
//  SocialQR
//
//  Created by Rahul Yedida on 12/27/20.
//
//

import Foundation
import CoreData


extension UserInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserInfo> {
        return NSFetchRequest<UserInfo>(entityName: "UserInfo")
    }

    @NSManaged public var img: Data?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var phone: String?

}

extension UserInfo : Identifiable {

}

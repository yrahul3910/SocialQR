//
//  SystemState+CoreDataProperties.swift
//  SocialQR
//
//  Created by Rahul Yedida on 12/27/20.
//
//

import Foundation
import CoreData


extension SystemState {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SystemState> {
        return NSFetchRequest<SystemState>(entityName: "SystemState")
    }

    @NSManaged public var firstRun: Bool

}

extension SystemState : Identifiable {

}

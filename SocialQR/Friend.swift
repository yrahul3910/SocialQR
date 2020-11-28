//
//  Friend.swift
//  SocialQR
//
//  Created by Rahul Yedida on 11/17/20.
//

import SwiftUI

struct Friend: Codable, Hashable {
    var name: String?
    var phone: String?
    var notes: String?
    var img: Data?
    var links: Dictionary<String, String>?
    var interests: Array<String>?
    var hobbies: Array<String>?
    var occupation: String?
}

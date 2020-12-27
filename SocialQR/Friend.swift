//
//  Friend.swift
//  SocialQR
//
//  Created by Rahul Yedida on 11/17/20.
//

import SwiftUI

struct Friend: Codable, Hashable {
    var name: String
    var phone: String
    var notes: String?
    var img: Data?
    
    // Fixed-value for future compatibility
    let dataVersion: String = "1.0"
    
    // Silences a warning about the immutable property
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case phone = "phone"
        case notes = "notes"
        case img = "img"
        case dataVersion = "dataVersion"
    }
}

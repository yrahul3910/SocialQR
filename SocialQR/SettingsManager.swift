//
//  SettingsManager.swift
//  SocialQR
//
//  Created by Rahul Yedida on 12/5/20.
//

import Foundation

/*
 A custom settings manager that uses UserDefaults. This is simply
 an abstraction layer that provides convenience functions for the
 views to use.
 */
class SettingsManager {
    enum SettingsError: Error {
        case invalidKey
    }
    
    func doesSettingExist(key: String) -> Bool {
        return UserDefaults.standard.string(forKey: key) != nil
    }
    
    func getSetting(key: String) throws -> String {
        if !doesSettingExist(key: key) {
            throw SettingsError.invalidKey
        }
        
        let value = UserDefaults.standard.string(forKey: key)
        return value!
    }
    
    func getSettingOrCreate(key: String, default value: String?) throws -> String {
        if doesSettingExist(key: key) {
            return try getSetting(key: key)
        } else {
            setSetting(key: key, value: value!)
            return value!
        }
    }
    
    func setSetting(key: String, value: String) -> Void {
        UserDefaults.standard.set(value, forKey: key)
    }
}

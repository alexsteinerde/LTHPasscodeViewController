//
//  LTHKeychainUtils.swift
//  LTHPasscodeViewController Demo
//
//  Created by Jason Rodriguez on 12/10/21.
//  Copyright © 2021 Roland Leth. All rights reserved.
//

import Foundation
import UIKit
import Security
import CryptoKit

public class LTHKeychainUtils: NSObject {
    static private let SFHFKeychainUtilsErrorDomain = "SFHFKeychainUtilsErrorDomain"
    static private let deviceKey: String = UIDevice.current.identifierForVendor?.uuidString ?? "SN_DEFAULT_KEY"
    static private let symmetricKey: SymmetricKey = SymmetricKey(data: SHA256.hash(data: deviceKey.data(using: .utf8) ?? Data()))
    static private let prefix: String = SHA256.hash(data: deviceKey.data(using: .utf8) ?? Data()).compactMap { String(format: "%02x", $0) }.joined()
    
    @objc public class func getPasswordForUsername(_ username: String?, andServiceName serviceName: String?) throws -> String {
        
        guard let username = username, let serviceName = serviceName else {
            throw NSError(domain: SFHFKeychainUtilsErrorDomain, code: -2000, userInfo: nil)
        }
        
        // Set up a query dictionary with the base query attributes: item type (generic), username, and service
        let keys: [String] = [
            kSecClass as String,
            kSecAttrAccount as String,
            kSecAttrService as String
        ]
        let objects: [String] = [
            kSecClassGenericPassword as String,
            username,
            serviceName
        ]
        
        // First do a query for attributes, in case we already have a Keychain item with no password data set.
        // One likely way such an incorrect item could have come about is due to the previous (incorrect)
        // version of this code (which set the password as a generic attribute instead of password data).
        let attributeQuery: [String: Any] = [keys[0]: objects[0], keys[1]: objects[1], keys[2]: objects[2], (kSecReturnAttributes as String): true]
        
        var attrResult: CFTypeRef?
        var status: OSStatus?
        status = SecItemCopyMatching(attributeQuery as CFDictionary, &attrResult)
        
        if let status = status, status != noErr {
            // No existing item found - simply return nil for the password
            if status != errSecItemNotFound {
                // Only return an error if a real exception happened - not simply for "not found."
                throw NSError(domain: SFHFKeychainUtilsErrorDomain, code: Int(status), userInfo: nil)
            }
            return ""
        }
        
        // We have an existing item, now query for the password data associated with it.
        let passwordQuery: [String: Any] = [keys[0]: objects[0], keys[1]: objects[1], keys[2]: objects[2], (kSecReturnData as String): true]
        
        var resData: CFTypeRef?
        status = SecItemCopyMatching(passwordQuery as CFDictionary, &resData)
        let resultData = resData as? Data
        
        if let status = status, status != noErr {
            if status == errSecItemNotFound {
                // We found attributes for the item previously, but no password now, so return a special error.
                // Users of this API will probably want to detect this error and prompt the user to
                // re-enter their credentials.  When you attempt to store the re-entered credentials
                // using storeUsername:andPassword:forServiceName:updateExisting:error
                // the old, incorrect entry will be deleted and a new one with a properly encrypted
                // password will be added.
                
                throw NSError(domain: SFHFKeychainUtilsErrorDomain, code: -1999, userInfo: nil)
            } else {
                // Something else went wrong. Simply return the normal Keychain API error code.
                throw NSError(domain: SFHFKeychainUtilsErrorDomain, code: Int(status), userInfo: nil)
            }
        }
        
        if let data = resultData,
           let sealedBoxToOpen = try? ChaChaPoly.SealedBox(combined: data),
           let decryptedData = try? ChaChaPoly.open(sealedBoxToOpen, using: symmetricKey),
           let decryptedString = String(data: decryptedData, encoding: .utf8),
           decryptedString.hasPrefix(prefix) {
            print(decryptedString)
            return String(decryptedString.dropFirst(prefix.count))
        } else {
            print("DEFAULT")
            let password = try getPassword(resultData: resultData) ?? ""
            try storeUsername(username, andPassword: password, forServiceName: serviceName, updateExisting: true)
            return password
        }
    }
    
    private class func getPassword(resultData: Data?) throws -> String? {
        var password: String?
        
        if let resultData = resultData {
            password = String(
                data: resultData,
                encoding: .utf8)
        } else {
            // There is an existing item, but we weren't able to get password data for it for some reason,
            // Possibly as a result of an item being incorrectly entered by the previous code.
            // Set the -1999 error so the code above us can prompt the user again.
            throw NSError(domain: SFHFKeychainUtilsErrorDomain, code: -1999, userInfo: nil)
        }
        
        return password
    }
    
    @objc public class func storeUsername(_ username: String?, andPassword password: String?, forServiceName serviceName: String?, updateExisting: Bool) throws {
        guard let username = username, let password = password, let serviceName = serviceName else {
            throw NSError(domain: SFHFKeychainUtilsErrorDomain, code: -2000, userInfo: nil)
        }
        var existingPassword: String?
        // See if we already have a password entered for these credentials.
        do {
           existingPassword = try self.getPasswordForUsername(username, andServiceName: serviceName)
        } catch {
            if (error as NSError).code == -1999 {
                // There is an existing entry without a password properly stored (possibly as a result of the previous incorrect version of this code.
                
                // Delete the existing item before moving on entering a correct one.
                try deleteItem(forUsername: username, andServiceName: serviceName)
            } else if (error as NSError).code != noErr {
                throw error
            }
        }
        
        var status = noErr
        var encodedPassword = (prefix + password).data(using: .utf8) ?? Data()
        do {
            let cryptedBox = try ChaChaPoly.seal(encodedPassword, using: symmetricKey)
            encodedPassword = cryptedBox.combined
        } catch {
            throw NSError(domain: SFHFKeychainUtilsErrorDomain, code: -2000, userInfo: nil)
        }

        let keys = [
            kSecClass as String,
            kSecAttrService as String,
            kSecAttrLabel as String,
            kSecAttrAccount as String
        ]
        let objects = [
            kSecClassGenericPassword as String,
            serviceName,
            serviceName,
            username
        ]
        
        if let existingPassword = existingPassword, !existingPassword.isEmpty {
            // We have an existing, properly entered item with a password.
            // Update the existing item.
            if (existingPassword != password) && updateExisting {
                let query = [keys[0]: objects[0], keys[1]: objects[1], keys[2]: objects[2], keys[3]: objects[3]]
                let pwd = [kSecValueData as String: encodedPassword]
                status = SecItemUpdate(query as CFDictionary, pwd as CFDictionary)
            }
        } else {
            // No existing entry (or an existing, improperly entered, and therefore now
            // deleted, entry).  Create a new entry.
            let query: [String : Any] = [keys[0]: objects[0], keys[1]: objects[1], keys[2]: objects[2], keys[3]: objects[3], (kSecValueData as String): encodedPassword as Any]
            status = SecItemAdd(query as CFDictionary, nil)
        }
        
        if status != noErr {
            // Something went wrong with adding the new item. Return the Keychain error code.
            throw NSError(domain: SFHFKeychainUtilsErrorDomain, code: Int(status), userInfo: nil)
        }
    }
    
    @objc public class func deleteItem(forUsername username: String?, andServiceName serviceName: String?) throws {
        guard let username = username, let serviceName = serviceName else {
            throw NSError(domain: SFHFKeychainUtilsErrorDomain, code: -2000, userInfo: nil)
        }
        
        let query: [String : Any] = [
                kSecClass as String: kSecClassGenericPassword as String,
                kSecAttrAccount as String: username,
                kSecAttrService as String: serviceName,
                kSecReturnAttributes as String: NSNumber(value: true)
        ]
        let status: OSStatus? = SecItemDelete(query as CFDictionary)
        if let status = status, status != noErr {
            throw NSError(domain: SFHFKeychainUtilsErrorDomain, code: Int(status), userInfo: nil)
        }
    }
}

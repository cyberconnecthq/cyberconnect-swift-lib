//
//  SecurityKeyStore.swift
//  CyberConnectSwiftExample
//
//  Created by 吴鹏发 on 5/10/22.
//

import Foundation
import CryptoKit
import Security

struct SecurityKeyStore {
    func storeKey<T: SecurityKeyConvertible>(_ key: T, label: String) throws {
        
        let attributes = [kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
                          kSecAttrKeyClass: kSecAttrKeyClassPrivate] as [String: Any]
        
        guard let secKey = SecKeyCreateWithData(key.x963Representation as CFData,
                                                attributes as CFDictionary,
                                                nil)
            else {
                throw KeyStoreError("Unable to create SecKey representation.")
        }
        
        let query = [kSecClass: kSecClassKey,
                     kSecAttrApplicationLabel: label,
                     kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
                     kSecUseDataProtectionKeychain: true,
                     kSecValueRef: secKey] as [String: Any]
        
    
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeyStoreError("Unable to store item: \(status.message)")
        }
    }
    
    func readKey<T: SecurityKeyConvertible>(label: String) throws -> T? {
        let query = [kSecClass: kSecClassKey,
                     kSecAttrApplicationLabel: label,
                     kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
                     kSecUseDataProtectionKeychain: true,
                     kSecReturnRef: true] as [String: Any]
        
        var item: CFTypeRef?
        var secKey: SecKey
        switch SecItemCopyMatching(query as CFDictionary, &item) {
        case errSecSuccess: secKey = item as! SecKey
        case errSecItemNotFound: return nil
        case let status: throw KeyStoreError("Keychain read failed: \(status.message)")
        }
        
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(secKey, &error) as Data? else {
            throw KeyStoreError(error.debugDescription)
        }
        let key = try T(x963Representation: data)

        return key
    }
    
    func deleteKey(label: String) throws {
        let query = [kSecClass: kSecClassKey,
                     kSecUseDataProtectionKeychain: true,
                     kSecAttrApplicationLabel: label] as [String: Any]
        switch SecItemDelete(query as CFDictionary) {
        case errSecItemNotFound, errSecSuccess: break // Ignore these.
        case let status:
            throw KeyStoreError("Unexpected deletion error: \(status.message)")
        }
    }
}


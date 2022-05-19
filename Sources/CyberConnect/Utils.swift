//
//  Utils.swift
//  CyberConnectSwiftExample
//
//  Created by 吴鹏发 on 5/3/22.
//

import Foundation
import CryptoKit

public struct Utils {
    static let shared = Utils()
    public init() {}
    func retriveCyberConnectSignKey(address: String) -> P256.Signing.PrivateKey? {
        let key = getKey(address: address)
        do {
            guard let result: P256.Signing.PrivateKey = try SecurityKeyStore().readKey(label: key) else {
                //if can't find key in keychain, generate a new one
                let privateKey = P256.Signing.PrivateKey()
                try SecurityKeyStore().storeKey(privateKey, label: key)
                return privateKey
            }
            return result
        } catch {
            print(error)
        }
        return nil
    }

    func getAuthorizeString(localPublicKeyPem: String) -> String {
        return "I authorize CyberConnect from this device using signing key:\n\(localPublicKeyPem)"
    }
    
    private func getKey(address: String) -> String {
        return "CyberConnectKey_\(address)"
    }
}

public func onMainThread(_ closure: @escaping () -> Void) {
    if Thread.isMainThread {
        closure()
    } else {
        DispatchQueue.main.async {
            closure()
        }
    }
}

extension String {
    func pemRepresentationContent()-> String? {
        var components = self.components(separatedBy: "\n")
        if components.count > 3 {
            components.removeFirst()
            components.removeLast()
            let result = components.joined(separator: "\n")
            return result
        }
        return nil
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}

//
//  SecurityKeyConvertible.swift
//  CyberConnectSwiftExample
//
//  Created by 吴鹏发 on 5/10/22.
//

import Foundation
import CryptoKit

protocol SecurityKeyConvertible: CustomStringConvertible {
    init<Bytes>(x963Representation: Bytes) throws where Bytes: ContiguousBytes
    var x963Representation: Data { get }
}

extension SecurityKeyConvertible {
    public var description: String {
        return self.x963Representation.withUnsafeBytes { bytes in
            return "Key representation contains \(bytes.count) bytes."
        }
    }
}

// Assert that the NIST keys are convertible.
extension P256.Signing.PrivateKey: SecurityKeyConvertible {}
extension P256.KeyAgreement.PrivateKey: SecurityKeyConvertible {}
extension P384.Signing.PrivateKey: SecurityKeyConvertible {}
extension P384.KeyAgreement.PrivateKey: SecurityKeyConvertible {}
extension P521.Signing.PrivateKey: SecurityKeyConvertible {}
extension P521.KeyAgreement.PrivateKey: SecurityKeyConvertible {}


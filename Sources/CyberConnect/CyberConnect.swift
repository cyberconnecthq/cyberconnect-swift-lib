//
//  CyberConnect.swift
//  CyberConnectSwiftExample
//
//  Created by 吴鹏发 on 5/3/22.
//

import Foundation
import CryptoKit

public enum ConnectionType: String, CaseIterable {
    case follow = "follow"
    case like = "like"
    case report = "report"
    case watch = "watch"
    case vote = "vote"
}

enum SignResult: String, CaseIterable {
    case invalid = "INVALID_SIGNATURE"
    case success = "SUCCESS"
}

public struct CyberConnect {
    var address: String
    
    public init(address: String) {
        self.address = address
        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: "CyberConnectActivated") {
            Utils().deleteKey(address: address)
            userDefaults.set(true, forKey: "CyberConnectActivated")
        }
    }
    
    public func connect(toAddress: String, alias: String, network: NetworkType, connectType: ConnectionType = .follow, compeletion: @escaping CompleteionBlock) {
        NetworkRequestManager().connect(fromAddress: address, toAddress: toAddress, alias: alias, network: network, connectType: connectType, compeletion: compeletion)
    }
    
    public func disconnect(toAddress: String, alias: String, network: NetworkType, compeletion: @escaping CompleteionBlock) {
        NetworkRequestManager().disconnect(fromAddress: address, toAddress: toAddress, alias: alias, network: network, compeletion: compeletion)
    }
    
    public func alias(toAddress: String, alias: String, network: NetworkType, compeletion: @escaping CompleteionBlock) {
        NetworkRequestManager().setAlias(fromAddress: address, toAddress: toAddress, alias: alias, network: network, compeletion: compeletion)
    }
    
    public func getBatchConnections(toAddresses: [String], compeletion: @escaping CompleteionBlock) {
        NetworkRequestManager().getBatchConnections(fromAddress: address, toAddresses: toAddresses, compeletion: compeletion)
    }
    
    public func getIdentity(completion: @escaping CompleteionBlock) {
        NetworkRequestManager().getIdentity(address: address, completion: completion)
    }
    
    public func registerKey(signature: String, network: NetworkType, completion: @escaping CompleteionBlock) {
        NetworkRequestManager().registerKey(address: address, signature: signature, network: network, completion: completion)
    }
    
    public func retriveCyberConnectSignKey(address: String) -> P256.Signing.PrivateKey? {
        return Utils.shared.retriveCyberConnectSignKey(address: address)
    }
    
    public func isCyberConnectActivated() -> Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.bool(forKey: "CyberConnectActivated")
    }
    
    public func refreshCyberConnectStatus() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "CyberConnectActivated")
    }
    
    public func getAuthorizeString(localPublicKeyPem: String) -> String {
        return Utils.shared.getAuthorizeString(localPublicKeyPem: localPublicKeyPem)
    }
}

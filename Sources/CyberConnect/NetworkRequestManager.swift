//
//  NetworkRequestManager.swift
//  CyberConnectSwiftExample
//
//  Created by 吴鹏发 on 5/10/22.
//

import Foundation
import CryptoKit
import Security

typealias CompleteionBlock = (_ data:NSDictionary)->Void;
struct NetworkRequestManager {
    
    func getBatchConnections(fromAddress: String, toAddresses: [String], compeletion: @escaping CompleteionBlock) {
        
        let variable = Variables(from: fromAddress, to: toAddresses)
        let operationData = OperationData(operationName: "GetBatchConnections", query: "query GetBatchConnections($from: String!, $to: [String!]!) {\n  connections(fromAddr: $from, toAddrList: $to, network: ETH) {\n    toAddr\n    followStatus {\n      isFollowing\n      isFollowed\n      __typename\n    }\n    __typename\n  }\n}\n", variables: variable)
        do {
            let jsonData = try JSONEncoder().encode(operationData)
            let requestString = String(data: jsonData, encoding: .utf8)!
            NetworkRequestManager().postRequest(body: requestString, completionHandler: compeletion)
        } catch { print(error) }
    }
    
    func setAlias(fromAddress: String, toAddress: String, alias: String, network: NetworkType, compeletion: @escaping CompleteionBlock) {
        do {
            let timestampDouble = NSDate().timeIntervalSince1970 * 1000
            let timestamp = UInt(Double(truncating: timestampDouble as NSNumber))
            let operation = Operation(name: "follow", from: fromAddress, to: toAddress, namespace: "CyberConnect", network: network, alias: alias, timestamp: timestamp)
            
            guard let privateKey =  Utils.shared.retriveCyberConnectSignKey(address: fromAddress) else {
                print("can't get local key pairs")
                return
            }
            
            let operationData = try JSONEncoder().encode(operation)
            let signature = try privateKey.signature(for: operationData)
            let signatureString = "0x\(signature.rawRepresentation.hexEncodedString())"
            let operationString = String(data: operationData, encoding: .utf8)!
            let signKeyString = privateKey.publicKey.pemRepresentation.pemRepresentationContent()
            let variables = Variables(fromAddr: fromAddress, toAddr: toAddress, namespace: "CyberConnect", alias: alias, signature: signatureString, operation: operationString, signingKey: signKeyString, network: network)
            let input = Input(input: variables)
            let query = "mutation alias($input: UpdateConnectionInput!) {alias(input: $input) {result}}"
            let operationInputData = OperationInputData(operationName: "alias", query: query, variables: input)
            let jsonData = try JSONEncoder().encode(operationInputData)
            let requestString = String(data: jsonData, encoding: .utf8)!
            NetworkRequestManager().postRequest(body: requestString, completionHandler: compeletion)
        } catch {
            print(error)
        }
    }
    
    func connect(fromAddress: String, toAddress: String, alias: String, network: NetworkType, connectType: ConnectionType, compeletion: @escaping CompleteionBlock) {
        connectOrDisconnect(isConnect: true, fromAddress: fromAddress, toAddress: toAddress, alias: alias, network: network, connectType: connectType, compeletion: compeletion)
    }
    
    func disconnect(fromAddress: String, toAddress: String, alias: String, network: NetworkType, compeletion: @escaping CompleteionBlock) {
        connectOrDisconnect(isConnect: false, fromAddress: fromAddress, toAddress: toAddress, alias: alias, network: network, compeletion: compeletion)
    }
    
    func registerKey(address: String, signature: String, network: NetworkType, completion: @escaping CompleteionBlock) {
        
        guard let privateKey =  Utils.shared.retriveCyberConnectSignKey(address: address) else {
            print("can't get local key pairs")
            return
        }
        
        guard let publicKeyString: String = privateKey.publicKey.pemRepresentation.pemRepresentationContent() else {
            print("invalid pem key string")
            return
        }
        
        let message = "I authorize CyberConnect from this device using signing key:\n\(publicKeyString)"
        let variable = Variables(address: address, signature: signature, network: network, message: message)
        let input = Input(input: variable)
        let operationInputData = OperationInputData(operationName: "registerKey", query: "mutation registerKey($input: RegisterKeyInput!) {\n      registerKey(input: $input) {\n        result\n      }\n    }", variables: input)
        do {
            let jsonData = try JSONEncoder().encode(operationInputData)
            let requestString = String(data: jsonData, encoding: .utf8)!
            NetworkRequestManager().postRequest(body: requestString,completionHandler: completion)
        } catch { print(error) }
    }
    
    func getIdentity(address: String, completion: @escaping CompleteionBlock) {
        let variable = Variables(address: address, first: 100)
        let operationData = OperationData(operationName: "GetIdentity", query: "query GetIdentity($address: String!, $first: Int, $after: String) {\n  identity(address: $address) {\n    address\n    domain\n    twitter {\n      handle\n      verified\n      __typename\n    }\n    avatar\n    followerCount(namespace: \"\")\n    followingCount(namespace: \"\")\n    followings(first: $first, after: $after, namespace: \"\") {\n      pageInfo {\n        ...PageInfo\n        __typename\n      }\n      list {\n        ...Connect\n        __typename\n      }\n      __typename\n    }\n    followers(first: $first, after: $after, namespace: \"\") {\n      pageInfo {\n        ...PageInfo\n        __typename\n      }\n      list {\n        ...Connect\n        __typename\n      }\n      __typename\n    }\n    friends(first: $first, after: $after, namespace: \"\") {\n      pageInfo {\n        ...PageInfo\n        __typename\n      }\n      list {\n        ...Connect\n        __typename\n      }\n      __typename\n    }\n    __typename\n  }\n}\n\nfragment PageInfo on PageInfo {\n  startCursor\n  endCursor\n  hasNextPage\n  hasPreviousPage\n  __typename\n}\n\nfragment Connect on Connect {\n  address\n  domain\n  alias\n  namespace\n  __typename\n}\n", variables: variable)
        do {
            let jsonData = try JSONEncoder().encode(operationData)
            let requestString = String(data: jsonData, encoding: .utf8)!
            NetworkRequestManager().postRequest(body: requestString, completionHandler: completion)
        } catch { print(error) }
    }
    
    private func connectOrDisconnect(isConnect: Bool, fromAddress: String, toAddress: String, alias: String, network: NetworkType, connectType: ConnectionType = .follow, compeletion: @escaping CompleteionBlock) {
        do {
            let timestampDouble = NSDate().timeIntervalSince1970 * 1000
            let timestamp = UInt(Double(truncating: timestampDouble as NSNumber))
            let operation = Operation(name: isConnect ? connectType.rawValue : "unfollow", from: fromAddress, to: toAddress, namespace: "CyberConnect", network: network, alias: alias, timestamp: timestamp)
            
            guard let privateKey =  Utils.shared.retriveCyberConnectSignKey(address: fromAddress) else {
                print("can't get local key pairs")
                return
            }
            
            let operationData = try JSONEncoder().encode(operation)
            let signature = try privateKey.signature(for: operationData)
            let signatureString = "0x\(signature.rawRepresentation.hexEncodedString())"
            let operationString = String(data: operationData, encoding: .utf8)!
            let signKeyString = privateKey.publicKey.pemRepresentation.pemRepresentationContent()
            let variables = Variables(fromAddr: fromAddress, toAddr: toAddress, namespace: "CyberConnect", alias: alias, signature: signatureString, operation: operationString, signingKey: signKeyString, network: network)
            let input = Input(input: variables)
            let query = isConnect ? "mutation connect($input: UpdateConnectionInput!) {connect(input: $input) {result}}" : "mutation disconnect($input: UpdateConnectionInput!) {disconnect(input: $input) {result}}"
            let operationInputData = OperationInputData(operationName: isConnect ? "connect" : "disconnect", query: query, variables: input)
            let jsonData = try JSONEncoder().encode(operationInputData)
            let requestString = String(data: jsonData, encoding: .utf8)!
            NetworkRequestManager().postRequest(body: requestString, completionHandler: compeletion)
        } catch {
            print(error)
        }
    }
    
    private func postRequest(body: String, completionHandler: @escaping CompleteionBlock) {
        let urlPath: String = "https://api.cybertino.io/connect/"
        let url: URL = URL(string: urlPath)!
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        let data = body.data(using: .utf8)
        request.timeoutInterval = 60
        request.httpBody = data
        request.httpShouldHandleCookies=false
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    completionHandler(jsonResult)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }.resume()
    }
}

struct OperationData: Codable {
    var operationName: String
    var query: String
    var variables: Variables
}

struct OperationInputData: Codable {
    var operationName: String
    var query: String
    var variables: Input
}

enum NetworkType: String, CaseIterable, Codable {
    case eth = "ETH"
    case sol = "SOL"
}

struct Variables: Codable {
    var fromAddr: String?
    var toAddr: String?
    var from: String?
    var to: [String]?
    var namespace: String?
    var address: String?
    var first: UInt?
    var alias: String?
    var signature: String?
    var operation: String?
    var signingKey: String?
    var network: NetworkType?
    var message: String?
}

struct Input: Codable {
    var input: Variables
}

struct Operation: Codable {
    var name: String
    var from: String
    var to: String
    var namespace: String
    var network: NetworkType
    var alias: String
    var timestamp: UInt
}

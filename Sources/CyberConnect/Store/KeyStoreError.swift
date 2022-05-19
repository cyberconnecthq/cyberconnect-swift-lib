//
//  KeyStoreError.swift
//  CyberConnectSwiftExample
//
//  Created by 吴鹏发 on 5/10/22.
//

import Foundation

struct KeyStoreError: Error, CustomStringConvertible {
    var message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    public var description: String {
        return message
    }
}

extension OSStatus {
    var message: String {
        return (SecCopyErrorMessageString(self, nil) as String?) ?? String(self)
    }
}


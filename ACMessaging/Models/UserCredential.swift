//
//  UserCredentials.swift
//  XMPPMessenger
//
//  Created by Sepandat Pourtaymour on 13/07/2019.
//  Copyright © 2019 Sepandat Pourtaymour. All rights reserved.
//

import Foundation
import XMPPFramework

import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

struct UserCredential {
    let id: String
    fileprivate var _password: String
    fileprivate var userInfo: [String: String]
    
    var hashedPassword: String? {
        return _password.md5String()
    }
    
    var jabberID: XMPPJID? {
        return XMPPJID(string: id)
    }
    
    init(id: String, password: String, userInfo: [String: String]) {
        self.id = id
        self._password = password
        self.userInfo = userInfo
    }
}

extension String {
    func md5Data() -> Data? {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        guard let messageData = self.data(using:.utf8) else { return nil}
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }
    
    func md5String() -> String? {
        guard let data = md5Data() else { return nil }
        let md5Hex =  data.map { String(format: "%02hhx", $0) }.joined()
        return md5Hex
    }
}

//
//  Message.swift
//  XMPPMessenger
//
//  Created by Sepandat Pourtaymour on 13/07/2019.
//  Copyright © 2019 Sepandat Pourtaymour. All rights reserved.
//

import UIKit
//import Firebase

class Message: NSObject, NSCoding {
    
    var id: String?
    var senderId: String?
    var text: String?
    var timestamp: NSNumber?
    var recipientId: String?
    
    var image: Image?
    var imageUrl: String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    
    var videoUrl: String?
    
    func chatPartnerId() -> String? {
        return recipientId
//        return senderId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
    init(dictionary: [String: Any]) {
        super.init()
        id = dictionary[CommunicationManager.shared.idKey] as? String
        senderId = dictionary[CommunicationManager.shared.senderIdKey] as? String
        text = dictionary[CommunicationManager.shared.textKey] as? String
        timestamp = dictionary[CommunicationManager.shared.timestampKey] as? NSNumber
        recipientId = dictionary[CommunicationManager.shared.receiverIdKey] as? String
        
        let imageUrl = dictionary[CommunicationManager.shared.imageUrlKey] as? String
        let imageHeight = dictionary[CommunicationManager.shared.imageHeightKey] as? CGFloat
        let imageWidth = dictionary[CommunicationManager.shared.imageWidthKey] as? CGFloat
        image = Image(url: imageUrl, width: imageWidth, height: imageHeight)
        
        videoUrl = dictionary[CommunicationManager.shared.videoUrlKey] as? String
    }
    
    required init(coder decoder: NSCoder) {
        self.senderId = decoder.decodeObject(forKey: CommunicationManager.shared.senderIdKey) as? String
        self.text = decoder.decodeObject(forKey: CommunicationManager.shared.textKey) as? String
        self.timestamp = decoder.decodeObject(forKey: CommunicationManager.shared.timestampKey) as? NSNumber
        self.recipientId = decoder.decodeObject(forKey: CommunicationManager.shared.receiverIdKey) as? String
        
        let imageUrl = decoder.decodeObject(forKey: CommunicationManager.shared.imageUrlKey) as? String
        let imageHeight = decoder.decodeObject(forKey: CommunicationManager.shared.imageHeightKey) as? CGFloat
        let imageWidth = decoder.decodeObject(forKey: CommunicationManager.shared.imageWidthKey) as? CGFloat
        self.image = Image(url: imageUrl, width: imageWidth, height: imageHeight)

        self.videoUrl = decoder.decodeObject(forKey: CommunicationManager.shared.videoUrlKey) as? String
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(senderId, forKey: CommunicationManager.shared.senderIdKey)
        coder.encode(text, forKey: CommunicationManager.shared.textKey)
        coder.encode(timestamp, forKey: CommunicationManager.shared.timestampKey)
        coder.encode(recipientId, forKey: CommunicationManager.shared.receiverIdKey)
        coder.encode(imageUrl, forKey: CommunicationManager.shared.imageUrlKey)
        coder.encode(imageHeight, forKey: CommunicationManager.shared.imageHeightKey)
        coder.encode(imageWidth, forKey: CommunicationManager.shared.imageWidthKey)
        coder.encode(videoUrl, forKey: CommunicationManager.shared.videoUrlKey)
    }
    
}








